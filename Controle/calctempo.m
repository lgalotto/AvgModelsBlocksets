% function [Up,Ts,Tp] = calctempo(s)
%
% Retorna o ponto no domínio s correspondente à ultrapassagem Up e ao tempo
% de assentamento Ts em segundos.
%
% Por exemplo: Para 
% s = -1 + j;
% [Up,Ts,Tp] = calctempo(s)

% Criado - LGJ - 09/2020
function [Up,Ts,Tp] = calctempo(s)

zeta = abs(cos(angle(s)));
Up = calcup(zeta);

sigma = real(s);
Ts = 4/(-sigma);

wd = imag(s);
Tp = pi/wd;