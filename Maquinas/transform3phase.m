% function [mat,mnf,m3] = transform3phase(nfases,naofalha)
%
% Funcao que fornece as matrizes de transformacao de n fases para
% trifasico.
% Saidas:
% - mat - matriz de transformacao (trifasico para n fases)
% - mnf - matriz de transformacao (n fases para clarke)
% - m3  - matriz de transformacao (3 fases para clarke)
% 
% Entradas:
% - nfases   - inteiro com o numero desejados de fases.
% - naofalha - um vetor binario com indicacao das fases em operacao.
%
% Exemplo:
% [mat,mnf,m3] = transform3phase(5,[1 1 1 1 0]); % falta da ultima fase.
% wt = linspace(0,4*(2*pi),500);
% fase3 = [sin(wt);sin(wt+2*pi/3);sin(wt+4*pi/3)];
% fasen = mat*fase3;
% subplot(2,1,1); plot(wt,fase3'); subplot(2,1,2); plot(wt,fasen');

% LGJ - 07/2016 - atualizada 01/2019
function [mat,mnf,m3] = transform3phase(nfases,naofalha)

% transformada de clarke convencional
m3 = [cosd(0) cosd(120) cosd(240);
    sind(0) sind(120) sind(240);
    1 1 1];

if nargin < 2
    naofalha = ones(1,nfases);
end

% transformada de clarke para n fases
defasagem = (360)/nfases;
angulos = defasagem.*[0:(nfases-1)];

mn = [cosd(angulos); sind(angulos); ones(1,nfases)];
% if nfases > 3,
%     mn = [mn;eye(nfases-3,nfases)];
%     m3b = [m3;eye(nfases-3,3)];
% end

% selecao de colunas somente para as fases funcionando
mnf = mn(:,logical(naofalha));

mat = pinv(mnf'*mnf)*mnf'*m3;

% if cond(mnf'*mnf) < 0,
%     autovalores = eig(mnf'*mnf);
%     mat = inv(mnf'*mnf + 0.1*autovalores(sum(naofalha)-2)*eye(sum(naofalha)))*mnf'*m3;
% else
%     mat = inv(mnf'*mnf)*mnf'*m3;
% end



