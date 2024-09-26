% function plotfasores(Vi,Ii,Vo,Io,Zeq)
%
% Fornece um grafico de fasores a partir das tensoes e correntes de entrada
% e saida. A entrada Zeq e opcional. Quando informada, os fasores da queda 
% de tensao na resistencia e reatancia serie e incluida no grafico.
%

% LGJ - 27/07/2016
function plotfasores(Vi,Ii,Vo,Io,Zeq)

gcf;
quiver(0,0,real(Vi),imag(Vi),0); % Fasor de tensao de entrada
axis('equal')
grid;
hold on;
quiver(0,0,real(Vo),imag(Vo),0); % Fasor de tensao na carga

quiver(0,0,real(Io),imag(Io),0); % Fasor da corrente na carga

if nargin == 5
    Vqro = Io*real(Zeq);
    Vqxo = Io*imag(Zeq)*1i;
    Vqi = Ii*0; % Uso futuro, se houver necessidade de separar a queda no primario
    quiver([real(Vo);real(Vo+Vqro);real(Vo+Vqro+Vqxo)],[imag(Vo);imag(Vo+Vqro);imag(Vo+Vqro+Vqxo)],...
        [real(Vqro);real(Vqxo);real(Vqi)],[imag(Vqro);imag(Vqxo);imag(Vqi)],0);
    legend('Tensao de Entrada','Tensao de Saida','Corrente na carga','Quedas de tensao');
else
    legend('Tensao de Entrada','Tensao de Saida','Corrente na carga');
end

hold off;
xlabel('Real')
ylabel('Imag')

% Calculo da regulacao e eficiencia para colocar no titulo
reg = 100*(abs(Vi) - abs(Vo))/abs(Vo);
n = 100*real(Vo.*Io')/real(Vi.*Ii');

title({['Eficiencia = ' num2str(round(n*10)/10) ' %'];...
    ['Regulacao = ' num2str(round(reg*100)/100) ' %']})