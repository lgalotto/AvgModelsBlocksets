% function [Vi,Ii,Vo,Io,Si,So] = calculotrafoporfase(Vi,Zeq,Zm,Zl,Vo,So)
%
% Calcula o tranformador a partir de uma tensao aplicada e uma carga.
% os parametros de entrada Zeq e Zm podem ser obtidos da funcao abaixo:
%
% ensaiostrafo
% 
% Vi e a tensao de fase.
% Zl e a impedancia de carga
% Vo e So sao opcionais
%
% Zl, Vo e So podem ser vetores de iguais dimensoes, para calculo
% simultaneo de diferentes condicoes de carga.
%
% Ao entrar com Vo, Vi e recalculado. Assim, Vi de entrada pode ser
% qualquer valor mesmo vazio.
%
% Ao entrar com Vo e So, Zl e recalculado. Assim, Zl de entrada pode ser
% qualquer valor mesmo vazio.
% 
% Exemplos:
% Zeq = 1+j*1;
% Rm = 1000; Xm = 100;
% Zm = Rm*j*Xm/(Rm+j*Xm);
% Zl = 1+j*1;
% 
% % Com impedancia de carga constante:
% [Vi,Ii,Vo,Io,Si,So] = calculotrafoporfase(1000,Zeq,Zm,Zl)
%
% % Com tensao de carga constante:
% [Vi,Ii,Vo,Io,Si,So] = calculotrafoporfase([],Zeq,Zm,Zl,1000)
%
% % Com tensao e potencia de carga constantes:
% [Vi,Ii,Vo,Io,Si,So] = calculotrafoporfase([],Zeq,Zm,[],1000,100)


% Criado em 07/2016 - LGJ
% Modificado em 01/2017 - LGJ
function [Vi,Ii,Vo,Io,Si,So] = calculotrafoporfase(Vi,Zeq,Zm,Zl,Vo,So)

if nargin == 5
    So = Vo.*(Vo./Zl)';
    Io = Vo./Zl;
end

if nargin == 6
    Zl = (abs(Vo).^2)./So';
    Io = Vo./Zl;
end

Secundario = Zeq/2 + Zl;
Primario = Zeq/2;
Ztotal = Zm*Secundario./(Secundario + Zm) + Primario;

if nargin >= 5
    Ii = Io.*(Secundario + Zm)/Zm;
    Vi = Io.*Secundario + Ii.*Primario;
end

% corrente do primario
Ii = Vi./Ztotal;
% potencia de entrada
Si = Vi.*conj(Ii);
% corrente do secundario
Io = (Ii*Zm)./(Secundario + Zm);

Vo = Zl.*Io;
So = Vo.*conj(Io);
