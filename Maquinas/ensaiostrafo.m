% function [Rm,Xm,Zeq] = ensaiostrafo(Voc, Ioc, Poc, Vsc, Isc, Psc)
%
% Funcao criada para retornar os parametros de ensaios de transformadores a
% partir dos ensaios a vazio (OC - Open Circuit) e em curto-cirtuito (SC -
% Short Circuit) ensaiados no mesmo lado.
%
% Entrada:
% - Voc: Tensao do ensaio a vazio.
% - Ioc: Corrente do ensaio a vazio.
% - Poc: Potencia do ensaio a vazio.
% - Vsc: Tensao do ensaio em curto-circuito.
% - Isc: Corrente do ensaio em curto-circuito.
% - Psc: Potancia do ensaio em curto-circuito.
%
% Saidas:
% - Rm: Resistencia magnetizacao ou de perdas no nucleo.
% - Xm: Reatancia de magnetizacao.
% - Zeq: Req + j Xeq
% - Req: Resistencia equivalente das bobinas (R1 + R2')
% - Xeq: Reatancia de dispercao equivalente (X1 + X2')
%
%                   Modelo L
%
%    -----------[ Req ]-----[ Xeq ]----------
%       |   |
%       Rm  Xm
%       |   |
%       |   |
%    ----------------------------------------
%

% Criado 12/2015 - LGJ - Atualizado 09/2018
function [Rm,Xm,Zeq] = ensaiostrafo(Voc, Ioc, Poc, Vsc, Isc, Psc)

if Poc > Voc*Ioc
    warning('Potencia ativa deve ser menor do que a Aparente. Corrigindo:');
    Poc = Voc*Ioc
end

Rm = Voc^2/Poc;
Xm = Voc/sqrt(Ioc^2 - (Voc/Rm)^2);

if Psc > Vsc*Isc
    warning('Potencia ativa deve ser menor do que a Aparente. Corrigindo:');
    Psc = Vsc*Isc
end

Req = Psc/Isc^2;
Xeq = Req*tan(acos(Psc/(Vsc*Isc)));
Zeq = Req + 1i*Xeq;
