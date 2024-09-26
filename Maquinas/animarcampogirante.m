% function animarcampogirante(nfases,defasagem,falha)
%
% Funcao que anima o campo girante para o numero de fases 'nfases'.
%
% O parametro 'defasagem' e opcional. Se nao incluir a defasagem eletrica e
% mecanica entre as fases e de 360º/nfases. Este parametro e utilizado
% principalmente para o caso bifasico, onde podem ser utilizados diferentes
% angulos de defasagem entre o enrolamento principal e o auxiliar.

% Feito por LGJ 03/2016 - Atualizado 11/2018
function animarcampogirante(nfases,defasagem,naofalha)

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

figure('position',[100 100 1000 500])
subplot(1,2,1)
axis equal;
axis([-2 2 -2 2])
grid;
title('Campo Girante')

% Angulos e correntes para 3 fases
angulos3 = (2*pi/3).*(0:(3-1));
fase3 = [sin(wt);sin(wt+2*pi/3);sin(wt+4*pi/3)];

% Angulos e correntes para n fases
angulos = defasagem.*(0:(nfases-1));
angulos = angulos(logical(naofalha));
% Criacao das correntes senoidais de N fases para o mesmo campo
[mat,mnf,m3] = transform3phase(nfases,naofalha);
fasen = mat*fase3;

hn = zeros(1,sum(naofalha));
% Criacao das correntes senoidais
% for k = 1:nfases
%     angulo(k) = (k-1)*defasagem;
%     fase(k,:) = sin(wt + angulo(k));
% 
%     h(k) = line([0 fase(k,:)*cos(angulo(k))],[0 fase(k,:)*sin(angulo(k))],'linewidth',2);
% 
%     xresultante = xresultante + fase(k,1)*cos(angulo(k));
%     yresultante = yresultante + fase(k,1)*sin(angulo(k));
% end

for k = 1:sum(naofalha)
%     fasen(k,:) = sin(wt + angulos(k));
    hn(k) = line([0 fasen(k,:)*cos(angulos(k))],[0 fasen(k,:)*sin(angulos(k))],'linewidth',2);
    
    xresultante = xresultante + fasen(k,1)*cos(angulos(k));
    yresultante = yresultante + fasen(k,1)*sin(angulos(k));
end

hres = line([0 xresultante],[0 yresultante],'color',[1 0 0]);
subplot(1,2,2)
plot(wt,fasen);
grid;
axis([0 max(wt) -1.5 1.5])
title('Correntes no tempo')
xlabel('\omega.t')

% animar as correntes no tempo
for tempo = 1:length(wt)
    xresultante = 0; yresultante = 0;
    % for k = 1:nfases
    %     set(h(k),'xdata',[0 fase(k,tempo)*cos(angulo(k))],...
    %         'ydata',[0 fase(k,tempo)*sin(angulo(k))]);
    % end
    for k = 1:sum(naofalha)
        set(hn(k),'xdata',[0 fasen(k,tempo)*cos(angulos(k))],...
            'ydata',[0 fasen(k,tempo)*sin(angulos(k))]);
%         xresultante = xresultante + fasen(k,tempo)*cos(angulos(k));
%         yresultante = yresultante + fasen(k,tempo)*sin(angulos(k));
    end

    xresultante = mnf(1,:)*fasen(:,tempo);
    yresultante = mnf(2,:)*fasen(:,tempo);
    set(hres,'xdata',[0 xresultante],...
            'ydata',[0 yresultante]);
    drawnow;
end