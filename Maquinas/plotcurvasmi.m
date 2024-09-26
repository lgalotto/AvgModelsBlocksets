
function plotcurvasmi(MaquinaAssincrona,Vi,freq,Sini,Sfim) % Vi=0,f=0,S=0,wm=0
    if nargin < 2, Vi = 0; end
    if nargin < 3, freq = 0; end
    if nargin < 4, Sini = 0; end
    if nargin < 5, Sfim = 1; end
    
    S = linspace(Sini,Sfim,100);
    Pi = zeros(100,1);
    wm = zeros(100,1);
    Perdaseletricas = zeros(100,1);
    Perdasav = zeros(100,1);
    Pu = zeros(100,1);
    fp = zeros(100,1);
    nu = zeros(100,1);
    Tu = zeros(100,1);
    Tmec = zeros(100,1);
    Tmax = -1000;
    wmax = 0;
    ws = 2*pi*freq/(MaquinaAssincrona.polos/2);

    for k = 1:100
      [Si, ~, Tu(k), wm(k), Perdaseletricas(k), Perdasav(k)] = calculomi(MaquinaAssincrona,Vi,freq,S(k));
      Pi(k) = real(Si);
      fp(k) = Pi(k)/abs(Si);
      Pu(k) = Tu(k)*wm(k);
      if Pi(k) > 1
        nu(k) = 1 - (Perdaseletricas(k) + Perdasav(k))/Pi(k);
      elseif Pu(k) < -1
        nu(k) = 1 - (Perdaseletricas(k) + Perdasav(k))/(-Pu(k));
      else
        nu(k) = 0;
      end
      if abs(wm(k)) > 1
        Tmec(k) = Tu(k) + (Perdasav(k))/wm(k);
      else
        Tmec(k) = Tu(k);
      end
      if Tu(k) > Tmax
        Tmax = Tu(k);
        wmax = wm(k);
      end
    end

    gcf;
    subplot(3,1,1)
    plot(wm,Pi); hold on;
    plot(wm,Perdasav);
    plot(wm,Perdaseletricas)
    plot(wm,Pu)
    title('Operação do MIT')
    ylabel('Potências (W)')
    grid;
    line([ws ws],get(gca,'ylim'),'color',[1 0 0],'linestyle','--')
    legend('Entrada','Perdas A.V.','Perdas Elétricas','Potência Útil','\omega_s','location','Northwest')

    subplot(3,1,2)
    plot(wm,nu); hold on;
    plot(wm,fp)
    grid()
    line([ws ws],get(gca,'ylim'),'color',[1 0 0],'linestyle','--')
    legend('Eficiência','Fator de Potência','\omega_s','location','Northwest')

    subplot(3,1,3)
    plot(wm,Tu); hold on;
    plot(wm,Tmec)
    ylabel('Torque (Nm)')
    xlabel('\omega_m (rad/s)')
    grid()
    line([wmax wmax],get(gca,'ylim'),'color',[0 0 1],'linestyle','--')
    line([ws ws],get(gca,'ylim'),'color',[1 0 0],'linestyle','--')
    legend('Torque útil','Torque induzido',['T_{max} = ', num2str(round(Tmax)), ' Nm'],'\omega_s','location','Northwest')