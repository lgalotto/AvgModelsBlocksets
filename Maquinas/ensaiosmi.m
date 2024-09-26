% function maquina = ensaiosmi(Voc, Ioc, Poc, Vbl, Ibl, Pbl, Rs, tipolig, freq, polos, S0,nfases)
%
% Funcao criada para retornar uma maquina assincrona a partir dos ensaios.
%
% Exemplo:
% modelo = ensaiosmi(173,1,30,17.3,5,30,0,1,60,4,0.001)

% Criado 05/2024 - LGJ 
function maquina = ensaiosmi(Voc, Ioc, Poc, Vbl, Ibl, Pbl, Rs, tipolig, freq, polos, S0, nfases)
    if nargin < 7, Rs = 0; end
    if nargin < 8, tipolig = 'Y'; end
    if nargin < 9, freq = 60; end
    if nargin < 10, polos = 4; end
    if nargin < 11, S0 = 0; end
    if nargin < 12, nfases = 3; end
    
    if tipolig == 1 % Estrela
      Vconv = 1/sqrt(3);
      Iconv = 1;
    else
      Vconv = 1;
      Iconv = sqrt(3);
    end

    [Xm,Rr,Rs,Xs,Xr] = ensaiosmiporfase(Voc*Vconv, Ioc*Iconv, Poc/3, Vbl*Vconv, Ibl*Iconv, Pbl/3, Rs);

    Pav = Poc - 3*Rs*((Ioc*Iconv).^2); %Pav = 3 * ((Voc*Vconv) ** 2)/(Rr*(1 - S0)/S0)
    ws = 2*pi*freq/(polos/2);
    wm = (1-S0)*ws;
    Dav = Pav/(wm^2);

    maquina = MaquinaAssincrona(Voc, freq, polos, sqrt(3)*Voc*Ioc, nfases, tipolig, Rs, Xs, Rr, Xr, Xm, Dav);