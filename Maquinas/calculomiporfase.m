% function [Si,Ii,Ir,Pmec,Tmec,wm] = calculomiporfase(MaquinaAssincrona,Vi,f,S)
%
% Calcula a máquina por fase, criada com as funçoes:
% - MaquinaAssincrona
% - ensaiosmiporfase
% 
% f  - frequencia da rede em Hz
% p  - numero de polos.
% Vi - tensao de fase.
% S  - escorregamento para a condicao de carga. S tambem pode ser vetor.
% 
% Exemplo:
% tensao = 220; frequencia = 60; polos = 4;
% MI = MaquinaAssincrona(tensao, frequencia, polos)
% [Si,Ii,Ir,Pmec,Tmec,wm] = calculomiporfase(MI,127,60,0.1)

% Criado em 03/2016 - LGJ - melhorado 11/2018 - melhorado em 05/2024
function [Si,Ii,Ir,Pmec,Tmec,wm] = calculomiporfase(MaquinaAssincrona,Vi,f,S)

    if any(abs(S)) > 0.00001
      % impedancias
      Rotor = (MaquinaAssincrona.rr)./S + 1i*(MaquinaAssincrona.xr);
      Estator = MaquinaAssincrona.rs + 1i*MaquinaAssincrona.xs;
      Zm = 1i*MaquinaAssincrona.xm;
      Zeq = Estator + Zm./(1 + Zm./Rotor);
      
      % Correntes
      Ii = Vi./Zeq;
      Ir = (Ii.*Zm)./(Rotor + Zm);
    else
      % impedancias
      % Rotor = infinito
      Estator = MaquinaAssincrona.rs + 1i*MaquinaAssincrona.xs;
      Zm = 1i*MaquinaAssincrona.xm;
      Zeq = Estator + Zm;
      % Correntes
      Ii = Vi./Zeq;
      Ir = 0*Ii;
    end

    % Potencias
    Si = Vi.*conj(Ii); % De Entrada
    Pg = real(Si) - real(Estator)*abs(Ii).^2; % Pot. do entreferro
    Pmec = Pg - MaquinaAssincrona.rr*(abs(Ir).^2); % Convertida: (abs(Ir).^2*(Req/2)).*(1-S)./S;
    
    % Mecanicos
    ws = 2*pi*(f/(MaquinaAssincrona.polos/2));
    wm = ws.*(1 - S);
    
    Tmec = zeros(1,length(S));
    
    ind = (wm > 1);
    %if wm > 1
        Tmec(ind) = Pmec(ind)./wm(ind);
    %else
        Tmec(~ind) = MaquinaAssincrona.rr * (abs(Ir(~ind)).^2)/(S(~ind)*ws);
    %end
  
%ind = find(wm < 1);
%Tmec(ind) = (abs(Ir(ind)).^2*(Req/2))./(S(ind).*ws);