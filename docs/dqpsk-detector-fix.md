# The π/4-DQPSK detector was not differential

The DQPSK BER curve in the original report sits flat at roughly 10⁻¹ and never
enters a waterfall. That is not a noise-doubling penalty - differential
detection costs about 3 dB against coherent QPSK, not four orders of magnitude.
This note records what was actually wrong, because the failure is more
instructive than the working code around it.

## Symptom

Three things were true at once, and only one of them looked like a problem:

- The noiseless modulator/demodulator loopback returned exactly zero errors.
- Static phase offsets of 10° and 20° returned exactly zero errors, which was
  read as confirming differential phase immunity.
- The BER-versus-Eb/N₀ curve was flat at ~6% and did not improve with SNR.

A bug that survives every functional test and only shows up in the error-rate
measurement is usually a bug in what the measurement assumes, not in the
plumbing.

## Root cause

The demodulator quantised each received symbol to the absolute 8-PSK phase grid
first, and only then differenced the quantised phases:

```matlab
[~, ind] = min(abs(theta - phi), [], 1);   % snap y_n to nearest of 8 grid phases
phi_n = theta(ind)';
p  = [pi/4, phi_n(1:end-1)];
an = mod(phi_n - p, 2*pi);                 % difference the *quantised* phases
```

That is coherent 8-PSK detection followed by a phase subtraction. It is not
differential detection. The report's own text describes the correct operation -
`z_n = y_n · conj(y_{n-1})` - but the code does not implement it.

Two distinct defects follow from that one structural choice.

**1. The nearest-phase search uses linear, not circular, distance.**
`abs(theta - phi)` treats phase as a number line. A symbol whose true phase is 0
but which noise pushes to 359° has `|359 - 0| = 359` against `|359 - 315| = 44`,
so it snaps to 315° - one grid step wrong, every time it wraps. Symbols at 0°
are 1/8 of the stream and roughly half of them wrap, and each bad phase corrupts
two differential transitions. That predicts a floor near 6%, which is what the
curve shows. The `phi(phi>=6.283) = phi(phi>=6.283)-6.283` line above it is an
attempt to patch the same wrap with a magic number; it fixes the noiseless case
only, which is why the loopback test passed.

**2. Quantising before differencing discards the phase reference.**
Even with the wrap fixed, snapping to an *absolute* grid means the receiver is
using absolute phase. It works only because the transmitter starts from a known
reference of π/4 and accumulates, so the transmitted sequence happens to land on
the absolute 8-PSK grid. A real differential receiver has no such reference.

## Why the phase-offset test passed anyway

This is the part worth keeping. The 10° and 20° offsets returned zero errors not
because the detector is phase-immune, but because 10° and 20° are smaller than
the 22.5° half-spacing of the 8-PSK grid - every symbol stays inside its own
decision cell. That is grid tolerance, not differential immunity. The 45° case
passed for a different accidental reason: 45° is exactly one grid step, so every
symbol lands cleanly on a *neighbouring* valid grid point and the differences
still come out right.

`CombinationB.m` ships with a commented-out offset line using **130°** - a value
that is neither below 22.5° nor a multiple of 45°. Had that been the value
tested, the detector would have failed immediately:

| Static offset | As written | Wrap fixed | True differential |
|---|---|---|---|
| 0° | 0.000 | 0.000 | 0.000 |
| 10° | 0.000 | 0.000 | 0.000 |
| 20° | 0.000 | 0.000 | 0.000 |
| 30° | **0.125** | 0.000 | 0.000 |
| 45° | 0.000 | 0.000 | 0.000 |
| 130° | **0.125** | 0.000 | 0.000 |

(Noiseless, 400 000 symbols, symbol-rate model.) Three offsets were tested and
all three were in the accidentally-passing set.

## Fix

Difference the complex samples first, then decide. A static channel phase θ
appears in both `y_n` and `y_{n-1}` and cancels exactly.

```matlab
elseif strcmpi( ModType , 'DQPSK' )
    % Power normalisation
    u = u / sqrt( mean( abs(u).^2 ) );

    % True differential detection: difference first, then decide.
    % A static channel phase theta appears in both terms and cancels.
    prev = [ exp(1i*pi/4) , u(1:end-1) ];    % reference phase for symbol 1
    z    = u .* conj( prev );                % z_n = y_n * conj(y_{n-1})

    % Valid transitions are the odd multiples of pi/4
    j   = mod( round( (angle(z) - pi/4) / (pi/2) ) , 4 );   % 0..3
    map = [0 1 3 2];                         % j -> dibit, matches Mapper.m
    y   = map( j + 1 );
    y   = reshape( de2bi( y , 2 , 'left-msb' ).' , 1 , [] );
```

The `theta`/`min` search, the 6.283 patch, and the floating-point equality tests
(`an == pi/4`) all disappear. Comparing floats for exact equality was a latent
third defect: any transition not exactly on the list fell through and silently
decoded as dibit 00.

While there, delete the dead `x = 1:M-1; theta = (2*pi*x/M);` in the `Mapper.m`
DQPSK branch - `theta` is never used, and the range wrongly omits phase 0.

## Verification

Symbol-rate model, 400 000 symbols per point, compared against the closed-form
DQPSK bound `Q₁(a,b) − ½I₀(ab)e^{−(a²+b²)/2}`:

| Eb/N₀ | As written | Wrap fixed only | True differential | Theory |
|---|---|---|---|---|
| 0 dB | 0.316 | 0.309 | 0.164 | 1.64e-1 |
| 2 dB | 0.268 | 0.255 | 0.099 | 9.93e-2 |
| 4 dB | 0.211 | 0.188 | 0.0489 | 4.87e-2 |
| 6 dB | 0.152 | 0.114 | 0.0173 | 1.72e-2 |
| 8 dB | 0.103 | 0.0516 | 0.00350 | 3.64e-3 |
| 10 dB | 0.0745 | 0.0155 | 2.98e-4 | 3.43e-4 |
| 12 dB | 0.0648 | 0.00229 | 1.1e-5 | 9.05e-6 |
| 14 dB | 0.0629 | 1.22e-4 | 0 | 3.20e-8 |

The corrected detector tracks the bound across the whole range. Fixing only the
wrap removes the floor but leaves the curve several dB adrift, which is the
signature of the second defect: it is still using an absolute reference.

## What this cost, and what it is worth

The result the DQPSK section was built to demonstrate - immunity to static
channel phase, without a carrier recovery loop - is real and is what the
corrected detector delivers at any offset, including 130°. The original
implementation demonstrated something weaker and looked like it had demonstrated
the strong version, because every test chosen happened to fall inside the region
where the two are indistinguishable.

The lesson is about test selection rather than about DQPSK. Three phase offsets
were tried and all three were inside the accidentally-passing set; the one value
the framework itself suggested would have exposed the bug on the first run.
