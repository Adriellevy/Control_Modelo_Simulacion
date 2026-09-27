%MIB - FICEN - Universidad Favaloro - 2018
%MECasciaro
function dydt = modeloSIR(t, y, beta, gamma)

%t: tiempo
%y: vector de variables: y = (S, I, R), de acuerdo al modelo: 
%   S' = -beta*S*I   ->   beta=S'/S*I
%   I' = beta*S*I - gamma*I 
%   R' = gamma*I 
%   
%   donde:
%   S: poblaci�n suceptible
%   I: poblaci�n infectada/infecciosa
%   R: poblaci�n recuperada/retirada

dydt = [-beta*y(1)*y(2); beta*y(1)*y(2) - gamma*y(2); gamma*y(2)];
