% Mapper (A.K.A. complex equivalent BB modulator)
function y = Mapper( u , ModType )

    if strcmp( ModType , 'BPSK' )
        map = [complex( -1 , eps ) complex( +1 , eps )];
        
        y = complex( zeros( 1 , length(u) ) , zeros( 1 , length(u) ) );
        y(u==0) = map(1);
        y(u==1) = map(2);
        
    elseif strcmpi( ModType , 'QPSK' )
       % Group bits into pairs [b1, b2]
       b = reshape(u, 2, length(u)/2).';
       
       % Map 1st bit to In-Phase (0 -> -1, 1 -> +1)
       I = zeros(length(b), 1);
       I(b(:,1) == 0) = -1;
       I(b(:,1) == 1) = 1;
       
       % Map 2nd bit to Quadrature (0 -> -1, 1 -> +1)
       Q = zeros(length(b), 1);
       Q(b(:,2) == 0) = -1;
       Q(b(:,2) == 1) = 1;
       
       % Combine into complex symbols. 
       y = (I + 1i*Q).';

    elseif strcmp( ModType , '16QAM' )
       d   = sqrt(0.4);                         % normalisation so that Eb = 1 (Es = 4)
       pam = d*[ -3 -1 +3 +1 ];                 % Gray 4-PAM, indexed by dibit 00,01,10,11
       b   = reshape( u , 4 , length(u)/4 ).';  % each row = [b1 b2 b3 b4]
       iDec = bi2de( b(:,1:2) , 'left-msb' );   % first two bits -> I level
       qDec = bi2de( b(:,3:4) , 'left-msb' );   % last  two bits -> Q level
       y = ( pam(iDec+1) + 1i*pam(qDec+1) ).';  % complex symbol
       
    elseif strcmpi( ModType , 'DQPSK')
       % Reshape into rows of symbols & convert to decimal
       x = reshape(u.',2,[])';
       x = bi2de(x, 'left-msb')';
       % Process normally using 4PSK (on axis)
       % Map depending on decimal value
       %map = [complex( 1 , 0 ) complex( 0 , 1 ) complex( -1 , 0 ) complex( 0 , -1 )];
       map = [pi/4 3*pi/4 -3*pi/4 -pi/4];
       L = zeros( 1 , length(x) );
       L(x==0) = map(1); L(x==1) = map(2); L(x==3) = map(3); L(x==2) = map(4);
       an = L; % Phase transitions
       % Find possible phases
       M = 8;
       x = 1:M-1;
       theta = (2*pi*x/M);
       % Make vector of phases
       phi_n = zeros(1,length(an));
       for i=1:length(an)
           if i == 1
               phi_n(i) = mod(pi/4 + an(i),2*pi);
           else
               phi_n(i) = mod(phi_n(i-1) + an(i),2*pi);
           end
       end
       y = exp(1j*(phi_n));
    end
    
    % To ensure dimension compatibility
    y = y(:).';
end
