% function rlocusanimate(g)
%
% Plots the rlocus function animated, from a transfer funcion g, from tf or
% zpk functions.
%
% Example:
% g = zpk(-7,[0 -5 -15 -20],1);
% rlocusanimate(g);

% Updated 08/2020 - prof. LGJ
% Created 11/2015 - prof. LGJ
function rlocusanimate(g)

% Mapa polo-zero
pzmap(g);

hold on;
drawnow;

% gera os ramos do lugar das raizes

[r,k] = rlocus(g);
% k = linspace(0,100,100);
% r = rlocus(g,k);

% Ajusta os eixos
zs = zero(g);
ps = pole(g);
pszs = [ps;zs];
maiorreal = max(real(pszs(:,1)));
menorreal = min(real(pszs(:,1)));
distreal = maiorreal-menorreal;

maiorimag = max(imag(pszs(:,1)));
menorimag = min(imag(pszs(:,1)));
distimag = maiorimag-menorimag;

distimag = max(distimag,distreal);
distreal = max(distreal,distimag);
if distreal == 0,
    if maiorreal == 0,
        distreal = 1;
    else
        distreal = abs(maiorreal);
    end
    distimag = distreal;
end

axis([menorreal-distreal maiorreal+distreal -maiorimag-distimag maiorimag+distimag])

% melhorar a visualização de polos e zeros
line(real(ps),imag(ps),'marker','x','markersize',10,'linewidth',2,'linestyle','none')
line(real(zs),imag(zs),'marker','o','markersize',10,'linewidth',2,'linestyle','none')

% cria as linhas (hl) e marcadores (rx) da animacao
ordem = size(r,1);
for n = 1:ordem,
    hl(n) = line(real(r(n,1)),imag(r(n,1)),'linewidth',2);
    rx(n) = plot(real(r(n,1)),imag(r(n,1)),'rx');
    set(rx(n),'markersize',13,'linewidth',2);
end
% exibe o valor do ganho k no título
title({'Root Locus Animated';['Gain = ' num2str(k(1))]})
drawnow;
set(gcf,'color',[1 1 1])
f(1) = getframe;
% atualizar os valores iterativamente para cada ganho
for p = 2:length(k),
    for n = 1:ordem,
        set(rx(n),'xdata',real(r(n,p)),'ydata',imag(r(n,p)));
        set(hl(n),'xdata',real(r(n,1:p)),'ydata',imag(r(n,1:p)));
    end
    title({'Root Locus Animated';['Gain = ' num2str(k(p))]})
    drawnow;
    f(p) = getframe;
%     pause(0.1)
end
% movie(f)
% movie2avi(f,'Exemplo-rlocusAnimate'); % Gravar a animacao