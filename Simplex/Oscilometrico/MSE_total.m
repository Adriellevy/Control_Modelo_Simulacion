function costo = MSE_total(params, A, PrampaDig, tm, PS_GS, PD_GS)
    uSist  = params(1);
    uDiast = params(2);
    nSignals = size(A,1);
    PS_vals = zeros(1, nSignals);
    PD_vals = zeros(1, nSignals);
    
    % 1. Penalización para mantener los umbrales en un rango físico válido (0 a 1)
    if uSist <= 0 || uSist >= 1 || uDiast <= 0 || uDiast >= 1
        costo = 1e6; % Costo altísimo si el algoritmo se va de los límites
        return;
    end

    for i = 1:nSignals
        Ai   = A(i,:);
        Pi   = PrampaDig(i,:);
        tmi  = tm(i,:);
        [PS_vals(i), PD_vals(i)] = detectarPSyPD(uSist, uDiast, Ai, Pi, tmi);
    end
    
    % Errores
    Error_PS = PS_vals-PS_GS;
    Error_PD=PD_vals-PD_GS;

    % 2. Elevar al cuadrado para que sea realmente un MSE
    msePS = mean(Error_PS.^2); 
    msePD = mean(Error_PD.^2);
    
    % Costo total
    costo = msePS + msePD;
end