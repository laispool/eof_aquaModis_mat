%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Métodos matriciais aplicados à Oceanografia                   %%%%%
%%%%% Atividade avaliativa                                          %%%%%
%%%%% Laís Pool  (202003345)                                        %%%%%
%%%%% Florianopolis, 17/12/2022                                     %%%%%
%%%%% MATLAB R2021a                                                 %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Analisar o material particulado em suspensão através da       %%%%%
%%%%% refletância dos pixels - Baía da Babitonga/ Canal do Linguado %%%%%
%%%%% dados: Ocean Color em .nc                                     %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all %fecha todas as imagens
clear all %exclui todas as variaveis
clc %limpa o command window

cd('D:\Mestre_UFRGS\1_Aulas\Matlab\avaliacao4\requested_files') %diretorio dos arquivos
listArchives = dir('AQUA_MODIS.*.L3m.DAY.RRS.x_Rrs_555.nc'); %lista os arquivos dentro do diretorio

rrs_555 = []; %prealoca a matrix de reflectancia
cont_nan = []; %prealoca o vetor para contagem de nans
time = []; %prealoca a variavel de time
for i = 1:length(listArchives) %iterador para cada arquivo
    disp(['Concatenando Imagens: ' num2str(round(i * 100 / length(listArchives),1)) '%']) %dispara informacao da porcentagem do processamento
    x = double(ncread(listArchives(i).name,'Rrs_555')); %importa os dados de reflectancia
    x = x'; %transpoem a matrix x para deixar posicionada corretamente entre latitude e longitude
    x = x(:); %extende a matrix de reflectancia em um vetor
    y = sum(isnan(x)); %conta os nans presentes em cada mapa de reflectancia
    if y <= length(x)*0.8;
        rrs_555 = cat(2,rrs_555,x); %concatena os vetores de reflectancia para formar uma matrix de mapas x tempo
        cont_nan = cat(2,cont_nan,y); %concatena o contador de nans
        z = ncinfo(listArchives(i).name); %import a informacao de tempo
        z = datevec(z.Attributes(12).Value,'YYYY-mm-ddTHH:MM:SS.FFFZ'); %transforma time string em time vetor
        time = cat(2,time,datetime(z(1:3))); %concatena em um vetor o tempo em formato datetime
    end
end

nlat = double(ncread(listArchives(i).name,'lat')); %importa os dados de latitude em formato double
nlon = double(ncread(listArchives(i).name,'lon')); %importa os dados de longitude em formato double
[LON,LAT] = meshgrid(nlon,nlat); %cria as matrizes de longitude e latitude
sizeMatrix = size(LON); %determina o tamanho das matrizes originais de latitude, longitude e reflectancia
lon = LON(:); %extende a matrix de longitude em um vetor
lat = LAT(:); %extende a matrix de latitude em um vetor

clear x y z LON LAT i listArchives %elimina as variaveis auxiliares

%%
% Plot de mapa diário com maior numero de nans

f1 = figure; 
f1.Position = [10 10 600 600];

rrs_555_maior_nans_diarios = rrs_555(:,cont_nan == max(cont_nan)); %encontras os dias com maior numero de nans dentre os dados diarios
mapa = reshape(rrs_555_maior_nans_diarios(:,1),sizeMatrix); %cria o mapa para os dados com maior numero de nans

cc = linspace(min(mapa(:)),max(mapa(:)),10); %cria os limites do colormap

m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]);
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa,cc,'edgecolor','none');
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS','Dado diário registrado com maior numero de Nans'});
ylabel('latitude')
xlabel('longitude')

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_maiorNumeroNansDiario', '-djpeg','-r300'); %salva figura


%%
% Calculo das medias mensais

rrs_555_mensal = []; %prealoca nova variavel de dados mensais
timevec = datevec(time); %cria uma variavel de tempo em formato datevec
years = unique(timevec(:,1)); %cria variaveis com os anos de abrangencia dos dados
for i = 1:length(years) %loop para iterar entre os anos da serie temporal usada
    for j = 1:12 %loop para iterar entre os meses do ano
        id = years(i) == timevec(:,1) & j == timevec(:,2); %cria um vetor boileano para identificar os dados que pertencem ao mes e ano das iteracoes
        x = nanmean(rrs_555(:,id),2); %calcula a media dos dados que pertencem ao mes e ano das iteracoes
        rrs_555_mensal = cat(2,rrs_555_mensal,x); %concatena os dados para formar uma matrix de dados mensais
    end
