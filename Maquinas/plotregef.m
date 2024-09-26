function [regulacao,eficiencia] = plotregef(Vi,Ii,Vo,Io)
%[regulacao,eficiencia] = plotregef(Vi,Ii,Vo,Io)
%
%   Funcao que calcula e plota um grafico de regulacao e eficiencia de
%   acordo com uma matriz de tensoes e correntes de entrada para diferentes
%   condicoes.

% LGJ - 01/2017

% Potencia ativa
Pl = real(Vo.*conj(Io));

% Calculo da regulacao
regulacao = (abs(Vi) - abs(Vo))./abs(Vo);

% Calculo da eficiencia
eficiencia = Pl./real(Vi.*conj(Ii));

if nargout == 0
    gcf;
    subplot(2,1,1)
    plot(Pl,regulacao*100);
    title('Regulacao')
    ylabel('%'); xlabel('Carga (W)')
    subplot(2,1,2)
    plot(Pl,eficiencia*100);
    title('Eficiencia')
    ylabel('%'); xlabel('Carga (W)')
end

end

