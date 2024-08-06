function [sys,x0,str,ts,simStateCompliance] = animarsuspensao(t,x,u,flag)
% Função que realiza a animação de um sistema de suspensão.
%
% Utilizada pelo simulink durante a simulação do exemplo_suspensao.mdl
%


%
% Modificado - LGJ 04/2018
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

% global estadosanimar;
%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 3;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
wt = linspace(0,6*2*pi,50); % desenho da mola
senoide = 0.3*sin(wt);

set(gcf,'color',[0 0 0],'position',[0 0 800 700]);
set(gca,'color',[0 0 0]);

x0 = [0 0 0];
linha  = [line([0 senoide 0 0.5 0.5 -0.5 -0.5 0],[0 wt./max(wt) 1 1 2 2 1 1],...
    'color',[1 1 1],'linewidth',3),...
    line(0,0,'color',[0 0.9 0.1],'linewidth',2),...
    line(0,3,'color',[1 0 0],'linewidth',2,'linestyle',':'),...
    line(0,0,'marker','.','markersize',30,'color',[1 0 0])];

axis([-6 2 -1 6])


%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

global estadosanimar;

sys = [];

linha = get(gca,'children'); % Localiza o handle da linha no gr�fico.
set(gca,'box','off','Visible','off'); % tornar eixos invis�veis.
set(gcf,'color',[0 0 0],'position',[0 0 800 700]);

% congelar os eixos
axis([-6 2 -1 6])

if isempty(linha) % se n�o existe linha
    wt = linspace(0,6*2*pi,50); % desenho da mola
    senoide = 0.3*sin(wt);

    linha  = [line([0 senoide 0 0.5 0.5 -0.5 -0.5 0],[0 wt./max(wt) 1 1 2 2 1 1],...
    'color',[1 1 1],'linewidth',3),...  % carro
    line(0,0,'color',[0 0.9 0.1],'linewidth',2),... % suspensao
    line(0,3,'color',[1 0 0],'linewidth',2,'linestyle',':'),... % linha
    line(0,0,'marker','.','markersize',30,'color',[1 0 0])];% roda
else
    wtnorm = linspace(0,1,50); 
    
    % atualizar carro
    set(linha(4),'ydata',[u(1) u(1)+(u(2)-u(1)).*wtnorm u(2)+[1 1 2 2 1 1]]);

    % suspensao
    xdados = get(linha(3),'xdata');
    ydados = get(linha(3),'ydata');
    set(linha(3),'xdata',[xdados-0.1 0],'ydata',[ydados u(1)])

    % Linha
    xdados_saida = get(linha(2),'xdata');
    ydados_saida = get(linha(2),'ydata');
    set(linha(2),'xdata',[xdados_saida-0.1 0],'ydata',[ydados_saida u(2)+1])

    % Roda
    set(linha(1),'ydata',u(1));

    drawnow;    
end


% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = [];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];
close;

% end mdlTerminate
