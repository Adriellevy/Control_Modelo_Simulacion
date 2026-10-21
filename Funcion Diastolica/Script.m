%% =========================================================================
% ANÁLISIS DE FLUJOS: APARTADOS 2D Y 4D
% =========================================================================
clear; clc; close all; % Limpia el entorno para evitar conflictos (opcional)

%% =========================================================================
% 1. APARTADO: FLUJO 2D (Eco Doppler)
% =========================================================================

%% 1.1 Parámetros y Carga de Datos 2D
% Definir vectores de espacio y tiempo
espacio = linspace(0, 4, 81); % Vector espacio de 81 elementos [cm]
tiempo = 0 : 1.1/50 : (1.1 - 1.1/50); % Vector de tiempo

% Umbral teórico de aliasing en Eco Doppler (en cm/s)
umbral_aliasing_2D = 42;

% Cargar los archivos Excel ÚNICAMENTE si no existen las matrices
if ~exist('Vel_Joven', 'var') || ~exist('Vel_Mayor', 'var')
    disp('Cargando datos 2D...');
    GridVelJoven = readtable('GridVelJoven.xlsx');
    GridVelMayor = readtable('GridVelMayor.xlsx');
    Vel_Joven = table2array(GridVelJoven);
    Vel_Mayor = table2array(GridVelMayor);
end

% Calcular los límites globales de velocidad para unificar la escala de color
min_global = min([Vel_Joven(:); Vel_Mayor(:)]);
max_global = max([Vel_Joven(:); Vel_Mayor(:)]);

%% 1.2 Visualización Espaciotemporal 2D
figure('Name', 'Flujo 2D - Eco Doppler', 'NumberTitle', 'off');

% Subplot 1: Joven
subplot(1, 2, 1);
surf(espacio, tiempo, Vel_Joven');
shading interp; % Suaviza la malla visualmente
colorbar;
clim([min_global, max_global]); % Fija la escala de color
xlabel('Espacio [cm]');
ylabel('Tiempo [s]');
title('Evolución Espaciotemporal del Joven');
hold on;
Resultado_vp_joven=Analisis_onda('2D', umbral_aliasing_2D, espacio, tiempo, Vel_Joven');

% Subplot 2: Mayor
subplot(1, 2, 2);
surf(espacio, tiempo, Vel_Mayor');
shading interp;
colorbar;
clim([min_global, max_global]); % Fija la misma escala de color
xlabel('Espacio [cm]');
ylabel('Tiempo [s]');
title('Evolución Espaciotemporal del Mayor');
hold on;
Resultado_vp_mayor=Analisis_onda('2D', umbral_aliasing_2D, espacio, tiempo, Vel_Mayor');


%% =========================================================================
% 2. APARTADO: FLUJO 4D (Manejo de Voxel)
% =========================================================================

% 2.1 Parámetros, Carga y Transformación de Datos 4D
% Umbral de aliasing convertido a m/s para los datos 4D
umbral_aliasing_3D = 0.42;

% Cargar los archivos Excel ÚNICAMENTE si no existen las matrices
if ~exist('MeshVelocidades', 'var') 
    disp('Cargando datos 4D...');
    TableMeshVelocidades = readtable('velocidadesMesh.xlsx');
    MeshVelocidades = table2array(TableMeshVelocidades);
end

% Extracción de coordenadas espaciales
X = MeshVelocidades(:, 1);
Y = MeshVelocidades(:, 2);
Z = MeshVelocidades(:, 3);

% Extracción de componentes de velocidad en el tiempo
Vx = MeshVelocidades(:, 4:53);   % m/s
Vy = MeshVelocidades(:, 54:103);
Vz = MeshVelocidades(:, 104:153);

% Factores de conversión y paso a metros
dx = 0.00140625; % m/px
dy = 0.002250;   % m/px
dz = 0.001;      % m/px

X_m = X * dx;
Y_m = Y * dy;
Z_m = Z * dz;

%% 2.2 Gráficos de Exploración 4D
% Evolución temporal de Vx
figure('Name', 'Exploración 4D - Vx', 'NumberTitle', 'off');
plot(Vx(50, :), 'LineWidth', 1.5);
hold on;
plot(Vx(end-50, :), 'LineWidth', 1.5);
legend('Pos Inicial', 'Pos Final');
xlabel('Instante temporal'); ylabel('Velocidad Vx [m/s]');
title('Evolución temporal de Vx');
grid on;

% Vista rápida del campo de velocidades en el instante 1 (en píxeles)
figure('Name', 'Exploración 4D - Campo Rápido', 'NumberTitle', 'off');
quiver3(X, Y, Z, Vx(:,1), Vy(:,1), Vz(:,1), 5);
title('Campo de velocidades (escala en píxeles)');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal; grid on;

%% 2.3 Preparación de la Animación 4D Avanzada
figure('Name', 'Animación de Flujo 4D', 'NumberTitle', 'off');
set(gcf, 'Color', 'w'); % Fondo blanco 

% Crear el gráfico inicial (en metros)
q = quiver3(X_m, Y_m, Z_m, Vx(:,1), Vy(:,1), Vz(:,1));
q.Color = [0 0.4470 0.7410]; 
q.LineWidth = 1.2;           

% Diseño de ejes
xlabel('Posición X (m)', 'FontWeight', 'bold', 'FontSize', 11);
ylabel('Posición Y (m)', 'FontWeight', 'bold', 'FontSize', 11);
zlabel('Posición Z (m)', 'FontWeight', 'bold', 'FontSize', 11);
grid on; box on; axis equal; view(45, 30);       

% Apariencia de la cuadrícula
ax = gca;
ax.FontSize = 10;                
ax.GridColor = [0.3 0.3 0.3];    
ax.GridAlpha = 0.4;              
axis tight manual; % CRÍTICO: Fija los límites geométricos
hold on;

% Pre-calcular los datos de la superficie para toda la animación
disp('Procesando superficie 4D...');
datos_superficie_4D = Analisis_onda('3D', umbral_aliasing_3D, X_m, Y_m, Z_m, Vx, Vy, Vz);

% Inicializar parche (malla) vacío
h_surf = patch('Faces', [], 'Vertices', [], ...
               'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);

camlight('headlight'); 
lighting gouraud;
material dull;

%% 2.4 Bucle de Animación 4D
disp('Iniciando animación...');
for i = 1:50
    % Actualizar flechas de velocidad
    q.UData = Vx(:,i);
    q.VData = Vy(:,i);
    q.WData = Vz(:,i);
    
    % Actualizar título
    title(sprintf('Campo de Velocidades del VI | Instante: %02d / 50', i), 'FontSize', 13);
    
    % Actualizar la superficie roja para este instante
    h_surf.Faces = datos_superficie_4D{i, 1};
    h_surf.Vertices = datos_superficie_4D{i, 2};
    
    drawnow;
    pause(0.15);
    
    % NOTA: La siguiente línea estaba recalculando TODO en cada iteración del bucle.
    % La he comentado por rendimiento. Solo descoméntala si la función requiere
    % ejecutarse de nuevo cada frame en lugar de pre-calcularse.
    % trayectoria_4D = Analisis_onda('3D', umbral_aliasing_3D, X_m, Y_m, Z_m, Vx, Vy, Vz);
end