function Simulador_SIR_Interactivo()
    % --- Parámetros Iniciales Fijos ---
    N = 7.9e6;             % Población de NY
    Y_0 = [N - 10, 10, 0]; % [S(0), I(0), R(0)]
    t_span = 0:1:150;      % 150 días

    % --- Creación de la Interfaz Gráfica (UIFigure) ---
    fig = uifigure('Name', 'Simulador SIR Interactivo', 'Position', [100, 100, 800, 600]);

    % Crear los ejes para la gráfica
    ax = uiaxes(fig, 'Position', [50, 150, 700, 400]);
    title(ax, 'Evolución de la Gripe de Hong Kong en NY (150 días)');
    xlabel(ax, 'Días');
    ylabel(ax, 'Población');
    grid(ax, 'on');

    % --- Sliders y Etiquetas ---
    % Slider para Beta (Tasa de contagio)
    uilabel(fig, 'Position', [100, 100, 150, 22], 'Text', 'Beta (Tasa de contagio):', 'FontWeight', 'bold');
    sldBeta = uislider(fig, 'Position', [100, 80, 250, 3], ...
                       'Limits', [0, 2], ...
                       'Value', 2/3); % Valor inicial

    % Slider para Gamma (Tasa de recuperación)
    uilabel(fig, 'Position', [450, 100, 150, 22], 'Text', 'Gamma (Recuperación):', 'FontWeight', 'bold');
    sldGamma = uislider(fig, 'Position', [450, 80, 250, 3], ...
                        'Limits', [0, 1], ...
                        'Value', 1/4); % Valor inicial

    % Asignar la función de actualización a los eventos de los sliders
    sldBeta.ValueChangedFcn = @(src, event) actualizarGrafica();
    sldGamma.ValueChangedFcn = @(src, event) actualizarGrafica();

    % --- Botón para Exportar al Workspace ---
    btnExportar = uibutton(fig, 'Position', [325, 20, 150, 35], ...
                           'Text', 'Exportar al Workspace', ...
                           'ButtonPushedFcn', @(src, event) exportarValores());

    % --- Dibujar la gráfica por primera vez ---
    actualizarGrafica();

    % --- Función anidada para actualizar la gráfica ---
    function actualizarGrafica()
        % Leer valores actuales de los sliders
        beta_actual = sldBeta.Value;
        gamma_actual = sldGamma.Value;

        % Resolver EDO con los nuevos valores
        [t, Y] = ode45(@(t,y) modeloSIR(t, y, beta_actual, gamma_actual, N), t_span, Y_0);

        % Limpiar el gráfico actual y volver a dibujar
        cla(ax);
        hold(ax, 'on');
        plot(ax, t, Y(:,1), 'b', 'LineWidth', 2, 'DisplayName', 'Susceptibles');
        plot(ax, t, Y(:,2), 'r', 'LineWidth', 2, 'DisplayName', 'Infectados');
        plot(ax, t, Y(:,3), 'g', 'LineWidth', 2, 'DisplayName', 'Recuperados');
        hold(ax, 'off');
        
        % Actualizar leyenda
        legend(ax, 'Location', 'best');
    end

    % --- Función anidada para exportar al Workspace ---
    function exportarValores()
        beta_export = sldBeta.Value;
        gamma_export = sldGamma.Value;
        
        % assignin manda las variables al "base" workspace de MATLAB
        assignin('base', 'beta_seleccionado', beta_export);
        assignin('base', 'gamma_seleccionado', gamma_export);
        
        % Mostrar una pequeña alerta visual para confirmar la acción
        mensaje = sprintf('Valores guardados:\nbeta = %.4f\ngamma = %.4f', beta_export, gamma_export);
        uialert(fig, mensaje, 'Exportación Exitosa', 'Icon', 'success');
        
        % También lo mostramos en la consola de comandos por practicidad
        fprintf('Exportado al Workspace: beta_seleccionado = %.4f, gamma_seleccionado = %.4f\n', beta_export, gamma_export);
    end
end

% --- Función de las Ecuaciones Diferenciales (SIR) ---
function dy = modeloSIR(~, y, beta, gamma, N)
    S = y(1);
    I = y(2);
    R = y(3);
    
    dS = -beta * S * I / N;
    dI = beta * S * I / N - gamma * I;
    dR = gamma * I;
    
    dy = [dS; dI; dR];
end