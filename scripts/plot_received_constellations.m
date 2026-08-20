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

%% ===================== Q4a : received constellations =====================
EbNo_show = 15;                            % dB
for s = 1:numel(schemes)
    ModType = schemes{s};  BitPerSymbol = bps(s);
    Nb = BitPerSymbol*5e3;
    b  = randi(2,1,Nb) - 1;
    s4 = MAF(ZeroPadder(Mapper(b,ModType),SamplePerSymbol),SamplePerSymbol);
    s6 = AWGN(s4, studentIDs, EbNo_show, BitPerSymbol, SamplePerSymbol, NumOfSubcarriers);
    s8 = Downsampler(MAF(s6,SamplePerSymbol),SamplePerSymbol);
    s8 = s8*sqrt(BitPerSymbol)/sqrt(mean(abs(s8).^2));   % display at nominal scale
    scatterplot(s8); grid on;
    title([ModType ' received, E_b/N_0 = ' num2str(EbNo_show) ' dB']);
end
