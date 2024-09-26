% [SI3, Ilinha, Tu, wm, Perdaseletricas, Perdasav] = simmiblock(tensao, frequencia, polos, potencia, nfases, tipolig, rs,xs,rr,xr,xm,dav,Vi,f,S,wm)
function simmiblock(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.

%   Copyright 2003-2018 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C MEX counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 16;
block.NumOutputPorts = 5;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';

% Register parameters
block.NumDialogPrms     = 1;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate);

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C MEX counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'x1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;


%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C MEX counterpart: mdlStart
%%
function Start(block)

block.Dwork(1).Data = 0;

%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C MEX counterpart: mdlOutputs
%%
function Outputs(block)

%block.OutputPort(1).Data = block.Dwork(1).Data + block.InputPort(1).Data;
%for k = 1:block.NumOutputPorts
%    block.OutputPort(k).Data = block.Dwork(k).Data;
%end

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlUpdate
%%
function Update(block)

%block.Dwork(1).Data = block.InputPort(1).Data;

%Parametros = get(block.BlockHandle,'Parameters');
%dados = str2num(Parametros);

tensao = block.InputPort(1).Data;
frequencia = block.InputPort(2).Data;
polos = block.InputPort(3).Data;
potencia = block.InputPort(4).Data;
nfases = block.InputPort(5).Data;
tipolig = block.InputPort(6).Data;
rs = block.InputPort(7).Data;
xs = block.InputPort(8).Data;
rr = block.InputPort(9).Data;
xr = block.InputPort(10).Data;
xm = block.InputPort(11).Data;
dav = block.InputPort(12).Data;

modelo = MaquinaAssincrona(tensao, frequencia, polos, potencia, nfases, tipolig, rs,xs,rr,xr,xm,dav);

vi = block.InputPort(13).Data;
f = block.InputPort(14).Data;
wm = block.InputPort(15).Data;

[SI3, Ilinha, Tu, ~, Perdaseletricas, Perdasav] = calculomi(modelo,vi,f,1,wm);

 block.OutputPort(1).Data = SI3;
 block.OutputPort(2).Data = Ilinha;
 block.OutputPort(3).Data = Tu;
 block.OutputPort(4).Data = Perdaseletricas;
 block.OutputPort(5).Data = Perdasav;

%Parametros = get(block.BlockHandle,'Parameters');
Parametros = block.InputPort(16).Data;
if Parametros % se verdadeiro

    Svet = linspace(-0.5,1.5,100);
    % Curva de torque atual
    [~, ~, Tuvet] = calculomi(modelo,vi,f,Svet);
        
    gcf();
    linha = get(gca,'Children');
    if isempty(linha) % inicializar
        set(gcf,'position',[0 0 800 700]);
        
        ylim = get(gca,'ylim');
        line([0],[Tu],'color',[1 0 0],'linewidth',3,'marker','o','markersize',12);
        line([0 0],ylim,'color',[0 0 0],'linewidth',3,'linestyle',':');
        line((1-Svet)*(4*pi*60/modelo.polos),Tuvet,'color',[0 0 1],'linewidth',1,'linestyle','-');
        
        grid on;
        ylabel('Torque (Nm)','color',[0 0 1])
        xlabel('\omega_m (rad/s)')

        %subplot(2,1,2)
        %estadosanimar(4) = line(0,0,'color',[1 0 0],'linewidth',3,'linestyle','-');
        %ylabel('Corrente de linha (A)','color',[1 0 0])
        %xlabel('Tempo')

        %grid on;
        %set(gca,'box','on')
        %axis([0 8 0 inf])

    else
        % Curva de Torque Nominal
        set(linha(3),'xdata',wm,'ydata',Tu);
    
        % Operacao
        ylim = get(gca,'ylim');
        set(linha(2),'xdata',wm.*[1 1],'ydata',ylim);
        
        set(linha(1),'xdata',(1-Svet)*(4*pi*f/modelo.polos),'ydata',Tuvet);
        
        % Grafico da corrente
        %tvet = get(linha(4),'xdata');
        %Ivet = get(linha(4),'ydata');
        %set(linha(4),'xdata',[tvet, t],'ydata',[Ivet, abs(Ilinha)]);
        
        % Corrente no tempo
    end
    drawnow;
end

%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlDerivatives
%%
function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : No
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate