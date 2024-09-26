% function animartransformadas(nfases,defasagem,naofalha)
%
% Funcao que realiza uma animacao do campo girando para o numero diferente
% de fases 'nfases'.
%
% O parametro 'defasagem' e opcional. Se nao incluir a defasagem eletrica e
% mecanica entre as fases e de 360º/nfases. Este parametro e utilizado
% principalmente para o caso bifasico, onde podem ser utilizados diferentes
% angulos de defasagem entre o enrolamento principal e o auxiliar.

% Feito por LGJ 08/2016 - Atualizado 11/2018
function animartransformadas(nfases,defasagem,naofalha)

% inicialicacoes
wt = linspace(0,4*(2*pi),500);
xresultante = 0; yresultante = 0;

if nargin < 3
    naofalha = ones(1,nfases);
end
% Quando a defasagem entre as fases for uma entrada opcional.
if nargin < 2
    defasagem = (2*pi)/nfases;
end

if isempty(defasagem)
    defasagem = (2*pi)/nfases;
end 

figure('position',[100 100 1000 500],'color',[1 1 1])
subplot(2,2,1)
axis equal;
axis([-2 2 -2 2])
grid;
title('Campo Girante Trifasico Original')

angulos3 = (2*pi/3).*(0:(3-1));
fase3 = [sin(wt);sin(wt+2*pi/3);sin(wt+4*pi/3)];
h3 = [0,0,0];
% Criacao dos fasores senoidais
for k = 1:3    
    h3(k) = line([0 cos(angulos3(k))],[0 sin(angulos3(k))],'linewidth',2);
    
    xresultante = xresultante + cos(angulos3(k));
    yresultante = yresultante + sin(angulos3(k));
end
hres3 = line([0 xresultante],[0 yresultante],'color',[1 0 0]);

subplot(2,2,2)
plot(wt,fase3);
grid;
axis([0 max(wt) -1.5 1.5])
title('Correntes no tempo')
xlabel('\omega.t')

subplot(2,2,3)
axis equal;
axis([-2 2 -2 2])
grid;
title({['Campo Girante: ' num2str(nfases) ' fases'];['Fases sem falhas: ' num2str(naofalha)]})

angulos = defasagem.*(0:(nfases-1));
angulos = angulos(logical(naofalha));

% Criacao das correntes senoidais de N fases para o mesmo campo
[mat,mnf,m3] = transform3phase(nfases,naofalha);
fasen = mat*fase3;
xresultante = 0; yresultante = 0;
hn = zeros(1,sum(naofalha));
for k = 1:sum(naofalha)
%     fasen(k,:) = sin(wt + angulos(k));
    hn(k) = line([0 fasen(k,:)*cos(angulos(k))],[0 fasen(k,:)*sin(angulos(k))],'linewidth',2);
    
    xresultante = xresultante + fasen(k,1)*cos(angulos(k));
    yresultante = yresultante + fasen(k,1)*sin(angulos(k));
end
hresn = line([0 xresultante],[0 yresultante],'color',[1 0 0]);

subplot(2,2,4)
plot(wt,fasen);
grid;
axis([0 max(wt) -1.5 1.5])
title({['Correntes no tempo: ' num2str(nfases) ' fases'];['Fases sem falhas: ' num2str(naofalha)]})
xlabel('\omega.t')

% animar as correntes no tempo
for tempo = 1:length(wt)
    xresultante = 0; yresultante = 0;
    for k = 1:3
        set(h3(k),'xdata',[0 fase3(k,tempo)*cos(angulos3(k))],...
            'ydata',[0 fase3(k,tempo)*sin(angulos3(k))]);
        
        xresultante = xresultante + fase3(k,tempo)*cos(angulos3(k));
        yresultante = yresultante + fase3(k,tempo)*sin(angulos3(k));
    end
    % metodo alternativo para calcular Alfa e Beta
%     xresultante = m3(1,:)*fase3(:,tempo);
%     yresultante = m3(2,:)*fase3(:,tempo);
    
    set(hres3,'xdata',[0 xresultante],'ydata',[0 yresultante]);
    
%     xresultante = 0; yresultante = 0;
    for k = 1:sum(naofalha)
        set(hn(k),'xdata',[0 fasen(k,tempo)*cos(angulos(k))],...
            'ydata',[0 fasen(k,tempo)*sin(angulos(k))]);
        
%         xresultante = xresultante + fasen(k,tempo)*cos(angulos(k));
%         yresultante = yresultante + fasen(k,tempo)*sin(angulos(k));
    end
    xresultante = mnf(1,:)*fasen(:,tempo);
    yresultante = mnf(2,:)*fasen(:,tempo);
    set(hresn,'xdata',[0 xresultante],'ydata',[0 yresultante]);
    
    drawnow;
    
    % Gravar em gif
%     frame = getframe(1);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if tempo == 1;
%       imwrite(imind,cm,'TesteCampoGirante','gif', 'Loopcount',inf);
%     else
%       imwrite(imind,cm,'TesteCampoGirante','gif','WriteMode','append');
%     end
end