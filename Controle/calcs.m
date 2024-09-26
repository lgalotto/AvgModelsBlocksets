% function s = calcs(Up,Ts,Tp)
%
% Retorna o ponto no domínio s correspondente à ultrapassagem Up e ao tempo
% de assentamento Ts em segundos.
%
% Por exemplo: Para 20% de ultrapassagem (overshoot) e assentamento em 4 seg:
%
% up = 0.2; ts = 4;
% s = calcs(up,ts)
%
% up = 0.2; tp = 1; 
% s = calcs(up,[],tp)
%
% up = 0.2; ts = 4; tp = 1; 
% s = calcs(up,ts,tp) % Entrando com os 3, utiliza-se o mais rapido.


% Modificado - LGJ - 09/2020
% Criado - LGJ - 12/2017
function s = calcs(Up,Ts,Tp)

zeta = calczeta(Up);

if nargin > 2 % se entrou com Tp
    wd = pi/Tp;
    sigma = -wd/tan(acos(zeta));
    
    if ~isempty(Ts) % se entrou também com Ts
        tal = Ts/4;
        if abs(sigma) < 1/tal % se o requisito de Ts for mais rápido
            sigma = -1/tal;
            wd = abs(sigma)*tan(acos(zeta));
        end
    end
else % se entrou somente com Ts
    tal = Ts/4;
    sigma = -1/tal;
    wd = abs(sigma)*tan(acos(zeta));
end

s = sigma + j*wd;