% 1. Definir vectores de espacio y tiempo
espacio = linspace(0, 4, 81); % Vector espacio de 81 elementos [cm]
tiempo = 0 : 1.1/50 : (1.1 - 1.1/50); % Vector de tiempo

% 2. Cargar los archivos Excel ÚNICAMENTE si no existen las matrices
if ~exist('Vel_Joven', 'var') || ~exist('Vel_Mayor', 'var')
    GridVelJoven = readtable('GridVelJoven.xlsx');
    GridVelMayor = readtable('GridVelMayor.xlsx');
    Vel_Joven = table2array(GridVelJoven);
    Vel_Mayor = table2array(GridVelMayor);
end

% 3. Calcular los límites globales de velocidad para unificar la escala de color
min_global = min([Vel_Joven(:); Vel_Mayor(:)]);
max_global = max([Vel_Joven(:); Vel_Mayor(:)]);

% 4. Graficar
figure(1);

% Subplot 1: Joven
subplot(1, 2, 1);
surf(espacio, tiempo, Vel_Joven');
colorbar;
clim([min_global, max_global]); % Fija la escala de color
xlabel('Espacio [cm]');
ylabel('Tiempo');
title('Evolución Espaciotemporal del Joven');
shading interp; % Suaviza la malla visualmente

% Subplot 2: Mayor
subplot(1, 2, 2);
surf(espacio, tiempo, Vel_Mayor');
colorbar;
clim([min_global, max_global]); % Fija la misma escala de color
xlabel('Espacio [cm]');
ylabel('Tiempo');
title('Evolución Espaciotemporal del Mayor');
shading interp;
%% Manejo de voxel

% 2. Cargar los archivos Excel ÚNICAMENTE si no existen las matrices
if ~exist('MeshVelocidades', 'var') 
    TableMeshVelocidades = readtable('velocidadesMesh.xlsx');
    MeshVelocidades = table2array(TableMeshVelocidades);
end

% X=MeshVelocidades(:,1)
% Y=MeshVelocidades(:,2)
% Z=MeshVelocidades(:,3)
% Vx=MeshVelocidades(:,4:53) m/s
% Vy=MeshVelocidades(:,54:103)
% Vz=MeshVelocidades(:,104:153)
dx=0.00140625 %m/px
dy=0.002250 %m/px
dz=0.001 %m/px
% Figure(2)
quiver3(X,Y,Z,Vx,Vy,Vz)