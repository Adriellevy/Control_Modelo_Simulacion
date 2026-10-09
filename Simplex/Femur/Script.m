% --- CÁLCULO DE PARÁMETROS INICIALES Y OPTIMIZADOS ---
pos_0_x = mean(H(:,1));
pos_0_y = mean(H(:,2));
pos_0_z = mean(H(:,3));
rad_0 = sqrt((pos_0_x - H(1,1))^2 + (pos_0_y - H(1,2))^2 + (pos_0_z - H(1,3))^2);
params_0 = [pos_0_x, pos_0_y, pos_0_z, rad_0];

opciones = optimset('Display', 'iter', 'TolX', 1e-4, 'TolFun', 1e-4);
functionobjetivo = @(params) costo(params, H);
vectoroptimo = fminsearch(functionobjetivo, params_0, opciones);


% =========================================================================
% PARÁMETROS DE CONFIGURACIÓN DE VISUALIZACIÓN
% =========================================================================
OPACIDAD_ESFERA = 0.25;  % Cambiar entre 0 (invisible) y 1 (sólido)

% =========================================================================
% CÁLCULOS DE PARÁMETROS
% =========================================================================
pos_0_x = mean(H(:,1));
pos_0_y = mean(H(:,2));
pos_0_z = mean(H(:,3));
rad_0 = sqrt((pos_0_x - H(1,1))^2 + (pos_0_y - H(1,2))^2 + (pos_0_z - H(1,3))^2);
params_0 = [pos_0_x, pos_0_y, pos_0_z, rad_0];

opciones = optimset('Display', 'iter', 'TolX', 1e-4, 'TolFun', 1e-4);
functionobjetivo = @(params) costo(params, H);
vectoroptimo = fminsearch(functionobjetivo, params_0, opciones);

err_0 = functionobjetivo(params_0);
err_opt = functionobjetivo(vectoroptimo);

% =========================================================================
% GENERACIÓN DEL GRÁFICO (POSICIONAMIENTO RELATIVO 100% COMPATIBLE)
% =========================================================================
fig = figure('Name', 'Comparativa de Ajuste de Esfera', 'Color', 'w');

% Matriz de 3x2 en subplot: los gráficos 3D ocupan las 2 primeras filas (filas 1 y 2)
% y los cuadros de texto ocupan únicamente la última fila (fila 3).
[x_s, y_s, z_s] = sphere(30);

% -------------------------------------------------------------------------
% SUBPLOT 1: ESTIMACIÓN INICIAL (Izquierda - Ocupa posiciones 1 y 3)
% -------------------------------------------------------------------------
ax1 = subplot(3, 2, [1, 3]);
hold(ax1, 'on');

scatter3(ax1, H(:,1), H(:,2), H(:,3), 15, [0.2 0.4 0.8], 'filled', 'MarkerFaceAlpha', 0.5);
surf(ax1, pos_0_x + x_s*rad_0, pos_0_y + y_s*rad_0, pos_0_z + z_s*rad_0, ...
     'FaceColor', [0.8 0.5 0.2], 'FaceAlpha', OPACIDAD_ESFERA, 'EdgeColor', [0.4 0.2 0.0], 'EdgeAlpha', 0.15);
scatter3(ax1, pos_0_x, pos_0_y, pos_0_z, 80, 'm', 'filled', 'MarkerEdgeColor', 'k');

axis(ax1, 'equal'); grid(ax1, 'on'); box(ax1, 'on'); view(ax1, 45, 20);
xlabel(ax1, 'Eje X'); ylabel(ax1, 'Eje Y'); zlabel(ax1, 'Eje Z');
title(ax1, '1. Estimación Inicial', 'FontSize', 11, 'FontWeight', 'bold');

% -------------------------------------------------------------------------
% SUBPLOT 2: RESULTADO OPTIMIZADO (Derecha - Ocupa posiciones 2 y 4)
% -------------------------------------------------------------------------
ax2 = subplot(3, 2, [2, 4]);
hold(ax2, 'on');

p1 = scatter3(ax2, H(:,1), H(:,2), H(:,3), 15, [0.2 0.4 0.8], 'filled', 'MarkerFaceAlpha', 0.5);
p2 = surf(ax2, vectoroptimo(1) + x_s*vectoroptimo(4), ...
               vectoroptimo(2) + y_s*vectoroptimo(4), ...
               vectoroptimo(3) + z_s*vectoroptimo(4), ...
               'FaceColor', [0.1 0.7 0.3], 'FaceAlpha', OPACIDAD_ESFERA, 'EdgeColor', [0.0 0.3 0.1], 'EdgeAlpha', 0.15);
p3 = scatter3(ax2, vectoroptimo(1), vectoroptimo(2), vectoroptimo(3), 80, 'r', 'filled', 'MarkerEdgeColor', 'k');

axis(ax2, 'equal'); grid(ax2, 'on'); box(ax2, 'on'); view(ax2, 45, 20);
xlabel(ax2, 'Eje X'); ylabel(ax2, 'Eje Y'); zlabel(ax2, 'Eje Z');
title(ax2, '2. Resultado Optimizado', 'FontSize', 11, 'FontWeight', 'bold');

legend(ax2, [p1, p2, p3], {'Puntos H', 'Esfera', 'Centroide'}, 'Location', 'northeastoutside');

% Sincronizar vista 3D nativa
hLink = linkprop([ax1, ax2], {'CameraPosition', 'CameraUpVector', 'CameraTarget', 'View'});
setappdata(fig, 'LinkProp', hLink);

% -------------------------------------------------------------------------
% FILA INFERIOR: TEXTOS SEPARADOS (Posición 5 e Izquierda / Posición 6 y Derecha)
% -------------------------------------------------------------------------
ax_txt1 = subplot(3, 2, 5);
axis(ax_txt1, 'off');
txt_init = sprintf('ESTADO INICIAL:\nCentroide: (%.2f, %.2f, %.2f)\nRadio: %.4f | MSE: %.4e', ...
                   pos_0_x, pos_0_y, pos_0_z, rad_0, err_0);
text(ax_txt1, 0.5, 0.5, txt_init, 'HorizontalAlignment', 'center', ...
     'VerticalAlignment', 'middle', 'FontName', 'Courier', 'FontSize', 9, ...
     'EdgeColor', [0.6 0.6 0.6], 'BackgroundColor', [0.97 0.97 0.97]);

ax_txt2 = subplot(3, 2, 6);
axis(ax_txt2, 'off');
txt_opt = sprintf('RESULTADO OPTIMIZADO:\nCentroide: (%.2f, %.2f, %.2f)\nRadio: %.4f | MSE: %.4e', ...
                  vectoroptimo(1), vectoroptimo(2), vectoroptimo(3), vectoroptimo(4), err_opt);
text(ax_txt2, 0.5, 0.5, txt_opt, 'HorizontalAlignment', 'center', ...
     'VerticalAlignment', 'middle', 'FontName', 'Courier', 'FontSize', 9, ...
     'EdgeColor', [0.6 0.6 0.6], 'BackgroundColor', [0.97 0.97 0.97]);