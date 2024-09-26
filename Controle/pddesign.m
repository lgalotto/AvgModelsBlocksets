% function Cs = pddesign(Gs,Up,tau,metodo)
%
% Gs é a função de transferência G(s) criada com as funções do toolbox de
% controle.
% Cs é o compensador de resposta criado com o comando tf.
%
% Up  - ultrapassagem desejada. 
% tau - constante de tempo desejada.
% metodo - metodo de projeto, pode ser 'bode', 'rl'.
% 
%
% Exemplo:
% 
%  Gs = tf([0.1],[1 1 0])
%  Cs = pddesign(Gs,0.1,1,'rl')
%  % resultado grafico
%  pddesign(Gs,0.1,1,'rl');

% Criado em 08/11/2020 - LGJ - melhorado - 08/2021
function Cs = pddesign(Gs,Up,tau,metodo)
% function Cs = pddesign(Gs,wc,pm) % versao antiga

if nargin <= 3
    metodo = 'rl';
end
if nargin <= 2
    tau = 1/min(abs(pole));
end
if nargin == 1
    Up = 0.01;
end

if Up < 0,
    Up = 0;
    warning('Nao exite overshoot negativo. Considerado zero.')
end

Ts = 4*tau;
s = calcs(Up,Ts);

switch metodo
    case 'bode'
        [wc,pm] = s2openbode(s);
        Cs = pddesignbode(Gs,wc,pm);
    case 'rl'
        Cs = pddesignrlnise(Gs,s);
        
        if nargout == 0
            gcf;
            subplot(1,2,1)
            rlocus(Gs,Gs*Cs);
            line(real(s),imag(s),'marker','*','markersize',14)
            subplot(1,2,2)
            step(feedback(Gs,1),feedback(Gs*Cs,1));
            line(get(gca,'xlim'),[1 1].*(1+Up),'color',[0 0.5 0],'linestyle','--');
            line([pi pi]./abs(imag(s)),get(gca,'ylim'),'color',[0 0.5 0],'linestyle','--');
        end
    otherwise
        error('Metodo indisponível. Veja o help.')
end

function Cs = pddesignrlnise(Gs,s)
    polos = pole(Gs);
    zeros = zero(Gs);
    
    % regra dos angulos
    angulo = 0;
    for k = 1:length(polos)
        angulo = angulo - angle(s - polos(k));
    end
    for k = 1:length(zeros)
        angulo = angulo + angle(s - zeros(k));
    end
    
    if imag(s) ~= 0
        Z = real(s) - imag(s)/tan(-pi-angulo);
    else
        if -pi-angulo == 0
            Z = 2*real(s);
        else
            Z = real(s)/2;
        end
    end
    if Z >= 0
        Z = [];
        warning('Zero inadequado para o requisito.')
    end
    if isinf(Z)
        Z = [];
        warning('Zero desnecessario para o requisito.')
    end
    
    % regra dos modulos
    Cs = zpk(Z,[],1);
    [num,den]=tfdata(Cs*Gs);
    
    modulo = abs(polyval(num{1},s)/polyval(den{1},s));
       
    Cs = zpk(Z,[],1/modulo);
    
    


function Cs = pddesignbode(Gs,wc,pm)
% Permite criar um controlador/compensador C(s) = K(s+a) que faça a planta G(s)
% operar na frequencia de cruzamento (wc) desejada e com a margem de fase
% (pm) desejada.

x = frd(Gs,wc);

fimax = (-180+pm) - angle(x.Response)*180/pi;

if fimax > 0
    % encontrando o zero do pd
    a = wc./(tand(fimax));

    % Ajustando o ganho do pd
    Kc = 1/(abs(x.Response)*sqrt(wc.^2 + a.^2));
    
    % formato da C(s) considerado
    Cs = zpk([-a],[],Kc);
else
    Cs = zpk([],[],1/(abs(x.Response)));
end