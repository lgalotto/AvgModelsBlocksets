% function up = calcup(zeta)
%
% Retorna o valor da ultrapassagem para um determinado valor de constante
% de amortecimento (zeta).
% O valor percentual deve ser multiplicado por 100.

% LGJ - 12/2016
function up = calcup(zeta)

if any(zeta) < 0,
    warning('O amortecimento deve ser positivo. Utilizando o módulo.')
    zeta = abs(zeta);
end

if zeta >= 1,
    up = 0;
else
    up = exp(-zeta*pi./sqrt(1-zeta.^2));
end