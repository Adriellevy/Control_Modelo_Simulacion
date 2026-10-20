% -------------------------------------------------------------------------
% 1) Cálculo de estimaciones PS_MAA y PD_MAA
% -------------------------------------------------------------------------
N=94
% Definición de los umbrales solicitados
uSist = 0.55;
uDiast = 0.82;

% Inicialización de los vectores de salida (1x94) para optimizar memoria
PS_MAA = zeros(1, N);
PD_MAA = zeros(1, N);

% Iteración sobre los N=94 pacientes
for i = 1:N
    % Extracción de las señales del paciente 'i' (filas completas de 1x6001)
    A_i = A(i, :);
    PrampaDig_i = PrampaDig(i, :);
    tm_i = tm(i, :);
    
    % Estimación de las presiones sistólica y diastólica mediante el método
    [PS_MAA(i), PD_MAA(i)] = detectarPSyPD(uSist, uDiast, A_i, PrampaDig_i, tm_i);
end

% -------------------------------------------------------------------------
% 2) Cálculo de errores, medias y desvíos estándar
% -------------------------------------------------------------------------

% a. Error para cada paciente i (Estimación MAA - Ground Truth GS)
% Asumiendo la convención estándar de Error = Medición - Referencia
Error_PS = PS_MAA - PS_GS; 
Error_PD = PD_MAA - PD_GS;

% b. Error medio sistólico y diastólico
Error_Medio_PS = mean(Error_PS);
Error_Medio_PD = mean(Error_PD);

% c. Desvío estándar del error sistólico y diastólico
Std_Error_PS = std(Error_PS);
Std_Error_PD = std(Error_PD);

% Mostrar resultados en consola
fprintf('Error Medio Sistólico: %.2f mmHg (Std: %.2f mmHg)\n', Error_Medio_PS, Std_Error_PS);
fprintf('Error Medio Diastólico: %.2f mmHg (Std: %.2f mmHg)\n', Error_Medio_PD, Std_Error_PD);
%% -------------------------------------------------------------------------
% 3) Graficos de errores
% -------------------------------------------------------------------------
% Errores no absolutos
figure(1)
subplot(2,2,1)
plot(Error_PS)
hold on
plot(Error_PD)
hold off
subplot(2,2,2)
plot(Error_PS,Error_PD,'o')
% Errores absolutos 
Error_Absoluto_Pd=abs(Error_PD);
Error_Absoluto_Ps=abs(Error_PS);


subplot(2,2,3)
plot(Error_Absoluto_Pd)
hold on
plot(Error_Absoluto_Ps)
hold off


subplot(2,2,4)
plot(Error_Absoluto_Ps,Error_Absoluto_Pd,'o')
%% -------------------------------------------------------------------------
% 4) Optimizacion de errores
% -------------------------------------------------------------------------
% 2. Configurar opciones de Simplex (opcional, para ver las iteraciones)
opciones = optimset('Display', 'iter', 'TolX', 1e-4, 'TolFun', 1e-4);

% 3. Crear una función anónima que le pase las variables extra a nuestra función de costo
% 'params' será el vector que Simplex irá modificando: 
funcionObjetivo =@(params)  MSE_total(params, A, PrampaDig, tm, PS_GS, PD_GS);

% 4. Ejecutar algoritmo Simplex (Nelder-Mead)
fprintf('Iniciando optimizacion Simplex...\n');
umbralesOptimos = fminsearch(funcionObjetivo, [uSist uDiast], opciones);

% 5. Resultados
uSistOpt = umbralesOptimos(1);
uDiastOpt = umbralesOptimos(2);

fprintf('\n=== OPTIMIZACION FINALIZADA ===\n');
fprintf('Umbral Sistólico Óptimo: %.4f\n', uSistOpt);
fprintf('Umbral Diastólico Óptimo: %.4f\n', uDiastOpt);
%% Grafico de los umbrales optimos
% 1. Recalcular las presiones usando los umbrales optimizados
nSignals = size(A,1);
PS_opt = zeros(1, nSignals);
PD_opt = zeros(1, nSignals);

for i = 1:nSignals
    Ai   = A(i,:);
    Pi   = PrampaDig(i,:);
    tmi  = tm(i,:);
    [PS_opt(i), PD_opt(i)] = detectarPSyPD(uSistOpt, uDiastOpt, Ai, Pi, tmi);
end

% 2. Cálculo de errores medios y métricas (Simplex y MAA)
% a. Modelo optimizado con Simplex
Error_PS_opt = PS_opt - PS_GS;
Error_PD_opt = PD_opt - PD_GS;

