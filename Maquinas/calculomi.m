function [SI3, Ilinha, Tu, wm, Perdaseletricas, Perdasav] = calculomi(MaquinaAssincrona,Vi,f,S,wm)
% function [SI3, Ilinha, Tu, wm, Perdaseletricas, Perdasav] = calculomi(MaquinaAssincrona,Vi,f,S,wm)
%
% Para calcular os dados a partir de um modelo de maquina assincrona.
%
% Exemplo:
% modelo = ensaiosmi(220,1,30,17.3,5,30,'Y',60,4,0.001)
% [SI3, Ilinha, Tu, wm, Perdaseletricas, Perdasav] = calculomi(modelo,220,60,0.1)

% Criado LGJ - 04/2024
    ws = 2*pi*(f/(MaquinaAssincrona.polos/2));

    if nargin < 2, Vi = MaquinaAssincrona.tensao; end % Aplica nominal
    if nargin < 3, f = MaquinaAssincrona.frequencia; end % Aplica nominal
    if nargin < 4, S = 1; end % Partida como Padrao 
    if nargin < 5
        wm = S*ws; % calcula a velocidade a partir de S
    else
        S = (ws-wm)/ws; % se entrou com wm, recalcular S
    end
    

    if MaquinaAssincrona.tipolig == 1 %'Y' 
      Vfase = Vi/sqrt(3);
      [Si, Ii, Ir, ~, Tmec, wm] = calculomiporfase(MaquinaAssincrona,Vfase,f,S);
      Ilinha = Ii;
    else
      Vfase = Vi;
      [Si, Ii, Ir, ~, Tmec, wm] = calculomiporfase(MaquinaAssincrona,Vfase,f,S);
      Ilinha = Ii*sqrt(3);
    end

    Perdaseletricas = MaquinaAssincrona.nfases*(MaquinaAssincrona.rs*(abs(Ii).^2) + MaquinaAssincrona.rr*(abs(Ir).^2));
    Perdasav = MaquinaAssincrona.dav*(wm.^2);
    %Pu = MaquinaAssincrona.nfases*real(Si) - Perdaseletricas - Perdasav
    Tu = MaquinaAssincrona.nfases*Tmec - MaquinaAssincrona.dav*wm;
    
    SI3 = 3*Si;