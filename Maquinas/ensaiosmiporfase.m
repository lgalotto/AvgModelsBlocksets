% function [Xm,Rr,Rs,Xs,Xr] = ensaiosmiporfase(Voc, Ioc, Poc, Vbl, Ibl, Pbl)
%
% Funcao criada para retornar os parametros de ensaios de motores de
% inducao.
%

% Criado 03/2016 - LGJ - Melhorado 05/2024
function [Xm,Rr,Rs,Xs,Xr] = ensaiosmiporfase(Voc, Ioc, Poc, Vbl, Ibl, Pbl, Rs)
    if nargin < 7, Rs = 0; end

    if Pbl > Vbl*Ibl
        warning('Potencia ativa deve ser menor do que a Aparente. Corrigindo:');
        Pbl = Vbl*Ibl;
        disp(Pbl)
    end

    Req = Pbl/Ibl^2;
    if Rs == 0
        Rr = Req/2;
        Rs = Req/2;
    else
        Rr = Req - Rs;
    end

    if Poc > Voc*Ioc
        warning('Potencia ativa deve ser menor do que a Aparente. Corrigindo:');
        Poc = Voc*Ioc;
        disp(Poc)
    end

    
    Qbl = sqrt((Vbl*Ibl).^ 2 - (Pbl.^2));
    metodo = 2;
    if metodo == 1
      Xeq = Req*Qbl/Pbl;  % Req*tan(acos(Pbl/(Vbl*Ibl)))
      Rpeq = (Voc.^2)/Poc;
      % S0 = (Req/2)/((Req/2) + Rpeq)
      Xm = Voc/sqrt((Ioc.^2) - (Voc/Rpeq).^2);
    else
      Xeq = Qbl/(Ibl.^2);  % Req*tan(acos(Pbl/(Vbl*Ibl)))
      Qoc = sqrt((Voc*Ioc).^2 - (Poc.^2));
      Xm = Qoc/(Ioc.^2);
    end

    % Motor classe A - Norma IEEE 112
    Xs = Xeq/2;
    Xr = Xeq/2;