mean_Error_PS_opt = mean(Error_PS_opt);
mean_Error_PD_opt = mean(Error_PD_opt);
std_Error_PS_opt  = std(Error_PS_opt);
std_Error_PD_opt  = std(Error_PD_opt);
var_Error_PS_opt  = var(Error_PS_opt);
var_Error_PD_opt  = var(Error_PD_opt);

var_Error_PS = var_Error_PS_opt;
var_Error_PD = var_Error_PD_opt;
std_Error_PS = std_Error_PS_opt;
std_Error_PD = std_Error_PD_opt;

% b. Modelo empírico inicial MAA
mean_Error_PS_MAA = mean(Error_PS);
mean_Error_PD_MAA = mean(Error_PD);

% Límites comunes para la línea ideal (y = x) en ambos subplots
min_val = min([PS_GS, PD_GS, PS_opt, PD_opt, PS_MAA, PD_MAA]) - 10;
max_val = max([PS_GS, PD_GS, PS_opt, PD_opt, PS_MAA, PD_MAA]) + 10;

% 3. Graficar 1vs1 comparativo: Simplex Optimizado (1,2,1) vs MAA Inicial (1,2,2)
figure('Name', 'Comparación 1vs1: Simplex vs MAA (frente a GS)', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 550]);

% -------------------------------------------------------------------------
% Subplot (1,2,1): Simplex Optimizado vs GS
% -------------------------------------------------------------------------
subplot(1, 2, 1);
hold on;
grid on;

% Graficar Sistólica y Diastólica (Simplex)
scatter(PS_GS, PS_opt, 50, 'r', 'filled', 'MarkerEdgeColor', 'k', ...
    'DisplayName', sprintf('Sistólica (Error Medio: %.2f mmHg)', mean_Error_PS_opt));
scatter(PD_GS, PD_opt, 50, 'b', 'filled', 'MarkerEdgeColor', 'k', ...
    'DisplayName', sprintf('Diastólica (Error Medio: %.2f mmHg)', mean_Error_PD_opt));

