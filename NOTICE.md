# Authorship and licence scope

This repository is the modulation/demodulation half of a four-person university
group project. Not every file in it is mine, so the MIT licence in
[LICENSE](LICENSE) cannot apply uniformly. This file states what applies where.

## Written by me and my project partner - MIT licensed

| File | Notes |
|---|---|
| `src/Mapper.m` | BPSK, QPSK, 16-QAM and π/4-DQPSK constellation mapping and Gray coding. The `if/elseif` skeleton and the function signature came with the assignment; the mapping bodies are ours. |
| `src/DeMapper.m` | Power normalisation, threshold detection, Gray de-mapping, differential detection. Same skeleton caveat. |
| `scripts/*.m` | Analysis, sweep and plotting scripts. |
| `docs/*.md` | Write-ups. |

All four schemes live inside the single `Mapper`/`DeMapper` pair, dispatched on
the `ModType` argument. There are no separate per-scheme modulator files.

## Course-provided scaffolding - not mine

The files under `framework/` were supplied with the assignment as a fixed
transmit/receive harness. They are reproduced unmodified so the chain runs, and
they are **not** covered by the MIT grant above:

- `Initialization.m`
- `ZeroPadder.m`
- `MAF.m`
- `Downsampler.m`
- `AWGN.m`
- `CombinationB.m`
- `plotPSD.m`

If the course owner objects to their redistribution, they can be removed and
replaced with a short description of the interface each one implements.

## Reduced before publication

`framework/ChannelEncoder.m` and `framework/ChannelDecoder.m` are present only
because `CombinationB.m` calls them. The versions in this repository carry the
pass-through (`'NONE'`) path alone. Their Hamming branches were written by the
two group members who did the channel-coding half and have been **stripped, not
published** - see below.

## Deliberately excluded

The channel-coding half of the project - repetition and Hamming encoders and
decoders, coding-gain analysis, and the integrated coded 16-QAM link - was
written by the other two group members. It is not in this repository and is not
mine to publish.

`CombinationA.m`, `CombinationC.m`, `OFDMModulator.m` and `OFDMDemodulator.m`
are also excluded. The two OFDM files are untouched course templates whose
bodies are entirely `% Insert your code here`; that path was never implemented
by this group, and the two Combination scripts that depend on them cannot run.
Committing files that error on invocation would be worse than omitting them.
