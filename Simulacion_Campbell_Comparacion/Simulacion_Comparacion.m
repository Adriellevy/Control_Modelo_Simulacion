function Simulacion_Comparacion()
    % Script de comparación entre Euler, RK4 y ode23 para el modelo de Campbell
    % Incluye medición de tiempos (tic/toc) y experimentos de convergencia/estabilidad.
    
    Ciclos = 5;
    t0 = 0;
    tf = 0.62 * (1+eps);
    p0_init = [30; 30; 40; 30; 32];
    
    % --- EXPERIMENTO 1: Comparación de métodos con paso fijo h = 0.001 ---
    h_fino = 0.001;
    
    % 1. ode23 (Método original del profesor)
    disp('--- Simulando con ode23 (Profesor) ---');
    tic;
    [t_ode, P_ode, V_ode] = simular_modelo(@(t,p) Ec_Dif_Local(t,p), Ciclos, t0, tf, p0_init, 'ode23', []);
    tiempo_ode = toc;
    fprintf('Tiempo ode23: %.4f segundos\n\n', tiempo_ode);
    
    % 2. RK4
    disp('--- Simulando con RK4 (h=0.001) ---');
    tic;
    [t_rk4, P_rk4, V_rk4] = simular_modelo(@(t,p) Ec_Dif_Local(t,p), Ciclos, t0, tf, p0_init, 'rk4', h_fino);
    tiempo_rk4 = toc;
    fprintf('Tiempo RK4: %.4f segundos\n\n', tiempo_rk4);
    
    % 3. Euler
    disp('--- Simulando con Euler (h=0.001) ---');
    tic;
    [t_eu, P_eu, V_eu] = simular_modelo(@(t,p) Ec_Dif_Local(t,p), Ciclos, t0, tf, p0_init, 'euler', h_fino);
    tiempo_eu = toc;
    fprintf('Tiempo Euler: %.4f segundos\n\n', tiempo_eu);
    
    % --- GRÁFICOS: COMPARACIÓN DE LOS TRES MÉTODOS ---
    % Gráfico 1: Subplots comparativos de las presiones (P1 a P5)
    figure('Name', 'Comparación de Presiones (ode23 vs RK4 vs Euler)', 'NumberTitle', 'off');
    titulos = {'P1 (Ventrículo)', 'P2 (Aorta)', 'P3 (Arterias)', 'P4 (Arteriolas/Capilares)', 'P5 (Venas)'};
    for i = 1:5
        subplot(3, 2, i);
        plot(t_ode, P_ode(:,i), 'k-', 'LineWidth', 2); hold on;
        plot(t_rk4, P_rk4(:,i), 'b--', 'LineWidth', 1.5);
        plot(t_eu, P_eu(:,i), 'r:', 'LineWidth', 1.5);
        title(titulos{i}); xlabel('t [s]'); ylabel('P [mmHg]');
        if i == 5
            legend('ode23', 'RK4', 'Euler', 'Location', 'best');
        end
        grid on;
    end
    sgtitle('Comparación de Métodos Numéricos (h = 0.001)');
    
    % Gráfico 2: Comparación Curva Presión-Volumen
    figure('Name', 'Curva PV Comparativa', 'NumberTitle', 'off');
    plot(V_ode, P_ode(:,5), 'k-', 'LineWidth', 2); hold on;
    plot(V_rk4, P_rk4(:,5), 'b--', 'LineWidth', 1.5);
    plot(V_eu, P_eu(:,5), 'r:', 'LineWidth', 1.5);
    title('Curva Presión-Volumen Comparativa');
    xlabel('Volumen [cc]'); ylabel('Presión Venosa (P5) [mmHg]');
    legend(sprintf('ode23 (%.3fs)', tiempo_ode), ...
           sprintf('RK4 (%.3fs)', tiempo_rk4), ...
           sprintf('Euler (%.3fs)', tiempo_eu), ...
           'Location', 'best');
    grid on;
    
    % --- EXPERIMENTO 2: Estabilidad y Precisión con paso más grueso (VOP / Variación del Paso) ---
    % Vamos a aumentar el paso h para observar cómo Euler falla (se vuelve inestable)
    % mientras que RK4 soporta pasos más grandes sin divergir.
    disp('--- EXPERIMENTO DE ESTABILIDAD (Variando h) ---');
    h_grueso = 0.015; % Un paso donde Euler suele volverse inestable en estos sistemas
    disp(['Probando simulacion de 1 ciclo con paso más grueso h = ', num2str(h_grueso)]);
    
    try
        [~, P_eu_grueso, ~] = simular_modelo(@(t,p) Ec_Dif_Local(t,p), 1, t0, tf, p0_init, 'euler', h_grueso);
        eu_falla = any(isnan(P_eu_grueso(:))) || any(isinf(P_eu_grueso(:))) || max(abs(P_eu_grueso(:))) > 1e4;
    catch
        eu_falla = true;
    end
    
    try
        [~, P_rk4_grueso, ~] = simular_modelo(@(t,p) Ec_Dif_Local(t,p), 1, t0, tf, p0_init, 'rk4', h_grueso);
        rk4_falla = any(isnan(P_rk4_grueso(:))) || any(isinf(P_rk4_grueso(:))) || max(abs(P_rk4_grueso(:))) > 1e4;
    catch
        rk4_falla = true;
    end
    
    if eu_falla
        disp('--> RESULTADO: Como era esperado, EULER ES INESTABLE y diverge con h grande.');
    else
        disp('--> RESULTADO: Euler sobrevivió este paso.');
    end
    
    if ~rk4_falla
        disp('--> RESULTADO: RK4 se mantiene ESTABLE con el mismo h grande, demostrando mayor tolerancia.');
    else
        disp('--> RESULTADO: RK4 también falló con este h.');
    end
