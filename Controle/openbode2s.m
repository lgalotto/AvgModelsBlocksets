% function [s] = openbode2s(wc,pm)
%
% Calcula o ponto de projeto no dominio s a partir dos pontos no bode de
% malha aberta.
% 
% exemplo:
%
% wc = 10; % rad/s 
% pm = 45; % graus
% [s] = openbode2s(wc,pm)
% % Obs.: veja tambem a funcao calctempo os parametros no tempo a partir do s.
% % Obs.: funciona melhor para pm < 70 graus.

% criado - 10/2021 - LGJ
function [s] = openbode2s(wc,pm)

% parametros da malha fechada
%zeta = abs(cos(angle(s)));
%wn = abs(s);

% formula exata para margem de fase
%tand(pm) = 2*zeta/sqrt(-2*zeta^2+sqrt(1+4*zeta^4));
zeta = (1/(16/tan(pm*pi/180)^2 + 16/tan(pm*pi/180)^4))^(1/4);

% formula exata para wc
%wc = wn*sqrt(sqrt(1+4*zeta^4)-2*zeta^2);
wn = wc/((4*zeta^4 + 1)^(1/2) - 2*zeta^2)^(1/2);

s = -zeta*wn + j*wn*sqrt(1-zeta^2);