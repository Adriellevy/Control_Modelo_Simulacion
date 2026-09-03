function [t, y] = rk4(odefun, tspan, y0, h)
    % rk4: Método de Runge-Kutta de 4to orden para resolver EDOs.
    % Es una alternativa explícita de paso fijo al solver ode23 de MATLAB.
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
        
        k1 = odefun(ti, yi);
        k2 = odefun(ti + hi/2, yi + hi/2 * k1);
        k3 = odefun(ti + hi/2, yi + hi/2 * k2);
        k4 = odefun(ti + hi, yi + hi * k3);
        
        y(i+1, :) = (yi + (hi/6) * (k1 + 2*k2 + 2*k3 + k4))';
    end
end
