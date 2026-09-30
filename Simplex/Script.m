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
% 3. Crear una función anónima que le pase las variables extra a nuestra función de costo
% 'u' será el vector que Simplex irá modificando: u = [uSist, uDiast]
funcionObjetivo = MSE_total([uSist uDiast], A, PrampaDig, tm, PS_GS, PD_GS, N);

% 4. Ejecutar algoritmo Simplex (Nelder-Mead)
fprintf('Iniciando optimizacion Simplex...\n');
umbralesOptimos = fminsearch(funcionObjetivo, x0, opciones);

% 5. Resultados
uSist_Opt = umbralesOptimos(1);
uDiast_Opt = umbralesOptimos(2);

fprintf('\n=== OPTIMIZACION FINALIZADA ===\n');
fprintf('Umbral Sistólico Óptimo: %.4f\n', uSist_Opt);
fprintf('Umbral Diastólico Óptimo: %.4f\n', uDiast_Opt);