end
timeMensal = (datetime(years(1),1,1):calmonths:datetime(years(end),12,1)); %cria o vetor temporal com dt mensal
id_elimina_mes_sem_dados = sum(isnan(rrs_555_mensal),1) ~= size(rrs_555_mensal,1); %vetor boileano que identifica passos de tempos que nao sao compostos em sua totalidade por nans
timeMensal = timeMensal(id_elimina_mes_sem_dados); %encontra apenas os meses com fazem parte da serie temporal dos dados
rrs_555_mensal = rrs_555_mensal(:,id_elimina_mes_sem_dados);  %elimina meses que são compostos em sua totalidade por nans


%%
% Plot de mapa mensal com maior numero de nans

f2 = figure;
f2.Position = [10 10 600 600];

cont_nan = sum(isnan(rrs_555_mensal),1); %encontras os meses com maior numero de nans dentre os dados mensais
mapa = reshape(rrs_555_mensal(:,cont_nan == max(cont_nan)),sizeMatrix); %cria o mapa para os dados com maior numero de nans

cc = linspace(min(mapa(:)),max(mapa(:)),10); %cria os limites do colormap

m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]); 
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa,cc,'edgecolor','none');
shading interp
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS','Dado mensal registrado com maior numero de Nans'});
ylabel('latitude')
xlabel('longitude')

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_maiorNumeroNansMensal', '-djpeg','-r300');


%%
% Interpolacao para remocao de nans

rrs_555_interp_mensal = []; %prealoca a variavel que recebera os dados interpolados
for i = 1:size(rrs_555_mensal,1) %iterador entre as coordenadas da matriz
    disp(['Interpolando: ' num2str(round(i * 100 / size(rrs_555_mensal,1),1)) '%']) %dispara informacao da porcentagem do processamento
    id = ~isnan(rrs_555_mensal(i,:)); %vetor boileano para identificar dados nao nans dentro da serie temporal de cada coordenada
    if sum(id) > length(id)*0.8 %condicional para numero de nans presente dentro de cada coordenada (neste caso 80% da serie eh completa por nao nans)
        x = rrs_555_mensal(i,id); %variavel com apenas dados nao nans de cada coordenada
        timex = timeMensal(id); %variavel de tempo com apenas tempo nao nans de cada coordenada   
        x_interp = interp1(timex,x,timeMensal,'linear','extrap'); %interpolacao de dados de cada coordenada ao longo da serie temporal
        rrs_555_interp_mensal = cat(1,rrs_555_interp_mensal,x_interp); %concatena os vetores interpolados para criacao de uma matrix de dados interpolados
    else %caso generico para caso os numero de nans dentro da coordenada ultrapasse o limite estipulado no if anterior
        x = nan(size(rrs_555_mensal(i,:))); %cria um vetor de nans com o tamanho da serie temporal
        rrs_555_interp_mensal = cat(1,rrs_555_interp_mensal,x); %substitui o vetor da coordenada com muitos nans para um vetor de nans completo
    end
end

id = ~isnan(rrs_555_interp_mensal);
rrs_555_interp_semNan = rrs_555_interp_mensal(id);
rrs_555_interp_semNan = reshape(rrs_555_interp_semNan,[],[length(timeMensal)]);


%%
% Plot de mapa mensal com maior numero de nans

f3 = figure;
f3.Position = [10 10 600 600];

mapa = reshape(nanmean(rrs_555_mensal,2),sizeMatrix); %calcula o dados medio para todo periodo analisado

cc = linspace(min(mapa(:)),max(mapa(:)),10); %cria os limites do colormap

m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]); 
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa,cc,'edgecolor','none');
shading interp
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS','Dado médio de 2002 a 2022'});
ylabel('latitude')
xlabel('longitude')

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_media2002a2022', '-djpeg','-r300');


%%
% Calculo de Anomalia

rrs_555_interp_semNan_media = mean(rrs_555_interp_semNan,2); %encontra as médias das series temporais de cada coordenada
anomalia_rrs_555 = rrs_555_interp_semNan - rrs_555_interp_semNan_media; %subtrai a media dos dados encontrando a anomalia dos dados


