% function Cs = pidesign(Gs,erro,tipo,metodo)
%
% Gs é a função de transferência G(s) criada com as funções do toolbox de
% controle.
% Cs é o compensador P ou PI de resposta criado com o comando tf.
%
% erro - valor positivo de erro aceitavel
% tipo - 'degrau', 'rampa' ou 'parabola'
% metodo - 'dominante' (exclui polo dominante), 'nise' (1/10 do polo dominante)
%
% Cs = Kp(s+z)/s 
%
% Exemplo:
%     Gs = tf([0.1],[1 1]);
%     pidesign(10*Gs,0,'degrau')

% Criado em 08/2021 - LGJ - Atualizado 08/2022
function Cs = pidesign(Gs,erro,tipo,metodo)

if nargin <= 3
    metodo = 'nise';
end

if nargin <= 2
    tipo = 'degrau'; % padrao
end

switch tipo
    case 'degrau'
        Kdesejado = 1/erro - 1;
        ordem = 0;
    case 'rampa'
        Kdesejado = 1/erro;
        ordem = 1;
    case 'parabola'
        Kdesejado = 1/erro;
        ordem = 2;
    otherwise
        error('Entrada indisponivel.')
end

% encontrar ponto de operacao anterior
Ts = feedback(Gs,1);
polos = pole(Ts);
[~,ind] = max(real(polos));
sprojeto = polos(ind);

switch metodo
    case 'nise'
        s = tf('s');
        x = frd(tf(Gs*s^ordem),0);
        if isinf(abs(x.Response)) % tipo superior
            Cs = 1;
            warning('O sistema atende o requisito sem o PI.')
        elseif abs(x.Response) ~= 0 && ~isinf(Kdesejado) % tipo suficiente
            Cs = Kdesejado/abs(x.Response);
            warning('Atende o requisito sem o PI, mas alterando o transitorio.')
        else
            polos = pole(Gs*s^ordem);
            ind = find(real(polos)<0,1,'first');
            Z = real(polos(ind))/10;


            % regra dos modulos
            Cs = zpk(Z,0,abs(sprojeto/(sprojeto-Z)));

            % verificacao
            x = frd(tf(Cs*Gs*s^ordem),0);
            if abs(x.Response) < Kdesejado
                warning('Um PI ainda nao atende ao requisito.')
            end
        end
    case 'dominante'
        s = tf('s');
        x = frd(tf(Gs*s^ordem),0);
        if isinf(abs(x.Response)) % tipo superior
            Cs = 1;
            warning('O sistema atende o requisito sem o PI.')
        elseif abs(x.Response) ~= 0 && ~isinf(Kdesejado) % tipo suficiente
            Cs = Kdesejado/abs(x.Response);
            warning('O sistema atende o requisito sem o PI.')
        else
            polos = pole(Gs*s^ordem);
            ind = find(real(polos)<0,1,'first');
            Z = real(polos(ind));
            Cs = zpk(Z,0,0.5*abs(sprojeto/(sprojeto-Z)));
        end
    otherwise
        error('Metodo indisponivel');
end
        


if nargout == 0
    gcf;
    subplot(1,2,1)
    rlocus(Gs,Gs*Cs);
    
    poloscompensados = pole(feedback(Gs*Cs,1));
    
    line(real(sprojeto),imag(sprojeto),'marker','square','markersize',14,'linestyle','none')
    
    line(real(poloscompensados),imag(poloscompensados),'marker','square','markersize',14,'color',[1 0 0],'linestyle','none')
    
    subplot(1,2,2)
    switch tipo
        case 'degrau'
            step(feedback(Gs,1),feedback(Gs*Cs,1));
            line(get(gca,'xlim'),[1 1].*(1-erro),'color',[0 0.5 0],'linestyle','--');
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
            
            