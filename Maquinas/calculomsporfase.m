function [Vfi,Ea,Is,Zs,Sele1f,Pmec1f] = calculomsporfase(Vfi,Ea,delta,Is,fi,Rs,Xs)
% [Vt,Ia,If,T,Ea,Zs,Dav,K,delta] = calculomaquinasCC(Vt,Ia,If,T,w,Zs,Dav,K,delta)
%
% Sendo:
% Vt - Tensao eficaz terminal de fase (V)
% Ia - Corrente eficaz de armadura de fase (A)
% If - Corrente de Campo (A)
% T  - Torque de carga no eixo (N.m)
% w  - Velocidade do eixo (rad/s)
% Zs - Impedância de armadura (Ohms)
% Dav- Coeficiente de atrito dinamico (correspondente ao atrito e a 
% ventialacao forcada.
% K  - Constante construtiva da maquina
% delta - Angulo de potencia
% 
% Retorna o resultado de uma maquina CC em regime permanente, definindo
% quaisquer 6 entradas das 8 nao opcionais.
% 
% Ao colocar a entrada vazia, a funcao retorna o resultado esperado para a
% variavel indefinida.
%
% Exemplos:

% Equacao do circuito
% real
% Vfi - Ea*cos(delta) == Is*Rs*cos(fi) - Is*Xs*sin(fi)
% imag
% 0 - Ea*sin(delta) == Is*Xs*cos(fi) + Is*Rs*sin(fi)

% LGJ - criado 06/2021
% if nargin < 9
%     delta = 0;
% end
% 
% if nargin < 8
%     K = [];
% end
% 
% if nargin < 7
%     Dav = [];
% end
% 
% if nargin < 6
%     Zs = [];
% end
% 
% if nargin < 5
%     w = [];
% end

% Metodo com o Symbolic

% Converter entradas indefinidas em symbolicas
numindef = 0;
respostas = '';
if isempty(Vfi)
    syms Vfi; numindef = numindef + 1;
    respostas = [respostas ',Vfi'];
end
if isempty(Ea)
    syms Ea; numindef = numindef + 1;
    assume(Ea,'positive')
    respostas = [respostas ',Ea'];
end
if isempty(delta)
    syms delta; numindef = numindef + 1;
    assume(delta,'real')
    respostas = [respostas ',delta'];
end
if isempty(Is)
    syms Is; numindef = numindef + 1;
    respostas = [respostas ',Is'];
end
if isempty(fi)
    syms fi; numindef = numindef + 1;
    assume(fi,'real')
    respostas = [respostas ',delta'];
end
if isempty(Rs)
    syms Rs; numindef = numindef + 1;
    respostas = [respostas ',Rs'];
end
if isempty(Xs)
    syms Xs; numindef = numindef + 1;
    respostas = [respostas ',Xs'];
end


if numindef >= 3
    error('Definir mais variaveis.');
end

% solucao das equacoes - Variavel dependendo das saidas desejadas
eval(['sol = solve(Vfi - Ea*cos(delta) == Is*Rs*cos(fi) - Is*Xs*sin(fi),- Ea*sin(delta) == Is*Xs*cos(fi) + Is*Rs*sin(fi)' respostas ');']);
% eval(['sol = solve(Ea == K*If*w*(cos(delta)+j*sin(delta)),real(Ea*conj(Ia))/w == T + Dav*w, real(Vt - Zs*Ia)==K*If*w*cos(delta), imag(Vt - Zs*Ia)==K*If*w*sin(delta)' respostas ');']);

% Conversao da solucao para numerico
try Vfi = sol.Vfi; Vfi = eval(Vfi); end
try Ea = sol.Ea; Ea = eval(Ea); end
try delta = sol.delta; delta = eval(delta); end
try Is = sol.Is; Is = eval(Is); end
try fi = sol.fi; fi = eval(fi); end
try Rs = sol.Rs; Rs = eval(Rs); end
try Xs = sol.Xs; Xs = eval(Xs); end

Ea = Ea*cos(delta) + j*Ea*sin(delta);
Zs = Rs + j*Xs;
Is = Is*cos(fi) + j*Is*sin(fi);

Sele1f = Vfi*Is';
Pmec1f = real(Ea*Is');