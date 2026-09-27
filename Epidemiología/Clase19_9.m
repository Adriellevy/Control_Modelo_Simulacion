% =========================================================================
% RESOLUCIÓN DEL MODELO SIR - GRIPE DE HONG KONG (NUEVA YORK 2004)
% =========================================================================
clc; clear; close all;
% --- Parámetros Iniciales (Parte c) ---
N = 7.9e6;          % Población de NY
beta_base = 0.72;    % Tasa de contagio (1 contagio cada 2 días)
gamma_base = 1/3;   % Tasa de recuperación (1 recuperación cada 3 días)
Y_0 = [N - 10, 10, 0]; % [S(0), I(0), R(0)] - Asumimos S0 = N-10
t_span = 0:1:150;      % 150 días
% --- 1. Simulación base (Parte c) ---
[t, Y] = ode45(@(t,y) modeloSIR(t, y, beta_base, gamma_base, N), t_span, Y_0);
S = Y(:,1); I = Y(:,2); R = Y(:,3);
figure('Name', 'Evolución Epidémica (150 días)');
plot(t, S, 'b', t, I, 'r', t, R, 'g', 'LineWidth', 2);
grid on; title('Evolución de la Gripe de Hong Kong en NY (150 días)');
xlabel('Días'); ylabel('Población');
legend('Susceptibles', 'Infectados', 'Recuperados', 'Location', 'best');
% --- 2. Diagrama de Fase I(S) y Cálculo de I_max (Parte d) ---
[I_max, idx_max] = max(I);
S_at_I_max = S(idx_max);
fprintf('--- Resultados del Escenario Base ---\n');
fprintf('I_max (Cantidad máxima de infecciosos): %.0f personas\n', I_max);
fprintf('Susceptibles restantes en el pico (S): %.0f personas\n\n', S_at_I_max);
figure('Name', 'Diagrama de Fase I(S)');
plot(S, I, 'k', 'LineWidth', 2); hold on;
plot(S_at_I_max, I_max, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Marca el pico
grid on; title('Diagrama de Fase: Infectados vs Susceptibles');
xlabel('Susceptibles (S)'); ylabel('Infectados (I)');
legend('Trayectoria I(S)', 'I_{max} (Pico Epidémico)', 'Location', 'best');
set(gca, 'XDir', 'reverse'); % Invertir el eje X es convención en epidemiología
% --- 3. Variación de Gamma manteniendo Beta constante (Parte e) ---
factores = linspace(0.25, 1.75, 20); % Variación del 25% al 175%
I_max_gamma_var = zeros(length(factores), 1);
gamma_vals = gamma_base * factores;
for k = 1:length(factores)
    [~, Y_var] = ode45(@(t,y) modeloSIR(t, y, beta_base, gamma_vals(k), N), t_span, Y_0);
    I_max_gamma_var(k) = max(Y_var(:,2));
end
% Polyfit para Gamma (Grado 2 suele ser buen ajuste empírico aquí)
p_gamma = polyfit(gamma_vals, I_max_gamma_var, 2);
I_max_gamma_fit = polyval(p_gamma, gamma_vals);
figure('Name', 'Efecto de Gamma sobre I_max');
plot(gamma_vals, I_max_gamma_var, 'bo', 'MarkerFaceColor', 'b'); hold on;
plot(gamma_vals, I_max_gamma_fit, 'r-', 'LineWidth', 2);
grid on; title('Efecto de variar \gamma sobre I_{max} (polyfit)');
xlabel('Tasa de Recuperación (\gamma)'); ylabel('I_{max}');
legend('Datos simulados', 'Ajuste polinómico', 'Location', 'best');
% --- 4. Variación de Beta manteniendo Gamma constante (Parte f) ---
I_max_beta_var = zeros(length(factores), 1);
beta_vals = beta_base * factores;
for k = 1:length(factores)
    [~, Y_var] = ode45(@(t,y) modeloSIR(t, y, beta_vals(k), gamma_base, N), t_span, Y_0);
    I_max_beta_var(k) = max(Y_var(:,2));
end
% Polyfit para Beta
p_beta = polyfit(beta_vals, I_max_beta_var, 2);
I_max_beta_fit = polyval(p_beta, beta_vals);
figure('Name', 'Efecto de Beta sobre I_max');
plot(beta_vals, I_max_beta_var, 'bo', 'MarkerFaceColor', 'b'); hold on;
plot(beta_vals, I_max_beta_fit, 'r-', 'LineWidth', 2);
grid on; title('Efecto de variar \beta sobre I_{max} (polyfit)');
xlabel('Tasa de Transmisión (\beta)'); ylabel('I_{max}');
legend('Datos simulados', 'Ajuste polinómico', 'Location', 'best');
% =========================================================================
% FUNCIÓN DEL MODELO SIR
% =========================================================================
function dydt = modeloSIR(~, y, beta, gamma, N)
    S = y(1);
    I = y(2);
    % R = y(3); % R no es estrictamente necesario para S' e I', pero lo mantenemos
    
    dSdt = -beta * S * I / N;
    dIdt = beta * S * I / N - gamma * I;
    dRdt = gamma * I;
    
    dydt = [dSdt; dIdt; dRdt];
end