clear; clc; close all;

% ---- fixed framework parameters (initial setup of CombinationB.m) ----
SamplePerSymbol  = 32;
NumOfSubcarriers = 1;
Rb = 1e6;                                  % channel bit rate [bps], CR = 1

x1 = 7; x2 = 5; x3 = 9; x4 = 0;           
studentIDs = 1*x1 + 2*x2 + 3*x3 + 4*x4;
rng( studentIDs , 'twister' );

schemes = {'QPSK','16QAM'};
bps     = [2 4];                           % BitPerSymbol per scheme

%% ===================== Q5 : spectra =====================
figure; hold on; grid on;
for s = 1:numel(schemes)
    ModType = schemes{s};  BitPerSymbol = bps(s);
    Nb = BitPerSymbol*2e4;
    b  = randi(2,1,Nb) - 1;
    s4 = MAF(ZeroPadder(Mapper(b,ModType),SamplePerSymbol),SamplePerSymbol);
    Rs = Rb/BitPerSymbol;                  % symbol rate
    fs = SamplePerSymbol*Rs;               % sampling rate of s4
    plotPSD(s4, fs);
end
xlabel('frequency [kHz]'); ylabel('PSD');
legend('QPSK','16-QAM'); title('Transmit PSD (rectangular pulse)');
