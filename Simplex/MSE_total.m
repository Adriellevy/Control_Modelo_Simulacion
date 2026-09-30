function costo = MSE_total(params, A, PrampaDig, tm, PS_GS, PD_GS,Error_PS,Error_PD)
    uSist  = params(1);
    uDiast = params(2);
    nSignals = size(A,1);
    PS_vals = zeros(1, nSignals);
    PD_vals = zeros(1, nSignals);

    for i = 1:nSignals
        Ai   = A(i,:);
        Pi   = PrampaDig(i,:);
        tmi  = tm(i,:);
        [PS_vals(i), PD_vals(i)] = detectarPSyPD(uSist, uDiast, Ai, Pi, tmi);
    end
    
    % MSE para PS y PD
    msePS = mean(Error_PS);
    msePD = mean(Error_PD);

    % Costo total
    costo = msePS+msePD;
end