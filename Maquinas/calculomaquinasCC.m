function [Vt,Ia,If,T,w,Ra,Dav,K] = calculomaquinasCC(Vt,Ia,If,T,w,Ra,Dav,K,DV,alpha)
% [Vt,Ia,If,T,w,Ra,Dav,K] = calculomaquinasCC(Vt,Ia,If,T,w,Ra,Dav,K,DV,alpha)
%
% Sendo:
% Vt - Tensao terminal (V)
% Ia - Corrente de armadura (A)
% If - Corrente de Campo (A)
% T  - Torque de carga no eixo (N.m)
% w  - Velocidade do eixo (rad/s)
% Ra - Resistencia equivalente de armadura (Ohms)
% Dav- Coeficiente de atrito dinamico (correspondente ao atrito e a�
% ventialacao forcada.
% K  - Constante construtiva da maquina
% DV - Queda de tensao nas escovas (opcional - padrao 0 V)
% alpha - Rela��o de refor�o ou enfraquecimento de campo com a corrente armadura
% 
% Retorna o resultado de uma maquina CC em regime permanente, definindo
% quaisquer 6 entradas das 8 nao opcionais.
% 
% Ao colocar a entrada vazia, a funcao retorna o resultado esperado para a
% variavel indefinida.
%
% Exemplos:
%   % Calculo do atrito e da constante da maquina 
%   % a partir de um ensaio a vazio
%   [Vt,Ia,If,T,w,Ra,Dav,K] = calculomaquinasCC(100,10,1,0,1800*pi/30,0.1,[],[])
%
%   % Calculo da carga e velocidade
%   [Vt,Ia,If,T,w,Ra,Dav,K] = calculomaquinasCC(100,20,1,[],[],0.1,0.01,0.5)


% LGJ 04/2019
% atualizado 03/2020
if nargin < 10
    alpha = 0; % Padrao - motor CC shunt
end

if nargin < 9
    DV = 0;
end

if nargin < 8
    K = [];
end

if nargin < 7
    Dav = [];
end

if nargin < 6
    Ra = [];
end

if nargin < 5
    w = [];
end

% Metodo com o Symbolic

% Converter entradas indefinidas em symbolicas
numindef = 0;
respostas = '';
if isempty(Vt)
    syms Vt; numindef = numindef + 1;
    respostas = [respostas ',Vt'];
end
if isempty(Ia)
    syms Ia; numindef = numindef + 1;
    respostas = [respostas ',Ia'];
end
if isempty(If)
    syms If; numindef = numindef + 1;
    respostas = [respostas ',If'];
end
if isempty(T)
    syms T; numindef = numindef + 1;
    respostas = [respostas ',T'];
end
if isempty(w)
    syms w; numindef = numindef + 1;
    respostas = [respostas ',w'];
end
if isempty(Ra)
    syms Ra; numindef = numindef + 1;
    respostas = [respostas ',Ra'];
end
if isempty(K)
    syms K; numindef = numindef + 1;
    respostas = [respostas ',K'];
end
if isempty(Dav)
    syms Dav; numindef = numindef + 1;
    respostas = [respostas ',Dav'];
end
if isempty(alpha)
    syms alpha; numindef = numindef + 1;
    respostas = [respostas ',alpha'];
end
if numindef >= 3
    error('Definir mais variaveis.');
end

% solucao das equacoes - Variavel dependendo das saidas desejadas
eval(['sol = solve(K*(If + alpha*Ia)*Ia == T + Dav*w, Vt - Ra*Ia==K*(If + alpha*Ia)*w' respostas ');']);

% Conversao da solucao para numerico
try Vt = sol.Vt; Vt = eval(Vt); end
try Ia = sol.Ia; Ia = eval(Ia); end
try If = sol.If; If = eval(If); end
try T = sol.T; T = eval(T); end
try w = sol.w; w = eval(w); end
try Ra = sol.Ra; Ra = eval(Ra); end
try Dav = sol.Dav; Dav = eval(Dav); end
try K = sol.K; K = eval(K); end

% Metodo Antigo
% if isempty(Ia) && isempty(If) % Variáveis comuns nas duas equações
%     IaIf = (T + Dav*w)/(K);
%     Ia = min(roots([Ra -(Vt-DV) K*IaIf*w]));
%     If = IaIf/Ia;
%     
%     if isempty(Ia)
%     	error('Dados insuficientes');
%     end
% end
% 
% if isempty(Ia) && isempty(K) % Variáveis comuns nas duas equações
%     IaK = (T + Dav*w)/(If);
%     Ia = min(roots([Ra -(Vt-DV)  IaK*If*w]));
%     K = IaK/Ia;
%     
%     if isempty(Ia)
%     	error('Dados insuficientes');
%     end
% end
% 
% if isempty(If) && isempty(K) % Variáveis comuns nas duas equações
%     K = (T + Dav*w)/(Ia);
%     
%     warning('O If permanece vazio. Valor embutido na constante K!');
%     
%     if isempty(K)
%     	error('Dados insuficientes');
%     end
% end
% 
% if isempty(Ia)
%     Ia = (T + Dav*w)/(K*If);
%     if isempty(Ia)
%         Ia = (Vt - K*If*w - DV)/Ra;
%         if isempty(Ia)
%             error('Dados insuficientes');
%         end
%     end
% end
% 
% if isempty(If)
%     If = (T + Dav*w)/(K*Ia);
%     if isempty(If)
%         If = (Vt - Ra*Ia - DV)/(K*w);
%         if isempty(If)
%             error('Dados insuficientes');
%         end
%     end
% end
% 
% if isempty(w)
%     w = -(T - K*If*Ia)/(Dav);
%     if isempty(w)
%         w = (Vt - Ra*Ia - DV)/(K*If);
%         if isempty(If)
%             error('Dados insuficientes');
%         end
%     end
% end
% 
% if isempty(K)
%     K = (T + Dav*w)/(If*Ia);
%     if isempty(K)
%         K = (Vt - Ra*Ia - DV)/(If*w);
%         if isempty(K)
%             error('Dados insuficientes');
%         end
%     end
% end
%     
% if isempty(Vt)
%     Vt = K*If*w + Ra*Ia + DV;
%     if isempty(Vt)
%         error('Dados insuficientes');
%     end
% end
% 
% if isempty(T)
%     T = K*If*Ia - Dav*w;
%     if isempty(T)
%         error('Dados insuficientes');
%     end
% end
% 
% if isempty(Ra)
%     Ra = (Vt - DV - K*If*w)/Ia;
%     if isempty(Ra)
%         error('Dados insuficientes');
%     end
% end
% 
% if isempty(Dav)
%     Dav = -(T - K*If*Ia)/w;
%     if isempty(Dav)
%         error('Dados insuficientes');
%     end
% end
