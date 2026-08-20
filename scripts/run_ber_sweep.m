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

%% ===================== Q4b : BER sweep =====================
EbNodB = 0:1:14;
BER = zeros(numel(schemes), numel(EbNodB));

for s = 1:numel(schemes)
    ModType = schemes{s};  BitPerSymbol = bps(s);
    Nb = BitPerSymbol*1e5;                 % multiple of BitPerSymbol
    for i = 1:numel(EbNodB)
        b  = randi(2,1,Nb) - 1;
        s2 = Mapper(b, ModType);
        s3 = ZeroPadder(s2, SamplePerSymbol);
        s4 = MAF(s3, SamplePerSymbol);
        s6 = AWGN(s4, studentIDs, EbNodB(i), BitPerSymbol, SamplePerSymbol, NumOfSubcarriers);
        s7 = MAF(s6, SamplePerSymbol);
        s8 = Downsampler(s7, SamplePerSymbol);
        s9 = DeMapper(s8, ModType);
        BER(s,i) = mean(s9 ~= b);
    end
end

g = 10.^(EbNodB/10);
ber_qpsk_th = qfunc(sqrt(2*g));            % QPSK = BPSK
ber_16_th   = 0.75*qfunc(sqrt(0.8*g));     % square 16-QAM, Gray

figure; 
semilogy(EbNodB, BER(1,:), 'o', 'MarkerSize',7, 'LineWidth',1.2); hold on; grid on;
semilogy(EbNodB, BER(2,:), 's', 'MarkerSize',7, 'LineWidth',1.2);
semilogy(EbNodB, ber_qpsk_th, '-',  'LineWidth',1.5);
semilogy(EbNodB, ber_16_th,   '--', 'LineWidth',1.5);
xlabel('E_b/N_0 [dB]'); ylabel('BER'); ylim([1e-5 1]);
legend('QPSK (sim)','16-QAM (sim)','QPSK theory','16-QAM theory','Location','southwest');
title('BER: QPSK vs 16-QAM over AWGN');
