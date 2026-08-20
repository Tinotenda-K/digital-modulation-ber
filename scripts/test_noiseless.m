%% test_noiseless.m  -- Q3: modulator and demodulator back-to-back, no channel
clear; clc;
for ModType = ["QPSK","16QAM"]
    bps = 2*(ModType=="QPSK") + 4*(ModType=="16QAM");
    Nb  = bps*1e4;
    b    = randi(2,1,Nb) - 1;
    a    = Mapper(b,  char(ModType));     % modulate
    bhat = DeMapper(a, char(ModType));    % demodulate
    fprintf('%-6s  BER = %g\n', ModType, sum(bhat~=b)/Nb);
end
