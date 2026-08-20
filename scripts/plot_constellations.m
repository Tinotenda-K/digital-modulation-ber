%% plot_constellations.m  -- ideal constellations, Gray labels, decision boundaries

d = sqrt(0.4); lv = d*[-3 -1 1 3];

% ----- QPSK -----
figure; hold on; axis equal; grid on;
plot([0 0],[-2 2],'k--'); plot([-2 2],[0 0],'k--');
pts = [1+1i, 1-1i, -1+1i, -1-1i];  lab = {'11','10','01','00'};   % [b1 b2]=[I Q]
plot(real(pts),imag(pts),'o','MarkerFaceColor','b','MarkerSize',9);
text(real(pts)+0.08, imag(pts)+0.08, lab);
title('QPSK: Gray mapping and decision boundaries'); xlabel('I'); ylabel('Q');

% ----- 16-QAM -----
figure; hold on; axis equal; grid on;
for t = [-2*d 0 2*d]
    plot([t t],[-2.4 2.4],'k--'); plot([-2.4 2.4],[t t],'k--');
end
axb = {'00','01','11','10'};       % level order -3d,-1d,+1d,+3d
for ii = 1:4
    for qq = 1:4
        p = lv(ii) + 1i*lv(qq);
        plot(real(p),imag(p),'o','MarkerFaceColor','b','MarkerSize',8);
        text(real(p)+0.06, imag(p)+0.11, [axb{ii} axb{qq}], 'FontSize',8);
    end
end
title('16-QAM: Gray mapping and decision boundaries'); xlabel('I'); ylabel('Q');