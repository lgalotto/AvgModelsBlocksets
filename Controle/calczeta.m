% function zeta = calczeta(up)
%
% Retorna o valor da constante de amortecimento para um determinado valor
% de ultrapassagem (up entre 0 a 1) para a resposta ao degrau de um sistema 
% dinâmico.
%
% Por exemplo: Para 20% de ultrapassagem (overshoot):
%
% up = 0.2;
% zeta = calczeta(up)


% LGJ - 01/2017
function zeta = calczeta(up)

if any(up) < 0,
    warning('A ultrapassagem deve ser positiva.')
    up = abs(up);
end
if any(up) > 1,
    warning('O valor máximo de up é 1 = 100%.')
    up = max(up,1);
end

% zeta = -log(up)./sqrt(pi^2 + (log(up)).^2);

zeta = sqrt(1./((pi^2)./(log(up)).^2 + 1)); % Equação também válida para up = 0;