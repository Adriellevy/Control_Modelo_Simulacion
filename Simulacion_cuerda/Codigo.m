% 1. Parámetros principales y Espaciales
Puntos_t = 801; % 8s / dt(0.01) + 1
Puntos_x = 201; % 1m / dx(0.005) + 1
xL = 1;              
x = linspace(0, xL, Puntos_x); 
dx = x(2) - x(1); % Extrae el dx real
t = linspace(0, 8, Puntos_t); 
dt = t(2) - t(1); % Extrae el dt real
% Selección de las 3 alternativas de velocidad
c1 = 0.33;
caso_simulacion = 2; % Cambiar a: 1 (c2=c1), 2 (c2=50% menos) o 3 (c2=50% más)
if caso_simulacion == 1
    c2 = c1;
elseif caso_simulacion == 2
    c2 = c1 * 0.5;
else
    c2 = c1 * 1.5;
end
% 2. Definir Lambda dependiente de la posición (espacio)
Lambda = zeros(1, Puntos_x);
Lambda(x <= 2/3) = c1 * (dt/dx);   % Velocidad normal para los primeros 2/3
Lambda(x > 2/3)  = c2 * (dt/dx);   % Velocidad seleccionada para el último 1/3
% Precalcular constante L2 solo para los nodos interiores (índices 2 a fin-1)
L2 = Lambda(2:end-1).^2; 
% 3. Parámetros del pulso y Tiempo
alpha = 50; 
t0 = 1; 
% Inicializar la matriz de solución U(t, x)
U = zeros(Puntos_t, Puntos_x);
% Pre-calcular el pulso para todos los instantes de tiempo
pulso = exp(-alpha * (t - t0).^2);
% Condición inicial para los primeros dos pasos de tiempo en el borde izquierdo
U(1, 1) = pulso(1); 
U(2, 1) = pulso(2); 
% 4. Resolución Temporal
for j = 2:Puntos_t-1
    % Condición de borde izquierda
    U(j+1, 1) = pulso(j+1);
    
    % Resolución vectorizada espacial. 
    U(j+1, 2:end-1) = L2 .* U(j, 3:end) + 2*(1 - L2) .* U(j, 2:end-1) + L2 .* U(j, 1:end-2) - U(j-1, 2:end-1);
    
    % Condición de borde derecha fija
    U(j+1, end) = 0;
end
% ----------------------------------
% 5. Animación Dinámica
figure('Name', sprintf('Propagación - Caso %d', caso_simulacion));
for j = 1:1:Puntos_t % Salto ajustado para velocidad de reproducción
    plot(x, U(j, :), 'b', 'LineWidth', 2);
    hold on;
    xline(2/3, 'r--', 'Discontinuidad de densidad');
    hold off;
    
    axis([0 xL -1 1.5]); 
    xlabel('Posición x (m)');
    ylabel('Amplitud u(t,x)');
    title(sprintf('Onda en el tiempo t = %.2f s (Caso %d)', t(j), caso_simulacion));
    grid on;
    drawnow;
end