% 1. Definir vectores de espacio y tiempo
espacio = linspace(0, 4, 81); % Vector espacio de 81 elementos [cm]
tiempo = 0 : 1.1/50 : (1.1 - 1.1/50); % Vector de tiempo
% Umbral teórico de aliasing en Eco Doppler (en cm/s)
umbral_aliasing_2D = 42;
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
hold on;
Analisis_onda('2D', umbral_aliasing_2D, espacio, tiempo, Vel_Joven');

% Subplot 2: Mayor
subplot(1, 2, 2);
surf(espacio, tiempo, Vel_Mayor');
colorbar;
clim([min_global, max_global]); % Fija la misma escala de color
xlabel('Espacio [cm]');
ylabel('Tiempo');
title('Evolución Espaciotemporal del Mayor');
shading interp;
hold on;
Analisis_onda('2D', umbral_aliasing_2D, espacio, tiempo, Vel_Mayor');
%% Manejo de voxel
% Umbral de aliasing convertido a m/s para los datos 4D
umbral_aliasing_3D = 0.42;
% 2. Cargar los archivos Excel ÚNICAMENTE si no existen las matrices
if ~exist('MeshVelocidades', 'var') 
    TableMeshVelocidades = readtable('velocidadesMesh.xlsx');
    MeshVelocidades = table2array(TableMeshVelocidades);
end

X=MeshVelocidades(:,1);
Y=MeshVelocidades(:,2);
Z=MeshVelocidades(:,3);
Vx=MeshVelocidades(:,4:53); %m/s
Vy=MeshVelocidades(:,54:103);
Vz=MeshVelocidades(:,104:153);
dx=0.00140625; %m/px
dy=0.002250; %m/px
dz=0.001; %m/px
X_m = X * dx;
Y_m = Y * dy;
Z_m = Z * dz;
%%
figure(2)
plot(Vx(50,:))
hold on
plot(Vx(end-50,:))
legend('Pos Inicial', 'Pos Final') % Reemplaza 'Pos Final' por el nombre que prefieras
%%
figure(3)
quiver3(X,Y,Z,Vx(:,1),Vy(:,1),Vz(:,1),5)
%%
figure(3)
% Fondo blanco para la figura (mejor presentación)
set(gcf, 'Color', 'w'); 

% 1. Crear el gráfico inicial (usando las coordenadas en metros)
q = quiver3(X_m, Y_m, Z_m, Vx(:,1), Vy(:,1), Vz(:,1));

% Estilo de las flechas
q.Color = [0 0.4470 0.7410]; % Color azul estándar de MATLAB
q.LineWidth = 1.2;           % Flechas un poco más gruesas

% --- DISEÑO DE LOS EJES ---
xlabel('Posición X (m)', 'FontWeight', 'bold', 'FontSize', 11);
ylabel('Posición Y (m)', 'FontWeight', 'bold', 'FontSize', 11);
zlabel('Posición Z (m)', 'FontWeight', 'bold', 'FontSize', 11);

grid on;            % Activar la cuadrícula principal
box on;             % Cerrar la caja gráfica alrededor del 3D
axis equal;         % CRÍTICO: Mantiene las proporciones reales (1m en X se ve igual que 1m en Z)
view(45, 30);       % Ángulo de visión 3D (Azimut 45°, Elevación 30°)

% Mejorar la apariencia de la cuadrícula
ax = gca;
ax.FontSize = 10;                % Tamaño de los números de los ejes
ax.GridColor = [0.3 0.3 0.3];    % Color de la cuadrícula más oscuro
ax.GridAlpha = 0.4;              % Opacidad de la cuadrícula

% Fija los límites geométricos para que la caja no cambie de tamaño al animar
axis tight manual; 
hold on;
datos_superficie_4D = Analisis_onda('3D', umbral_aliasing_3D, X_m, Y_m, Z_m, Vx, Vy, Vz);
% Inicializar un objeto de malla (patch) vacío para la superficie
h_surf = patch('Faces', [], 'Vertices', [], ...
               'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
% Añadir iluminación para que el volumen se vea tridimensional
camlight('headlight'); 
lighting gouraud;
material dull;
%% 2. Bucle de animación
for i = 1:50
    % Actualizar componentes de velocidad
    q.UData = Vx(:,i);
    q.VData = Vy(:,i);
    q.WData = Vz(:,i);
    
    % Título dinámico con mejor formato
    title(sprintf('Campo de Velocidades del VI | Instante: %02d / 50', i), 'FontSize', 13);
    % Actualizar la geometría de la superficie roja para este instante
    h_surf.Faces = datos_superficie_4D{i, 1};
    h_surf.Vertices = datos_superficie_4D{i, 2};
    drawnow;
    pause(0.15);
    trayectoria_4D = Analisis_onda('3D', umbral_aliasing_3D, X_m, Y_m, Z_m, Vx, Vy, Vz);
end