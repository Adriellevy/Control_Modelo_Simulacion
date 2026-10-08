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

% 3. Graficar 1vs1 (Ground Truth vs Algoritmo Optimizado)
figure('Name', 'Comparación 1vs1: GS vs Optimización', 'NumberTitle', 'off');
hold on;
grid on;

% Graficar Sistólica (Puntos rojos)
scatter(PS_GS, PS_opt, 50, 'r', 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Sistólica');

% Graficar Diastólica (Puntos azules)
scatter(PD_GS, PD_opt, 50, 'b', 'filled', 'MarkerEdgeColor', 'k', 'DisplayName', 'Diastólica');

% Calcular los límites para la línea de identidad (y = x)
min_val = min([PS_GS, PD_GS, PS_opt, PD_opt]) - 10;
max_val = max([PS_GS, PD_GS, PS_opt, PD_opt]) + 10;

% Trazar la línea ideal (y = x)
plot([min_val max_val], [min_val max_val], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal (y = x)');

% Etiquetas y diseño
xlabel('Presión de Referencia (Gold Standard) [mmHg]', 'FontWeight', 'bold');
ylabel('Presión Estimada con Algoritmo [mmHg]', 'FontWeight', 'bold');
title(sprintf('Correlación 1 vs 1 (Umbrales: S=%.2f, D=%.2f)', uSistOpt, uDiastOpt));
legend('Location', 'best');
axis([min_val max_val min_val max_val]); % Mantener la misma escala en ambos ejes
axis square; % Forzar la caja gráfica a ser cuadrada para visualizar mejor el y=x
hold off;