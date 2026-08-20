% De-mapper (A.K.A. complex equivalent BB demodulator)
function y = DeMapper( u , ModType )

    if strcmp( ModType , 'BPSK' )
        % Power normalization (always start with power normalization)
        u = u * sqrt(1) / sqrt( mean( abs(u).^2 ) );
        % Threshold detector implementation 
        u( real(u) <= 0 ) = -1;
        u( real(u) >  0 ) = +1;
        % Symbol to bit conversion according to constellation
        y = zeros( 1 , length(u) );
        y( u == -1 ) = 0;
        y( u == +1 ) = 1;
    
    elseif strcmp( ModType , 'QPSK' )
        u  = u * sqrt(2) / sqrt( mean( abs(u).^2 ) );   % power norm. to Es = 2
        b1 = real(u) > 0;                               % I decision, boundary I = 0
        b2 = imag(u) > 0;                               % Q decision, boundary Q = 0
        y  = double( reshape( [b1 ; b2] , 1 , 2*length(u) ) );

    elseif strcmp( ModType , '16QAM' )
        u  = u * sqrt(4) / sqrt( mean( abs(u).^2 ) );   % power norm. to Es = 4
        d  = sqrt(0.4);  th = 2*d;                      % boundaries at 0 and +/- 2d
        I  = real(u);  Q = imag(u);
        iDec = zeros(1,length(u));
        iDec( I <  -th )          = 0;   % -3d -> 00
        iDec( I >= -th & I < 0 )  = 1;   % -1d -> 01
        iDec( I >=  0  & I < th ) = 3;   % +1d -> 11
        iDec( I >=  th )          = 2;   % +3d -> 10
        qDec = zeros(1,length(u));
        qDec( Q <  -th )          = 0;
        qDec( Q >= -th & Q < 0 )  = 1;
        qDec( Q >=  0  & Q < th ) = 3;
        qDec( Q >=  th )          = 2;
        iBits = de2bi( iDec , 2 , 'left-msb' );         % M x 2  -> [b1 b2]
        qBits = de2bi( qDec , 2 , 'left-msb' );         % M x 2  -> [b3 b4]
        y = reshape( [iBits qBits].' , 1 , 4*length(u) );
        
    elseif strcmpi( ModType , 'DQPSK')
        % Power normalization (always start with power normalization)
        u = u / sqrt( mean( abs(u).^2 ) );
        % Find possible MPSK phases
        M = 8;
        x = 0:M-1;
        theta = (2*pi*x/M)';
        % Find current phase and compare
        phi = mod(atan2(imag(u),real(u)),2*pi); % Received Phases
        phi(phi>=6.283) = phi(phi>=6.283)-6.283;
        [~, ind] = min(abs(theta - phi), [], 1); % Boundaries
        phi_n = theta(ind)';
        p = [pi/4, phi_n(1:end-1)]; %phi delayed by 1
        an = mod(phi_n-p,2*pi);
        % Convert back to decimal
        y = zeros(1,length(u));
        y(an == pi/4) = 0; y(an == 5*pi/4) = 3;
        y(an == 3*pi/4) = 1; y(an == 7*pi/4) = 2;
        % Convert to binary
        u = de2bi(y, 2, 'left-msb');
        y = reshape(u', 1, []);
    end
    
    % Ensure dimension compatibility
    y = y(:).';
end
