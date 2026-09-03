function [P, V, t] = Pres_Vol(Ciclo)

% Sintaxis [P,V]=Pres_Vol(Ciclo)
% P = Vector de Presiones
% V= Volumen del ventrículo izquierdo
% Ciclo = cantidad de períodos a evaluar por la ecuación diferencial.
% Resolución del Paper "A Pulsative Cardiovascular Computer Model for 
% teaching Heart-Blood Vessel Interaction" de Cambell, Zegeln & Rigas
% Universidad Favaloro
% Ing. Franco Martin Pessana
% Octubre 2002

if nargin<1		%number of arguments input
  Ciclos = 5;
else
  Ciclos = Ciclo;
end
%%%%%%%% R2 Original
t0 = 0;
tf = 0.62;
tf = tf*(1+eps);
p0 = [30 30 40 30 32]'; %condiciones iniciales de las presiones
% p0 = [60 4.55 2 10 500]';
options = odeset('RelTol',1e-4,'AbsTol',1e-3);
%options=[];
for i=1:Ciclos
   [t,P]=ode23('Ec_difPV1',[t0 tf],p0,options);
   %P es una matriz donde en cada fila (de 5 columnas P1 a P5) estan las soluciones para cada instante t
  t0=t(size(t,1));
  t0=0;
  p0=P(size(P,1),:)';%tomo la última solución como condición inicial para el próximo ciclo
end
% Gráficos De Presión en cada una de las Compliances
figure (1);
plot(t,P(:,1));
ylabel('P1(t) [mmHg]');
xlabel('t')
figure (2);
plot(t,P(:,2));
ylabel('P2(t) [mmHg]');
xlabel('t')
figure (3);
plot(t,P(:,3));
ylabel('P3(t) [mmHg]');
xlabel('t')
figure (4);
plot(t,P(:,4));
ylabel('P4(t) [mmHg]');
xlabel('t')
figure (5);
plot(t,P(:,5));
ylabel('P5(t) [mmHg]');
xlabel('t')

for n=1:size(t,1)
   if t(n)<0.39
     C5(n) = 2e-3-1.875e-3*sin(pi*t(n)/0.39);
   else
     C5(n) = 2e-3;
   end
end
V = C5'.*P(:,5)*1334;
figure (6);
plot(V,P(:,5));
title('Curva Presión-Volumen');
ylabel('Presión [mmHg]');
xlabel('Volumen [cc]');

