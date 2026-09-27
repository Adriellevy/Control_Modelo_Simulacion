function salida = sensibilidadGamma(N, b, gamma_base, S0, I0, tspan, dt)
% SENSIBILIDADGAMMA Evalúa el efecto de variar gamma entre 25% y 175% sobre I_max.
% Ajusta la tendencia mediante polyfit y grafica la respuesta.
%
% Entradas:
%   N          : Población total.
%   b          : Tasa de contacto (fija).
%   gamma_base : Valor base de gamma (1/3).
%   S0, I0     : Poblaciones iniciales absolutas.
%   tspan, dt  : Intervalo y paso de integración para RK4.

    %% 1. Rango de variación de gamma (25% a 175%)
    porcentajes = linspace(0.25, 1.75, 30);       % 30 muestras en el rango
    gammas      = gamma_base .* porcentajes;
    
    I_max_teorico = zeros(size(gammas));
    I_max_simulado = zeros(size(gammas));
    R0_valores     = zeros(size(gammas));

    y0 = [S0/N; I0/N; 0];

    %% 2. Barrido paramétrico
    for k = 1:length(gammas)
        g_actual = gammas(k);
        R0_act   = b / g_actual;
        R0_valores(k) = R0_act;
        
        % Cálculo analítico de I_max
        if R0_act > 1
            S_crit = N / R0_act;
            I_max_teorico(k) = I0 + S0 - S_crit + S_crit * log(S_crit / S0);
        else
            % Si R0 <= 1, la enfermedad no se expande: el pico es I0
            I_max_teorico(k) = I0;
        end
        
        % Integración numérica con RK4
        f_sir  = @(t, y) modeloSIR(t, y, b, g_actual);
        [~, y] = RK4(f_sir, tspan, y0, dt);
        I_max_simulado(k) = max(y(:, 2)) * N;
    end

    %% 3. Ajuste polinómico con polyfit (Grado 2)
    % Ajustamos I_max en función de gamma
    grado = 2;
    p_gamma = polyfit(gammas, I_max_simulado, grado);
    
    % Malla fina para graficar el polinomio ajustado
    gamma_fino  = linspace(min(gammas), max(gammas), 200);
    I_max_fit   = polyval(p_gamma, gamma_fino);

    % Coeficiente de determinación R^2
    residuos = I_max_simulado - polyval(p_gamma, gammas);
    ss_res = sum(residuos.^2);
    ss_tot = sum((I_max_simulado - mean(I_max_simulado)).^2);
    R2 = 1 - (ss_res / ss_tot);

    %% 4. Gráficos
    figure('Color', 'w', 'Position', [100, 100, 950, 450]);

    % Subplot 1: I_max vs Gamma con ajuste polyfit
    subplot(1, 2, 1);
    plot(gammas, I_max_simulado / 1e6, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Simulación (RK4)'); hold on;
    plot(gamma_fino, I_max_fit / 1e6, 'b-', 'LineWidth', 2, ...
         'DisplayName', sprintf('Ajuste Polyfit Grado %d (R^2 = %.4f)', grado, R2));
    xline(gamma_base, '--k', 'DisplayName', sprintf('\\gamma base (%.3f)', gamma_base));
    grid on;
    xlabel('\gamma (días^{-1})');
    ylabel('I_{max} (Millones de personas)');
    title('Efecto de \gamma sobre I_{max}');
    legend('Location', 'northeast');

    % Subplot 2: I_max vs Porcentaje relativo de gamma
    subplot(1, 2, 2);
    plot(porcentajes * 100, I_max_simulado / 1e6, 'm.-', 'LineWidth', 1.8); hold on;
    grid on;
    xlabel('Variación de \gamma (%)');
    ylabel('I_{max} (Millones de personas)');
    title('I_{max} vs % de \gamma Base');
    xline(100, '--k', '100% Base');

    %% 5. Estructura de salida
    salida.gammas         = gammas;
    salida.porcentajes    = porcentajes;
    salida.I_max_simulado = I_max_simulado;
    salida.coeficientes   = p_gamma;
    salida.R2             = R2;

    %% 6. Conclusión en consola
    fprintf('\n================ ANÁLISIS DE SENSIBILIDAD (GAMMA) ================\n');
    fprintf('Polinomio ajustado: I_max(gamma) = (%.2e)*gamma^2 + (%.2e)*gamma + (%.2e)\n', ...
        p_gamma(1), p_gamma(2), p_gamma(3));
    fprintf('Coeficiente de determinación R^2: %.4f\n', R2);
    fprintf('==================================================================\n\n');
end