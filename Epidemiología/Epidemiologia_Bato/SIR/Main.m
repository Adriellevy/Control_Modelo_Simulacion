clear; clc; close all;

%% 1. Parámetros fijos
N      = 7.9e6;          % 7.9 millones de habitantes
gamma  = 1/3;            % Tasa de recuperación (1/días)
b = 0.5;                 % Tiempo medio entre contactos
I0_abs = 10;             % 10 individuos iniciales
i0     = I0_abs / N;
y0     = [1 - i0; i0; 0];
tspan  = [0, 100];
dt     = 0.05;


t_objetivo = 35;         % Día fijado para el pico
tol        = 0.01;       % Tolerancia (|t_pico - 35| < 0.01 días)

%% 2. Algoritmo de Bisección sobre 'b'
b_inf = 0.40;
b_sup = 0.80;
max_iter = 50;
iter = 0;

fprintf('Buscando b mediante Bisección...\n');

while (b_sup - b_inf)/2 > 1e-5 && iter < max_iter
    iter = iter + 1;
    b_mid = (b_inf + b_sup) / 2;
    
    t_pico_mid = calcular_pico(b_mid, gamma, y0, tspan, dt);
    
    if abs(t_pico_mid - t_objetivo) < tol
        break;
    end
    
    if t_pico_mid > t_objetivo
        b_inf = b_mid;
    else
        b_sup = b_mid;
    end
end

b_opt        = b_mid;
t_pico_final = t_pico_mid;

% Cálculo formal
R0   = b / gamma;
Re_0 = (b / gamma) * ((N-I0_abs) / N);

fprintf('\n--- RESULTADOS PARA PICO EN DÍA %d ---\n', t_objetivo);
fprintf('Iteraciones:  %d\n', iter);
fprintf('b necesario:  %.4f días^-1\n', b_opt);
fprintf('R0 (intrínseco):         %.4f\n', R0);
fprintf('Re(0) (efectivo inicial): %.6f\n', Re_0);
fprintf('Día del pico: %.2f días\n', t_pico_final);

%% 3. Simulación final con el b optimizado
f_opt  = @(t, y) modeloSIR(t, y, b_opt, gamma);
[t, y] = RK4(f_opt, tspan, y0, dt);

% Conversión a individuos absolutos
S_t = y(:, 1) * N;
I_t = y(:, 2) * N;
R_t = y(:, 3) * N;

max_I = max(I_t);

%% 4. Gráficos (SIR completo + Zoom al pico)
figure('Color', 'w', 'Position', [100, 100, 1050, 450]);

% Panel izquierdo: Dinámica completa SIR
subplot(1, 2, 1);
plot(t, S_t / 1e6, 'b-', 'LineWidth', 2); hold on;
plot(t, I_t / 1e6, 'r-', 'LineWidth', 2);
plot(t, R_t / 1e6, 'g-', 'LineWidth', 2);
grid on;
xlabel('Tiempo (días)');
ylabel('Millones de habitantes');
title(sprintf('Modelo SIR Completo (b = %.4f)', b_opt));
legend('S(t) Susceptibles', 'I(t) Infectados', 'R(t) Recuperados', 'Location', 'east');

% Panel derecho: Detalle del pico de infectados
subplot(1, 2, 2);
plot(t, I_t, 'r-', 'LineWidth', 2); hold on;
plot(t_pico_final, max_I, 'ko', 'MarkerFaceColor', 'k');
xline(t_objetivo, '--k', sprintf('Objetivo: Día %d', t_objetivo));
grid on;
xlabel('Tiempo (días)');
ylabel('Infectados activos I(t)');
title(sprintf('Pico en t = %.2f días', t_pico_final));
legend('I(t)', sprintf('Máx: %s casos', num2str(round(max_I))), 'Location', 'northeast');

S_t = y(:, 1) * N;
I_t = y(:, 2) * N;
S0 = N - I0_abs;

% --- PUNTO D:  Llamada a la función del diagrama de fase---
metricas = diagramaFaseSIR(S_t, I_t, N, b_opt, gamma, S0, I0_abs);

%% --- PUNTO E: Variación de Gamma ---

res_gamma = sensibilidadGamma(N, b, gamma, S0, I0_abs, tspan, dt);

%% --- PUNTO F: Variación de b ---

res_beta = sensibilidadBeta(N, b, gamma, S0, I0_abs, tspan, dt);

%% FUNCIONES AUXILIARES

function t_pico = calcular_pico(b, gamma, y0, tspan, dt)
    f_sir  = @(t, y) modeloSIR(t, y, b, gamma);
    [t, y] = RK4(f_sir, tspan, y0, dt);
    [~, idx] = max(y(:, 2));
    t_pico = t(idx);
end