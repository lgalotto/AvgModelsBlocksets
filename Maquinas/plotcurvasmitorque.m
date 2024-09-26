function plotcurvasmitorque(MaquinaAssincrona,Vi,freq,Sini,Sfim) % Vi=0,f=0,S=0,wm=0
    if nargin < 2, Vi = 0; end
    if nargin < 3, freq = 0; end
    if nargin < 4, Sini = 0; end
    if nargin < 5, Sfim = 1; end
    
    S = linspace(Sini,Sfim,100);
    wm = zeros(100,1);
    Tu = zeros(100,1);
    Ilinha = zeros(100,1);
    Tmax = -1000;
    wmax = 0;
    ws = 2*pi*freq/(MaquinaAssincrona.polos/2);

    for k = 1:100
      [~, Ilinha(k), Tu(k), wm(k)] = calculomi(MaquinaAssincrona,Vi,freq,S(k));
      if Tu(k) > Tmax
        Tmax = Tu(k);
        wmax = wm(k);
      end
    end

    gcf;
    title('Curvas de Operação do MIT')
    ax = plotyy(wm,Tu,wm,abs(Ilinha));
    ylabel('Torque (Nm)','color',[0 0 1])
    xlabel('\omega_m (rad/s)')
    grid()
    %set(ax(2),'ylabel','Corrente de linha (A)')
    line([wmax wmax],get(gca,'ylim'),'color',[0 0 1],'linestyle','--')
    line([ws ws],get(gca,'ylim'),'color',[1 0 0],'linestyle','--')
    legend('Torque útil',['T_{max} = ', num2str(round(Tmax)), ' Nm'],'\omega_s','Corrente de linha(A)','location','Northwest')
    