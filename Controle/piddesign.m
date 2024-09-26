% function Cs = piddesign(Gs,Up,tau,erro,tipo,metodo)
%
% Gs é a função de transferência G(s) criada com as funções do toolbox de
% controle.
% Cs é o compensador PID de resposta criado com o comando tf.
%
% Up  - ultrapassagem desejada. 
% tau - constante de tempo desejada.
% metodo - metodo de projeto, pode ser 'bode', 'rl', 'ga'.
% erro - valor positivo de erro aceitavel
% tipo - 'degrau', 'rampa' ou 'parabola'
%
% Exemplo:
% 
%  Gs = tf([0.1],[1 1])
%  piddesign(Gs,0.1,1) % padrao erro 0 ao degrau
%  
%  Gs = tf([10],[1 1 0])
%  piddesign(Gs,0.1,1,0,'rampa') % padrao metodo root locus

% LGJ - melhorado - 08/2021 - atualizado 08/2022
function Cs = piddesign(Gs,Up,tau,erro,tipo,metodo)

if nargin < 6
    metodo = 'pidconv';
end
if nargin < 5
    tipo = 'degrau';
end
if nargin < 4
    erro = 0;
end

switch metodo
    case 'ga'
        x = ga(@(x)pidfeedbacktest(x,Gs,Up,4*tau),3);
        
        Cs = zpk([x(2) x(3)],0,x(1));
    case 'pidconv'
        PI = pidesign(Gs,erro,tipo,'nise');
        PD = pddesign(PI*Gs,Up,tau,'rl');
        
        Cs = tf(PD*PI);
    case 'pidfilt'
        PI = pidesign(Gs,erro,tipo,'nise');
        lead = leaddesign(PI*Gs,Up,tau,'rl');
        
        Cs = tf(lead*PI);
    otherwise
        PI = pidesign(Gs,erro,tipo,'dominante');
        PD = pddesign(PI*Gs,Up,tau,'rl');
        
        Cs = tf(PD*PI);
end

% resposta grafica
if nargout == 0
    Ts = 4*tau;
    sprojeto = calcs(Up,Ts);
    gcf;
    subplot(1,2,1)
    rlocus(Gs,Gs*Cs);
    line(real(sprojeto),imag(sprojeto),'marker','*','markersize',14)
    
    subplot(1,2,2)
    switch tipo
        case 'degrau'
            [yc,t] = step(feedback(Gs*Cs,1));
            [yini] = step(feedback(Gs,1),t);
            plot(t,yc,'b'); axis manual;
            line(t,yini,'color',[1 0 0],'linestyle',':');
            line(get(gca,'xlim'),[1 1].*(1-erro),'color',[0 0.5 0],'linestyle','--');
            line(get(gca,'xlim'),[1 1].*(1+Up),'color',[0 0.5 0],'linestyle','--');
            line([pi pi]./abs(imag(sprojeto)),get(gca,'ylim'),'color',[0 0.5 0],'linestyle','--');
        case 'rampa'
            t = linspace(0,-10/real(sprojeto),100);
            lsim(feedback(Gs,1),feedback(Gs*Cs,1),t,t);
            line(get(gca,'xlim'),get(gca,'ylim')-erro,'color',[0 0.5 0],'linestyle','--');
        case 'parabola'
            t = linspace(0,-10/real(sprojeto),20);
            u = t.^2;
            lsim(feedback(Gs,1),feedback(Gs*Cs,1),u,t);
            line(t,u-erro,'color',[0 0.5 0],'linestyle','--');
    end
end