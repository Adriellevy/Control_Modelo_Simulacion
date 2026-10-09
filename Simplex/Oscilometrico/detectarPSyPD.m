function [PS, PD] = detectarPSyPD(uSist, uDiast, A, PrampaDig, tm)
%Dr. Mariano E. Casciaro, FICEN - Universidad Favaloro 2025.
%Aplica el método oscilométrico en una señal de amplitud oscilométrica 
%digitalizada, devolviendo el valor de Presión sistólica y diastólica. 

%Input:
%   -uSist: umbral sistólico (entre 0-1, corresponde a un % de amplitud
%   máxima de la señal de amplitud oscilométrica)
%   -uDiast: umbral diastólico (entre 0-1, corresponde a un % de amplitud
%   máxima de la señal de amplitud oscilométrica
%   -A: señal de amplitud oscilométrica digitalizada en 8 bits, muestreada 
%   de acuerdo al vector de tiempos de muestreo tm. 
%   -Prampa: señal rampa digitalizada
%   -tm: vector de tiempos de muestreo

%Output: 
%   -PS: presión sistólica, en mmHg
%   -PD: presión diastólica, en mmHg
B = 8; %Bits del conversor AD.
Pmax = 300; %mmHg, pero equivale a 1mV en el sensor elegido;

[Amax, imax] = max(A);
umbralS = int32(uSist*Amax);
umbralD = int32(uDiast*Amax);

tS = tm(A <= umbralS & tm < tm(imax)); %Detecto todos los tiempos menores a la ocurrencia de Amax
                                      %donde la Amplitud es menor o igual al umbral sistólico.  
tD = tm(A <= umbralD & tm > tm(imax)); %Detecto todos los tiempos mayores a la ocurrencia de Amax
                                      %donde la Amplitud es menor o igual al umbral diastólico.
TS = tS(end); %Considero el tiempo de sístole como el último tiempo antes de superar el umbral sistólico.
TD = tD(1);   %Considero el tiempo de diástole como primer  valor por debajo del umbral diastólico.  

%Calculo el número de cuentas en la rampa digitalizada en ambos instantes:
[~, iS] = find(tm == TS);
[~, iD] = find(tm == TD);
CS = PrampaDig(iS);
CD = PrampaDig(iD);

%Considerando el rango de trabajo elegido de 0 a 300 mmHg para Prampa, considerando
%un conversor ADC de B bits (rango 0-2^B) calculamos las presiones sistólicas y diastólicas:
PS = double(uint8(double(CS)/(2^B - 1)*Pmax)); %Cuentas/maxCuentas*300mmHg
PD = double(uint8(double(CD)/(2^B - 1)*Pmax)); %Cuentas/maxCuentas*300mmHg