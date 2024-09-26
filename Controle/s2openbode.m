% function [wc,pm] = s2openbode(s)
%
% Calcula o ponto de projeto no bode de malha aberta a partir do ponto
% desejado no dominio s.
% 
% exemplo:
%
% s = -1+j; % veja tambem a funcao calcs para retornar o s
% [wc,pm] = s2openbode(s)
% 

% criado - 10/2020 - LGJ
function [wc,pm] = s2openbode(s)

% parametros da malha fechada
zeta = abs(cos(angle(s)));
wn = abs(s);

% formula exata para margem de fase
pm = atand(2*zeta/sqrt(-2*zeta^2+sqrt(1+4*zeta^4)));

% formula exata para wc
wc = wn*sqrt(sqrt(1+4*zeta^4)-2*zeta^2);