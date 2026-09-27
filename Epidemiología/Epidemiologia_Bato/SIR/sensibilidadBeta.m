function salida = sensibilidadBeta(N, b_base, gamma, S0, I0, tspan, dt)
% SENSIBILIDADBETA Evalúa el efecto de variar b (beta*N) entre 25% y 175% sobre I_max.
% Ajusta la tendencia mediante polyfit y grafica la respuesta.
%
% Entradas:
%   N          : Población total.
%   b_base     : Tasa de contacto base (0.5).
%   gamma      : Tasa de recuperación (fija, 1/3).
%   S0, I0     : Poblaciones iniciales absolutas.
%   tspan, dt  : Intervalo y paso de integración para RK4.

    %% 1. Rango de variación de b (25% a 175%)
    porcentajes = linspace(0.25, 1.75, 30);       % 30 muestras en el rango
    bs          = b_base * porcentajes;
    
    I_max_teorico  = zeros(size(bs));
    I_max_simulado = zeros(size(bs));
    R0_valores     = zeros(size(bs));

    y0 = [S0/N; I0/N; 0];

    %% 2. Barrido paramétrico
    for k = 1:length(bs)
        b_actual = bs(k);
        R0_act   = b_actual / gamma;
        R0_valores(k) = R0_act;
        
        % Cálculo analítico de I_max
        if R0_act > 1
            S_crit = N / R0_act;
            I_max_teorico(k) = I0 + S0 - S_crit + S_crit * log(S_crit / S0);
        else
            % Rango subcrítico (R0 <= 1): no hay expansión, el pico es la semilla
            I_max_teorico(k) = I0;
        end
        
        % Integración numérica con RK4
        f_sir  = @(t, y) modeloSIR(t, y, b_actual, gamma);
        [~, y] = RK4(f_sir, tspan, y0, dt);
        I_max_simulado(k) = max(y(:, 2)) * N;
    end

    %% 3. Ajuste polinómico con polyfit (Grado 2)
    grado = 2;
    p_b   = polyfit(bs, I_max_simulado, grado);
    
    % Malla fina para graficar el polinomio ajustado
    b_fino    = linspace(min(bs), max(bs), 200);
    I_max_fit = polyval(p_b, b_fino);

    % Coeficiente de determinación R^2
    residuos = I_max_simulado - polyval(p_b, bs);
    ss_res   = sum(residuos.^2);
    ss_tot   = sum((I_max_simulado - mean(I_max_simulado)).^2);
    R2       = 1 - (ss_res / ss_tot);

    %% 4. Gráficos
    figure('Color', 'w', 'Position', [100, 100, 950, 450]);

    % Subplot 1: I_max vs b con ajuste polyfit
    subplot(1, 2, 1);
    plot(bs, I_max_simulado / 1e6, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Simulación (RK4)'); hold on;
    plot(b_fino, I_max_fit / 1e6, 'b-', 'LineWidth', 2, ...
         'DisplayName', sprintf('Ajuste Polyfit Grado %d (R^2 = %.4f)', grado, R2));
    xline(b_base, '--k', 'DisplayName', sprintf('b base (%.3f)', b_base));
    xline(gamma, ':r', 'DisplayName', sprintf('Umbral R_0=1 (b = \\gamma = %.3f)', gamma));
    grid on;
    xlabel('b (días^{-1})');
    ylabel('I_{max} (Millones de personas)');
    title('Efecto de b (\beta) sobre I_{max}');
    legend('Location', 'northwest');

    % Subplot 2: I_max vs Porcentaje relativo de b
    subplot(1, 2, 2);
    plot(porcentajes * 100, I_max_simulado / 1e6, 'b.-', 'LineWidth', 1.8); hold on;
    grid on;
    xlabel('Variación de b (%)');
    ylabel('I_{max} (Millones de personas)');
    title('I_{max} vs % de b Base');
    xline(100, '--k', '100% Base');
    xline((gamma / b_base) * 100, ':r', 'Umbral R_0 = 1 (66.7%)');

    %% 5. Estructura de salida
    salida.bs             = bs;
    salida.porcentajes    = porcentajes;
    salida.I_max_simulado = I_max_simulado;
    salida.coeficientes   = p_b;
    salida.R2             = R2;

    %% 6. Reporte en consola
    fprintf('\n================ ANÁLISIS DE SENSIBILIDAD (BETA / b) ================\n');
    fprintf('Polinomio ajustado: I_max(b) = (%.2e)*b^2 + (%.2e)*b + (%.2e)\n', ...
        p_b(1), p_b(2), p_b(3));
    fprintf('Coeficiente de determinación R^2: %.4f\n', R2);
    fprintf('=====================================================================\n\n');
end

