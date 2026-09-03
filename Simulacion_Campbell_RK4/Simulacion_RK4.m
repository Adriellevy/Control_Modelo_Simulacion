% Simulación de Campbell utilizando Runge-Kutta de 4to orden (RK4)
% Esta es una alternativa al código original provisto por el profesor 
% que utiliza el solver ode23 de MATLAB.
% Permite estudiar la influencia del paso de integración (h) en 
% la convergencia y estabilidad del método numérico de forma explícita.

function Simulacion_RK4()
    Ciclos = 5;
    t0 = 0;
    tf = 0.62;
    tf = tf*(1+eps);
    p0 = [30; 30; 40; 30; 32];
    
    h = 0.001; % Paso de integración (ajustable)
    
    t_total = [];
    P_total = [];
    
    for i = 1:Ciclos
        % Reemplazamos ode23 por nuestra propia implementación de RK4
        [t, P] = rk4(@Ec_Dif_Local, [t0, tf], p0, h);
        
        if i == 1
            t_total = t;
            P_total = P;
        else
            % Concatenamos evitando duplicar el primer punto
            t_total = [t_total; t(2:end) + t_total(end)]; 
            P_total = [P_total; P(2:end, :)];
        end
        
        p0 = P(end, :)';
    end
    
    % Gráficos de Presiones
    figure(1);
    subplot(3,2,1); plot(t_total, P_total(:,1)); ylabel('P1(t) [mmHg]'); xlabel('t');
    subplot(3,2,2); plot(t_total, P_total(:,2)); ylabel('P2(t) [mmHg]'); xlabel('t');
    subplot(3,2,3); plot(t_total, P_total(:,3)); ylabel('P3(t) [mmHg]'); xlabel('t');
    subplot(3,2,4); plot(t_total, P_total(:,4)); ylabel('P4(t) [mmHg]'); xlabel('t');
    subplot(3,2,5); plot(t_total, P_total(:,5)); ylabel('P5(t) [mmHg]'); xlabel('t');
    sgtitle('Presiones con RK4');
    
    % Cálculo de Volumen y curva Presión-Volumen
    V_total = zeros(size(t_total));
    for n = 1:length(t_total)
        % el tiempo dentro de un ciclo para evaluar la compliance
        t_local = mod(t_total(n), tf); 
        if t_local < 0.39
            C5 = 2e-3 - 1.875e-3*sin(pi*t_local/0.39);
        else
            C5 = 2e-3;
        end
        V_total(n) = C5 * P_total(n, 5) * 1334;
    end
    
    figure(2);
    plot(V_total, P_total(:,5));
    title('Curva Presión-Volumen (Simulación RK4)');
    ylabel('Presión [mmHg]');
    xlabel('Volumen [cc]');
end

function pder = Ec_Dif_Local(t, p)
    % Copia de la ecuación diferencial (Ec_difPV1) del modelo propuesto
    % para evaluar de manera aislada con nuestros métodos numéricos.
    
    R1 = 250; 
    R2 = 380; % Equivalente a 3800/10 original
    R3 = 350;
    R4 = 625;
    R5 = 200;
    C1 = 1.9e-4;
    C2 = 0.0326;
    C4 = 8.2e-3; 
    
    if t < 0.39
        C5 = 2e-3 - 1.875e-3*sin(pi*t/0.39);
        C5d = -1.875e-3*pi/0.39*cos(pi*t/0.39);
        C3 = C5/3;
        C3d = C5d/3;
    else
        C5 = 2e-3;
        C5d = 0;
        C3 = C5/3;
        C3d = 0;
    end

    V1 = (p(5)>p(1));
    V2 = (p(2)>p(3));
    V3 = (p(3)>p(4));
    V4 = (p(4)>p(5));

    f11 = -(V1/R1+1/R2)/C1; 
    f12 = 1/(R2*C1);
    f15 = V1/(R1*C1);
    f21 = 1/(R2*C2);
    f22 = -(1/R2+V2/R3)/C2;
    f23 = V2/(R3*C2);
    f32 = V2/(R3*C3);
    f33 = -(V2/R3+V3/R4+C3d)/C3;
    f34 = V3/(R4*C3);
    f43 = V3/(R4*C4);
    f44 = -(V3/R4+V4/R5)/C4;
    f45 = V4/(R5*C4);
    f51 = V1/(R1*C5);
    f54 = V4/(R5*C5);
    f55 = -(V1/R1+V4/R5+C5d)/C5;

    matriz = [f11 f12 0 0 f15;
              f21 f22 f23 0 0;
              0 f32 f33 f34 0;
              0 0 f43 f44 f45;
              f51 0 0 f54 f55];
    pder = matriz * p;
end
