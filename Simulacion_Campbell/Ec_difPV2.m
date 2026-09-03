function pder=Ec_DifPV2(t,p)

% Ecuación diferencial llamada por Pres_Vol para la resolución del 
% la ecuación de estado del modelo de circulación propuesto
% por Cambell. El sistema posee compliances variables y diodos
% ideales.
% Universidad Favaloro
% Ing. Franco martín Pessana
% Octubre de 1998

% Declaración de las variables del sistema

R1 = 250; 
R2 = 3800/2;
R3 = 350;
R4 = 625;
R5 = 200;
C1 = 1.9e-4;
C2 = (0.0326);
C4 = 8.2e-3; 
if t<0.39
    C5 = 2e-3-1.875e-3*sin(pi*t/0.39);
    C5d = -1.875e-3*pi/0.39*cos(pi*t/0.39);
    C3 = C5/3;
    C3d = C5d/3;
else
    C5 = 2e-3;
    C5d = 0;
    C3 = C5/3;
    C3d = 0;
end

% Definición de los Diodos Ideales

if p(5)>p(1)
   V1 = 1;
else
   V1 = 0;
end
if p(2)>p(3)
   V2 = 1;
else
   V2 = 0;
end
if p(3)>p(4)
   V3 = 1;
else
   V3 = 0;
end
if p(4)>p(5)
   V4 = 1;
else
   V4 = 0;
end

% Declaración de funciones y variables de la matriz derivada

f11 = -(V1/R1+1/R2)/C1; 
f12 = 1/(R2*C1);
f15 = V1/(R1*C1);
f21 = 1/(R2*C2);
f22 = -(1/R2+V2/R3)/C2;
f23 = V2/(R3*C2);
f32 = V2/(R3*C3);
f33 = -(V2/R3+V3/R4+C3d)/C3;
f34 = V3/(R4*C3);
f43 = V3/(R4*C4);
f44 = -(V3/R4+V4/R5)/C4;
f45 = V4/(R5*C4);
f51 = V1/(R1*C5);
f54 = V4/(R5*C5);
f55 = -(V1/R1+V4/R5+C5d)/C5;

matriz = [f11 f12 0 0 f15;f21 f22 f23 0 0;0 f32 f33 f34 0;...
                          0 0 f43 f44 f45;f51 0 0 f54 f55];
pder = matriz*p;
