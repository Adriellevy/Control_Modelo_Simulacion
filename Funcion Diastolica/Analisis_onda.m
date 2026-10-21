function resultados = Analisis_Onda(tipo, umbral, varargin)
    % Función para extraer el frente de onda (flanco ascendente) y graficar regresiones.
    % Es a prueba de fallos y escala a los máximos reales si los datos no saturan el umbral.
    
    if strcmp(tipo, '2D')
        x = varargin{1};
        t = varargin{2};
        V = varargin{3}; % Matriz de velocidades (Z)
        
        % Seguro anti-fallos: Si los datos no superan el umbral, usar el 80% del máximo
        max_v = max(V(:));
        if max_v < umbral
            umbral = max_v * 0.8;
        end
        
        % Buscar el primer instante (flanco ascendente) que cruza el umbral para cada espacio
        t_sat = NaN(1, length(x));
        x_sat = NaN(1, length(x));
        for i = 1:length(x)
            idx_saturacion = find(V(:, i) >= umbral, 1, 'first');
            if ~isempty(idx_saturacion)
                t_sat(i) = t(idx_saturacion);
                x_sat(i) = x(i);
            end
        end
        
        % Filtrar puntos nulos
        idx_validos = ~isnan(t_sat);
        t_val = t_sat(idx_validos);
        x_val = x_sat(idx_validos);
        
        if length(x_val) > 1
            % Regresión Lineal: x(t) = Vp * t + b
            p = polyfit(t_val, x_val, 1);
            x_fit = polyval(p, t_val);
            
            % Graficar la recta sobre la superficie (en z=max_v para que se vea por encima)
            plot3(x_fit, t_val, repmat(max_v + 5, 1, length(x_fit)), 'r-', 'LineWidth', 3);
            % Graficar los puntos de saturación detectados
            plot3(x_val, t_val, repmat(max_v + 5, 1, length(x_val)), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 4);
            
            resultados = p; % Devuelve [Vp, ordenada_al_origen]
        else
            resultados = [];
        end
        
    elseif strcmp(tipo, '3D')
        X = varargin{1}; Y = varargin{2}; Z = varargin{3};
        Vx = varargin{4}; Vy = varargin{5}; Vz = varargin{6};
        num_tiempos = size(Vx, 2);
        
        % Calcular magnitudes
        V_mag = sqrt(Vx.^2 + Vy.^2 + Vz.^2);
        max_v = max(V_mag(:));
        if max_v < umbral
            umbral = max_v * 0.8;
        end
        
        % Matriz de celdas (Cell Array) para guardar {Caras, Vértices} de cada instante
        resultados = cell(num_tiempos, 2); 
        
        % Calcular la superficie (alphaShape) fotograma por fotograma
        for i = 1:num_tiempos
            idx_saturacion = find(V_mag(:, i) >= umbral);
            
            % Se necesitan al menos 4 puntos para hacer un volumen 3D
            if length(idx_saturacion) > 4
                % Crear la forma 3D solo con los puntos de este instante temporal
                shp = alphaShape(X(idx_saturacion), Y(idx_saturacion), Z(idx_saturacion));
                
                % Extraer la geometría de la malla (caras y vértices)
                [caras, vertices] = boundaryFacets(shp);
                
                % Guardar en los resultados
                resultados{i, 1} = caras;
                resultados{i, 2} = vertices;
            else
                % Si el flujo es muy bajo en este instante, no hay superficie
                resultados{i, 1} = [];
                resultados{i, 2} = [];
            end
        end
    end
end