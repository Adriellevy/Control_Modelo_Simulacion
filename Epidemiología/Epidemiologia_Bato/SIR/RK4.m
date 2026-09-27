function [t, y] = RK4(odefun, tspan, y0, dt)
    % Rk4_solver integra un sistema de EDOs usando Runge-Kutta 4 clásico.
    t = tspan(1):dt:tspan(2);
    N_steps = length(t);
    
    y = zeros(N_steps, length(y0));
    y(1, :) = y0(:)';
    
    for n = 1:(N_steps - 1)
        tn = t(n);
        yn = y(n, :)';
        
        k1 = odefun(tn,            yn);
        k2 = odefun(tn + 0.5 * dt, yn + 0.5 * dt * k1);
        k3 = odefun(tn + 0.5 * dt, yn + 0.5 * dt * k2);
        k4 = odefun(tn + dt,       yn + dt * k3);
        
        y_next = yn + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4);
        y(n + 1, :) = y_next';
    end
end