end

% === Funciones Auxiliares Internas ===

function [t_total, P_total, V_total] = simular_modelo(odefun, Ciclos, t0, tf, p0, metodo, h)
    t_total = [];
    P_total = [];
    options = odeset('RelTol',1e-4,'AbsTol',1e-3);
    
    for i = 1:Ciclos
        switch metodo
            case 'ode23'
                [t, P] = ode23(odefun, [t0 tf], p0, options);
            case 'rk4'
                [t, P] = rk4(odefun, [t0, tf], p0, h);
            case 'euler'
                [t, P] = euler(odefun, [t0, tf], p0, h);
        end
        
        if i == 1
            t_total = t;
            P_total = P;
        else
            t_total = [t_total; t(2:end) + t_total(end)]; 
            P_total = [P_total; P(2:end, :)];
        end
        p0 = P(end, :)';
    end
    
    % Calculo de Volumen
    V_total = zeros(size(t_total));
    for n = 1:length(t_total)
        t_local = mod(t_total(n), tf); 
        if t_local < 0.39
            C5 = 2e-3 - 1.875e-3*sin(pi*t_local/0.39);
        else
            C5 = 2e-3;
        end
        V_total(n) = C5 * P_total(n, 5) * 1334;
    end
end

function pder = Ec_Dif_Local(t, p)
    % Parámetros de la simulación de Campbell
    R1 = 250; R2 = 380; R3 = 350; R4 = 625; R5 = 200;
    C1 = 1.9e-4; C2 = 0.0326; C4 = 8.2e-3; 
    
    if t < 0.39
        C5 = 2e-3 - 1.875e-3*sin(pi*t/0.39);
        C5d = -1.875e-3*pi/0.39*cos(pi*t/0.39);
        C3 = C5/3; C3d = C5d/3;
    else
        C5 = 2e-3; C5d = 0; C3 = C5/3; C3d = 0;
    end

    V1 = (p(5)>p(1)); V2 = (p(2)>p(3)); V3 = (p(3)>p(4)); V4 = (p(4)>p(5));

    f11 = -(V1/R1+1/R2)/C1;  f12 = 1/(R2*C1); f15 = V1/(R1*C1);
    f21 = 1/(R2*C2);         f22 = -(1/R2+V2/R3)/C2; f23 = V2/(R3*C2);
    f32 = V2/(R3*C3);        f33 = -(V2/R3+V3/R4+C3d)/C3; f34 = V3/(R4*C3);
    f43 = V3/(R4*C4);        f44 = -(V3/R4+V4/R5)/C4; f45 = V4/(R5*C4);
    f51 = V1/(R1*C5);        f54 = V4/(R5*C5); f55 = -(V1/R1+V4/R5+C5d)/C5;

    matriz = [f11 f12 0 0 f15; f21 f22 f23 0 0; 0 f32 f33 f34 0; 0 0 f43 f44 f45; f51 0 0 f54 f55];
    pder = matriz * p;
end
