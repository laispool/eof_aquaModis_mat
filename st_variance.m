
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Métodos matriciais aplicados à Oceanografia                   %%%%%
%%%%% Atividade avaliativa                                          %%%%%
%%%%% Laís Pool  (202003345)                                        %%%%%
%%%%% Florianopolis, 26/12/2022                                     %%%%%
%%%%% MATLAB R2021a                                                 %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Analisar saída de SVD                                         %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear 
clc

cd D:\Mestre_UFRGS\1_Aulas\Matlab\avaliacao4\Mica
load('v_regiao1.mat')
load('timeMensal_1')
time1 = decyear(timeMensal_1');
v1=v;
clear v 

load('v_regiao2.mat')
load('timeMensal_2')
time2 = decyear(timeMensal_2');
v2=v;
clear v 

%% plots V 1
figure (1)
residuo1 = [];
for modo=1:3
    subplot(3,1,modo)
    st1 = sqrt(length(time1))*v1(:,modo);
    plot(timeMensal_1,st1)
    grid
    title({['Série temporal - MODO ', num2str(modo)], 'Litoral Norte de Santa Catarina'})
    ylabel('Desvio padrão')
    xlabel('Ano')
    hold on
    A1 = [ones(length(time1),1) time1];
    x1 = A1\st1;
    plot(timeMensal_1',A1*x1,'k','DatetimeTickFormat','yyyy')

    residuo1(:, modo) = st1-A1*x1;
end
clear modo
legend('Variância EOF','Modelo linear ajustado','Orientation','vertical', ...
    'Position',[0.17 0.007 0.2 0.05],'EdgeColor','none')

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao01_linear', '-djpeg','-r300');

figure (2)
for modo=1:3
    subplot(3,1,modo)
    st1 = sqrt(length(timeMensal_1))*v1(:,modo);
    plot(timeMensal_1,st1)
    grid
    title({['Série temporal - MODO ', num2str(modo)], 'Litoral Norte de Santa Catarina'})
    ylabel('Desvio padrão')
    xlabel('Ano')
    hold on
    
    A1 = [ones(length(time1),1) sin(2*pi*time1) cos(2*pi*time1) ...
        sin(4*pi*time1) cos(4*pi*time1)];
    x1 = A1\residuo1(:,modo);
    plot(timeMensal_1',A1*x1,'k','DatetimeTickFormat','yyyy')
end
clear modo
legend('Variância EOF','Modelo senoidal ajustado','Orientation','vertical', ...
    'Position',[0.17 0.007 0.2 0.05],'EdgeColor','none')
set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao01_senoidal', '-djpeg','-r300');
%% plots V 2
figure (3)
residuo2 = [];
for modo=1:3
    subplot(3,1,modo)
    st2 = sqrt(length(timeMensal_2))*v2(:,modo);
    plot(timeMensal_2,st2)
    grid
    title({['Série temporal - MODO ', num2str(modo)], 'Desembocadura da Baía da Babitonga'})
    ylabel('Desvio padrão')
    xlabel('Ano')
    hold on
    A2 = [ones(length(time2),1) time2];
    x2 = A2\st2;
    plot(timeMensal_2',A2*x2,'k','DatetimeTickFormat','yyyy')
    
    residuo2(:, modo) = st2-A2*x2;
end
clear modo

legend('Variância EOF','Modelo linear ajustado','Orientation','vertical', ...
    'Position',[0.17 0.007 0.2 0.05],'EdgeColor','none')
set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_linear', '-djpeg','-r300');

figure (4)
for modo=1:3
    subplot(3,1,modo)
    st2 = sqrt(length(timeMensal_2))*v2(:,modo);
    plot(timeMensal_2,st2)
    grid
    title({['Série temporal - MODO ', num2str(modo)], 'Desembocadura da Baía da Babitonga'})
    ylabel('Desvio padrão')
    xlabel('Ano')
    hold on
    
    A2 = [ones(length(time2),1) sin(2*pi*time2) cos(2*pi*time2) ...
        sin(4*pi*time2) cos(4*pi*time2)];
    x2 = A2\residuo2(:,modo);
    plot(timeMensal_2,A2*x2,'k','DatetimeTickFormat','yyyy')
end
clear modo

legend('Variância EOF','Modelo senoidal ajustado','Orientation','vertical', ...
    'Position',[0.17 0.007 0.2 0.05],'EdgeColor','none')
set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_senoidal', '-djpeg','-r300');

%%