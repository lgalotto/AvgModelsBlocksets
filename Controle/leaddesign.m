% function Cs = leaddesign(Gs,Up,tau,metodo)
%
% Permite criar um controlador/compensador C(s) que faça a planta G(s)
% operar com Up e tau desejado.
% metodo pode ser 'rl' (padrao) ou 'bode'.
%
% Gs é a função de transferência G(s) criada com as funções do toolbox de
% controle.
% Cs é o compensador de resposta criado com o comando tf.
%
% Exemplo:
% 

% Criado em 20/10/2020 - LGJ - melhorado 08/2021
function Cs = leaddesign(Gs,Up,tau,metodo)

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
        Cs = leaddesignbode(Gs,wc,pm);
    case 'rl'
        Cs = leaddesignrlnise(Gs,s);
        
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

function Cs = leaddesignrlnise(Gs,s)
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
    Cs = zpk(Z,10*Z,1);
    [num,den]=tfdata(Cs*Gs);
    
    modulo = abs(polyval(num{1},s)/polyval(den{1},s));
       
    Cs = zpk(Z,10*Z,1/modulo);


function Cs = leaddesignbode(Gs,wc,pm)

x = frd(Gs,wc);

fimax = (pm-180)-angle(x.Response)*180/pi;

% passo 1 - selecionar beta
beta = (1-sind(fimax))./(1+sind(fimax));

% passo 2 - encontrar a posicao dos polos e zeros.
T = 1/(wc*sqrt(beta));

% passo 3 - encontrar o ganho
Kc = sqrt(beta)/abs(x.Response);

% formato da C(s) considerado
Cs = tf(Kc*[T 1],[beta*T 1]);