% Trazar la línea ideal (y = x)
plot([min_val max_val], [min_val max_val], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal (y = x)');

% Cuadro informativo con datos de Error Medio (Simplex)
txt_err_opt = {
    '\bfError Medio (Simplex - GS):\rm'
    sprintf('  Sistólica (PS):  %.2f mmHg', mean_Error_PS_opt)
    sprintf('  Diastólica (PD): %.2f mmHg', mean_Error_PD_opt)
};

text(0.04, 0.94, txt_err_opt, ...
    'Units', 'normalized', ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8.5, ...
    'EdgeColor', [0.6 0.6 0.6], ...
    'BackgroundColor', [0.97 0.97 0.97], ...
    'Margin', 5);

% Etiquetas y diseño
xlabel('Presión de Referencia (Gold Standard) [mmHg]', 'FontWeight', 'bold');
ylabel('Presión Estimada con Simplex [mmHg]', 'FontWeight', 'bold');
title(sprintf('Simplex Optimizado: 1 vs 1 (S=%.2f, D=%.2f)', uSistOpt, uDiastOpt));
legend('Location', 'southeast');
axis([min_val max_val min_val max_val]);
axis square;
hold off;

% -------------------------------------------------------------------------
% Subplot (1,2,2): Método MAA Inicial vs GS
% -------------------------------------------------------------------------
subplot(1, 2, 2);
hold on;
grid on;

% Graficar Sistólica y Diastólica (MAA Inicial)
scatter(PS_GS, PS_MAA, 50, 'r', 'filled', 'MarkerEdgeColor', 'k', ...
    'DisplayName', sprintf('Sistólica (Error Medio: %.2f mmHg)', mean_Error_PS_MAA));
scatter(PD_GS, PD_MAA, 50, 'b', 'filled', 'MarkerEdgeColor', 'k', ...
    'DisplayName', sprintf('Diastólica (Error Medio: %.2f mmHg)', mean_Error_PD_MAA));

% Trazar la línea ideal (y = x)
plot([min_val max_val], [min_val max_val], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal (y = x)');

% Cuadro informativo con datos de Error Medio (MAA)
txt_err_maa = {
    '\bfError Medio (MAA - GS):\rm'
    sprintf('  Sistólica (PS):  %.2f mmHg', mean_Error_PS_MAA)
    sprintf('  Diastólica (PD): %.2f mmHg', mean_Error_PD_MAA)
};

text(0.04, 0.94, txt_err_maa, ...
    'Units', 'normalized', ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8.5, ...
    'EdgeColor', [0.6 0.6 0.6], ...
    'BackgroundColor', [0.97 0.97 0.97], ...
    'Margin', 5);

% Etiquetas y diseño
xlabel('Presión de Referencia (Gold Standard) [mmHg]', 'FontWeight', 'bold');
ylabel('Presión Estimada con MAA [mmHg]', 'FontWeight', 'bold');
title(sprintf('MAA Inicial: 1 vs 1 (S=%.2f, D=%.2f)', uSist, uDiast));
legend('Location', 'southeast');
axis([min_val max_val min_val max_val]);
axis square;
hold off;
%% -------------------------------------------------------------------------
% 5) Validación del Error Medio (< 5 mmHg), Regresión y Gráficos
% -------------------------------------------------------------------------

% --- Validación en consola ---
fprintf('\n=== VALIDACIÓN DE ERROR OPTIMIZADO (Criterio < 5 mmHg) ===\n');
fprintf('Error Medio Sistólico  (PS): %6.2f mmHg (Std: %.2f, Varianza: %.2f mmHg^2)\n', mean(Error_PS_opt), std_Error_PS, var_Error_PS);
fprintf('Error Medio Diastólico (PD): %6.2f mmHg (Std: %.2f, Varianza: %.2f mmHg^2)\n', mean(Error_PD_opt), std_Error_PD, var_Error_PD);

% --- Cálculo de Regresión y R^2 (usando polyfit y corrcoef) ---
p_ps = polyfit(PS_GS, PS_opt, 1);       
R_ps = corrcoef(PS_GS, PS_opt);

p_pd = polyfit(PD_GS, PD_opt, 1);       
R_pd = corrcoef(PD_GS, PD_opt);

% --- Creación de la Figura ---
figure('Name', 'Análisis Estadístico Avanzado', 'NumberTitle', 'off');

% 1. Histograma de Errores (Estimado - GS)
subplot(2, 2, 1);
histogram(PS_opt - PS_GS, 'FaceColor', 'r', 'FaceAlpha', 0.6);
hold on;
histogram(PD_opt - PD_GS, 'FaceColor', 'b', 'FaceAlpha', 0.6);
xline(5, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Límite +5 mmHg'); 
xline(-5, 'k--', 'LineWidth', 1.5, 'HandleVisibility','off');
title('Histograma de Errores Optimizado');
xlabel('Error [mmHg]');
ylabel('Frecuencia');
legend('Sistólica (PS)', 'Diastólica (PD)', 'Límite \pm5 mmHg');
grid on;
hold off;

% 2. Gráfico de Residuos (Error vs GS)
subplot(2, 2, 2);
scatter(PS_GS, PS_opt - PS_GS, 30, 'r', 'filled');
hold on;
scatter(PD_GS, PD_opt - PD_GS, 30, 'b', 'filled');
yline(0, 'k-', 'LineWidth', 1.5);
yline(5, 'k--', 'LineWidth', 1.5);
yline(-5, 'k--', 'LineWidth', 1.5);
title('Análisis de Residuos');
xlabel('Presión de Referencia (GS) [mmHg]');
ylabel('Residuo [mmHg]');
legend('Residuos PS', 'Residuos PD', 'Error 0', 'Límite \pm5 mmHg', 'Location','best');
grid on;
hold off;

% 3. Regresión Sistólica (PS_GS vs PS_opt)
subplot(2, 2, 3);
scatter(PS_GS, PS_opt, 30, 'r', 'filled');
hold on;
plot(PS_GS, polyval(p_ps, PS_GS), 'k-', 'LineWidth', 1.5);
title('Regresión Sistólica');
xlabel('PS Referencia [mmHg]');
ylabel('PS Estimada [mmHg]');
eq_str_ps = sprintf('y = %.2fx + %.2f\nR^2 = %.4f', p_ps(1), p_ps(2), R_ps(1,2)^2);
text(min(PS_GS), max(PS_opt), eq_str_ps, 'VerticalAlignment', 'top', 'FontSize', 10, 'FontWeight', 'bold');
grid on;
hold off;

% 4. Regresión Diastólica (PD_GS vs PD_opt)
subplot(2, 2, 4);
scatter(PD_GS, PD_opt, 30, 'b', 'filled');
hold on;
plot(PD_GS, polyval(p_pd, PD_GS), 'k-', 'LineWidth', 1.5);
title('Regresión Diastólica');
xlabel('PD Referencia [mmHg]');
ylabel('PD Estimada [mmHg]');
eq_str_pd = sprintf('y = %.2fx + %.2f\nR^2 = %.4f', p_pd(1), p_pd(2), R_pd(1,2)^2);
text(min(PD_GS), max(PD_opt), eq_str_pd, 'VerticalAlignment', 'top', 'FontSize', 10, 'FontWeight', 'bold');
grid on;
hold off;