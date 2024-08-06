function [Pmax,Vpa,Ipa,Ind] = encontrapmax(Psun,Tgraus,Voc,Isc,Rp,Rs,Ns,alpha)
% function [Pmax,Vpa,Ipa,Ind] = encontrapmax(Psun,T)
% 
% Calcula a curva de um painel a partir dos parametros de entrada.
%
% Exemplo:
%    encontrapmax(1000,25,32.9/54,8.21,7,0.005,54,3.18e-3)

% Modificado - LGJ - 10/2021

% VARIÁVEIS DE ENTRADA 
if nargin < 2
    Tgraus = 25; 
end
if nargin < 1
    Psun = 1000; 
end

% AJUSTE DA CARACTERÍSTICA I-V 
Ms = 1; 
Mp = 1; 

% DADOS DE CATÁLOGO 
if nargin < 8
    Rs = 0.005; 
    Rp = 7; 
    Ns = 54; 
    Voc = 32.9/Ns; 
    Isc = 8.21; 
    alpha = 3.18e-3;
end

% VETORES PARA SOLUCAO DA CURVA
Vpa = linspace(Ns*Voc*1.2,0,100); 
% Ipa = zeros(size(Vpa)); 
Ipa = linspace(0,Isc*1.2,100); 
% Vpa = Ns*Voc*ones(size(Ipa)); 

% CONSTANTES 
eta = 1.2; % fator de qualidade da juncao p-n
k = 1.38e-23; % cte de Boltzmann
q = 1.60e-19; % carga do eletron
EG = 1.1; % energia da banca proibida (eV)
Tr = 273 + 25; % Temp. de referencia (Kelvin)

% CÁLCULOS 
T = 273 + Tgraus; 
Vt = eta*k*T/q; 
% por modulo
V = Vpa/Ns/Ms; 
I = Ipa/Mp;
Iph = (Isc + alpha*(T-Tr))*Psun/1000; % Fotocorrente
Irr = (Isc-Voc/Rp)/(exp(q*Voc/eta/k/Tr)-1); % Corrente de Saturacao reversa de referencia
Ir = Irr*(T/Tr)^3*exp(q*EG/eta/k*(1/Tr-1/T)); % Corrente de Saturacao reversa da celula

% iterações de Newton para ajustar a corrente à curva
% for j=1:5; 
% I = I - ...
%     (Iph-I-Ir.*(exp((V+I.*Rs)./Vt)-1)-(V+I.*Rs)./Rp)./...
%     (-1-Ir.*exp((V+I.*Rs)./Vt).*Rs./Vt-Rs./Rp); 
% end 
% iterações de Newton para ajustar a tensao à curva
% for j=1:5; 
% V = V - ...
%     (Iph-I-Ir.*(exp((V+I.*Rs)./Vt)-1)-(V+I.*Rs)./Rp)./...
%     (- 1/Rp - (Ir*exp((V + I*Rs)/Vt))/Vt); 
% end 

% Iteracao mista
for j=1:3; 
    % ajuste de corrente à curva
    I = I - ...
    (Iph-I-Ir.*(exp((V+I.*Rs)./Vt)-1)-(V+I.*Rs)./Rp)./...
    (-1-Ir.*exp((V+I.*Rs)./Vt).*Rs./Vt-Rs./Rp); 
    % ajuste de tensao à curva
    V = V - ...
    (Iph-I-Ir.*(exp((V+I.*Rs)./Vt)-1)-(V+I.*Rs)./Rp)./...
    (- 1/Rp - (Ir*exp((V + I*Rs)/Vt))/Vt); 
end 



for j=1:length(I); 
    if I(j)<0, I(j)=0; end 
    if V(j)<0, V(j)=0; end 
end 

% Retornar valores por array
Ipa = I*Mp;
Vpa = V*Ns*Ms; 
Ppa = zeros(1,length(I));
for j=1:length(I); 
    Ppa(j)=Vpa(j)*Ipa(j); 
end 
[Pmax,Ind] = max(Ppa);


% GERAÇÃO DE CURVAS I-V E P-V 
if nargout == 0    
    gcf; 
    subplot(2,1,1)
    plot(Ipa,Vpa);
    ylabel('Tensão (V)')
    xlabel('I (A)')
    title('Curvas do Arranjo Fotovoltaico.')
    line(Ipa(Ind),Vpa(Ind),'marker','+','color',[1 0 0])
    text(Ipa(Ind),Vpa(Ind),[num2str(Psun) ' W/m^2, ' num2str(Tgraus) '°C'])
    
    grid on; 
    
    subplot(2,1,2)
    plot(Ipa,Ppa); 
    xlabel('I (A)')
    ylabel('Potência (W)')
    line(Ipa(Ind),Ppa(Ind),'marker','+','color',[1 0 0])
    grid on; 
end