%%
% Aplicando EOF

[u,s,v] = svd(anomalia_rrs_555,0); %aplico EOF nos dados de anomalia

mapaNan = nan(size(rrs_555_interp_mensal,1),1); %gera um mapa de nans

%%
% Plot modo 01

f4 = figure;
f4.Position = [10 10 1100 400];
modo = 1;

mapa01 = mapaNan; %cria uma copia do mapa de nanas
mapa01(id(:,1)) = u(:,modo)*s(modo,modo)/sqrt(length(timeMensal)); %cria o mapa do modo
porc = s(modo,modo)^2/sum(diag(s).^2)*100; %encontra a porcentagem de variancia do modo

mapa01 = reshape(mapa01,sizeMatrix); %tranforma o mapa vetor em mapa mariz

cc = linspace(min(mapa01(:)),max(mapa01(:)),10); 

subplot(1,2,1)
m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]); 
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa01,cc,'edgecolor','none');
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS',['EOF MODO' num2str(modo) ' - ' num2str(round(porc,2)) '%']});
ylabel('latitude')
xlabel('longitude')

subplot(1,2,2)

st = sqrt(length(timeMensal))*v(:,modo); %desvio padrao nao normalizado

plot(timeMensal,st)
ylabel('Desvio padrão (nm)')
xtickangle(45)
grid

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_modo01', '-djpeg','-r300');

%%
% Plot modo 02

f5 = figure;
f5.Position = [10 10 1100 400];
modo = 2;
mapa02 = mapaNan;
mapa02(id(:,1)) = u(:,modo)*s(modo,modo)/sqrt(length(timeMensal));
porc = s(2,2)^2/sum(diag(s).^2)*100;

mapa02 = reshape(mapa02,sizeMatrix);

cc = linspace(min(mapa02(:)),max(mapa02(:)),10);

subplot(1,2,1)
m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]); 
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa02,cc,'edgecolor','none');
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS',['EOF MODO' num2str(modo) ' - ' num2str(round(porc,2)) '%']});
ylabel('latitude')
xlabel('longitude')

subplot(1,2,2)

st = sqrt(length(timeMensal))*v(:,modo);

plot(timeMensal,st)
ylabel('Desvio padrão (nm)')
xtickangle(45)
grid

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_modo02', '-djpeg','-r300');

%%
% Plot modo 03

f6 = figure;
f6.Position = [10 10 1100 400];
modo = 3;
mapa03 = mapaNan;
mapa03(id(:,1)) = u(:,modo)*s(modo,modo)/sqrt(length(timeMensal));
porc = s(3,3)^2/sum(diag(s).^2)*100;

mapa03 = reshape(mapa03,sizeMatrix);

cc = linspace(min(mapa03(:)),max(mapa03(:)),10);

subplot(1,2,1)
m_proj('miller','lon',[min(lon) max(lon)],'lat',[min(lat) max(lat)]); 
[CS,CH]=m_contourf(reshape(lon,sizeMatrix),reshape(lat,sizeMatrix),mapa03,cc,'edgecolor','none');
colormap(turbo(length(cc)-1));
c = colorbar('XTick',cc);
c.Title.String = 'sr^-^1'
hold on
caxis([cc(1) cc(end)])
m_gshhs_h('color','k');
m_grid('box','fancy','tickdir','in');
title({'Reflectancia 555nm - Aqua MODIS',['EOF MODO' num2str(modo) ' - ' num2str(round(porc,2)) '%']});
ylabel('latitude')
xlabel('longitude')

subplot(1,2,2)

st = sqrt(length(timeMensal))*v(:,modo);

plot(timeMensal,st)
ylabel('Desvio padrão (nm)')
xtickangle(45)
grid

set(gcf,'renderer','painters'); %determina o tipo de renderizador. Paiters tem melhor aplicacao para graficos em 2D
set(gcf,'color','w'); %figura em fundo branco
print('regiao02_modo03', '-djpeg','-r300');

clear c cc CH cont_nan CS i id_elimina_mes_sem_dados j porc mapa mapaNan nlat nlon...
    x x_interp years ans rrs_555 rrs_555_mensal rrs_555_interp_semNan rrs_555_interp_semNan_media...
    time timex timevec f1 f2 f3

close all

save('variaveis_regiao02')
