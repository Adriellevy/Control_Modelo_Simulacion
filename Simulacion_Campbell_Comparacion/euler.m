function [t, y] = euler(odefun, tspan, y0, h)
    % euler: Método de Euler (1er orden) explícito para resolver EDOs.
    % 
    % odefun: Función de la EDO (pder = f(t, p))
    % tspan:  Vector de tiempo [t0, tf]
    % y0:     Condiciones iniciales (vector columna)
    % h:      Paso de integración (ej. 0.001)

    t0 = tspan(1);
    tf = tspan(end);
    t = (t0:h:tf)';
    
    % Asegurarnos de alcanzar exactamente el tf en el último paso si es posible
    if t(end) < tf
        t = [t; tf];
    end
    
    n = length(t);
    m = length(y0);
    y = zeros(n, m);
    y(1, :) = y0';

    for i = 1:(n-1)
        ti = t(i);
        yi = y(i, :)';
        
        hi = t(i+1) - t(i); % paso actual (puede ser distinto al final)
        
        y(i+1, :) = (yi + hi * odefun(ti, yi))';
    end
end
