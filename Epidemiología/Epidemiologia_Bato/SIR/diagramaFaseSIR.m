function metricas = diagramaFaseSIR(S_t, I_t, N, b, gamma, S0, I0)
% DIAGRAMAFASESIR Grafica el plano de fase I(S), calcula el pico analítico
% y compara el máximo de infectados con la población de susceptibles.
%
% Entradas:
%   S_t, I_t : Vectores temporales con las poblaciones absolutas.
%   N        : Población total.
%   b        : Tasa de transmisión (1/días).
%   gamma    : Tasa de recuperación (1/días).
%   S0, I0   : Poblaciones iniciales absolutas.
%
% Salida:
%   metricas : Struct con los valores teóricos y relaciones calculadas.

    %% 1. Cálculos analíticos y teóricos
    R0        = b / gamma;
    S_critico = N / R0; % Susceptibles en el pico (isoclina dI/dt = 0)
    
    % Máximo teórico obtenido de la integral primera I(S)
    I_max_teo = I0 + S0 - S_critico + S_critico * log(S_critico / S0);
    
    % Máximo numérico obtenido de la simulación
    [I_max_num, idx_pico] = max(I_t);
    S_en_pico_num         = S_t(idx_pico);
    
    % Comparaciones porcentuales
    pct_S_critico_N = (S_critico / N) * 100;
    pct_Imax_N      = (I_max_teo / N) * 100;
    rel_Imax_Scrit  = (I_max_teo / S_critico) * 100;
    rel_Imax_S0     = (I_max_teo / S0) * 100;

    %% 2. Empaquetar métricas en struct
    metricas.R0              = R0;
    metricas.S_critico       = S_critico;
    metricas.I_max_teo       = I_max_teo;
    metricas.I_max_num       = I_max_num;
    metricas.rel_Imax_Scrit  = rel_Imax_Scrit;
    metricas.rel_Imax_S0     = rel_Imax_S0;

    %% 3. Reporte en consola
    fprintf('\n================ REPORTE PLANO DE FASE I(S) ================\n');
    fprintf('R0 del sistema:                %.2f\n', R0);
    fprintf('Susceptibles en el pico (S*):  %s habitantes (%.2f%% de N)\n', ...
        num2str(round(S_critico)), pct_S_critico_N);
    fprintf('I_max analítico:               %s casos activos (%.2f%% de N)\n', ...
        num2str(round(I_max_teo)), pct_Imax_N);
    fprintf('I_max numérico simulado:       %s casos activos\n', num2str(round(I_max_num)));
    fprintf('Comparación I_max / S(pico):   %.2f%%\n', rel_Imax_Scrit);
    fprintf('Comparación I_max / S(inicio): %.2f%%\n', rel_Imax_S0);
    fprintf('============================================================\n\n');

    %% 4. Gráfico del Diagrama de Fase
    figure('Color', 'w', 'Position', [150, 150, 850, 520]);
    
    % Trayectoria
    plot(S_t / 1e6, I_t / 1e6, 'b-', 'LineWidth', 2.5); hold on;
    
    % Puntos singulares
    plot(S0 / 1e6, I0 / 1e6, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
    plot(S_critico / 1e6, I_max_teo / 1e6, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
    
    % Isoclina nula (umbral crítico S = N / R0)
    xline(S_critico / 1e6, '--k', 'LineWidth', 1.5);
    
    % Flechas de dirección temporal
    quiver(S_t(1:300:end) / 1e6, I_t(1:300:end) / 1e6, ...
           gradient(S_t(1:300:end)) / 1e6, gradient(I_t(1:300:end)) / 1e6, ...
           0.35, 'Color', [0.35 0.35 0.35]);
    
    grid on;
    xlabel('Susceptibles S (Millones de personas)');
    ylabel('Infectados I (Millones de personas)');
    title('Diagrama de Fase I(S)');
    legend('Trayectoria', 'Inicio (t = 0)', ...
           sprintf('I_{max} \\approx %d casos', round(I_max_teo)), ...
           'Isoclina dI/dt = 0 (S = N/R_0)', 'Location', 'northwest');
end