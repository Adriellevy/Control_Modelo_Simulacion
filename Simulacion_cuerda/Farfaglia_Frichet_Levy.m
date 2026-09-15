%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Trabajo Práctico #2 - Control, Modelos y Simulación
%%%
%%% Simulación del desplazamiento de una perturbación en una cuerda
%%% de dos velocidades distintas mediante diferencias finitas para la
%%% ecuación de onda hiperbólica:
%%%                     c^2 * d^2(u)/dx^2 = d^2(u)/dt^2
%%% Análisis de Reflexión:
%%% Se teoriza que, al incidir la perturbación sobre la discontinuidad, 
%%% la naturaleza de la reflexión depende de la velocidad del nuevo medio. 
%%% Formalmente, se observa que si la onda incide sobre un medio de menor
%%% velocidad (C), la onda reflejada presenta una inversión de fase, es
%%% decir, cambia de signo respecto de la onda incidente. 
%%% En cambio, si incide sobre un medio de mayor velocidad (C), la onda
%%% reflejada no presenta inversión de fase y conserva el mismo signo 
%%% que la onda incidente.
%%% Por otro lado la onda transmitida se observa que si C2 es menor, el
%%% modulo disminuye mientras que de forma opuesta si C2 es mayor, el 
%%% modulo tambien lo hace.
%%% Autores:
%%%       Bautista Farfaglia
%%%       Thomas Frichet
%%%       Adriel Levy
%%%
%%% Carrera: Ingeniería Biomédica
%%% FICEN - Universidad Favaloro
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function app_simulacion_tp2()
% =========================================================================
% FUNCIÓN DE RESOLUCIÓN DE LAS ECUACIONES DIFERENCIALES
% =========================================================================
    function U = resolver_onda(x,t,c1,c2,Puntos_t,Puntos_x)
        dx = x(2)-x(1);
        dt = t(2)-t(1);
        Lambda = zeros(1,Puntos_x);
        Lambda(x <= 2/3) = c1*(dt/dx);
        Lambda(x > 2/3) = c2*(dt/dx);
        L2 = Lambda(2:end-1).^2;
        alpha = 50;
        t0 = 1;
        U = zeros(Puntos_t,Puntos_x);
        pulso = exp(-alpha*(t-t0).^2);
        U(1,1) = pulso(1);
        U(2,1) = pulso(2);
        for j = 2:Puntos_t-1
            U(j+1,1) = pulso(j+1);
            U(j+1,2:end-1) = L2.*U(j,3:end)+2*(1-L2).*U(j,2:end-1)+L2.*U(j,1:end-2)-U(j-1,2:end-1);
            U(j+1,end) = 0;
        end
    end

% =========================================================================
% =========================================================================
% NOTA: Es aconsejable ignorar todo el bloque de código a continuación.
% Corresponde pura y exclusivamente a la construcción de la Interfaz
% Gráfica de Usuario y no aporta ninguna modificación ni
% importancia a la lógica de resolución de las ecuaciones diferenciales.
% =========================================================================
% =========================================================================

    fig = figure('Name','Simulación TP#2 - Cuerda con Discontinuidad','Position',[100,100,900,550],'MenuBar','none','NumberTitle','off','Resize','off');
    pnl_ctrl = uipanel('Parent',fig,'Position',[0.02,0.05,0.28,0.9],'Title','Parámetros de Simulación','FontSize',11,'FontWeight','bold');
    ax = axes('Parent',fig,'Position',[0.38,0.12,0.58,0.78]);
    title(ax,'Esperando inicio de simulación...');
    xlabel(ax,'Posición x (m)');
    ylabel(ax,'Amplitud u(t,x)');
    grid(ax,'on');
    axis(ax,[0 1 -1 1.5]);

    uicontrol(pnl_ctrl,'Style','text','Position',[10,420,220,20],'String','Seleccione los casos a comparar:','HorizontalAlignment','left','FontWeight','bold');
    chk1 = uicontrol(pnl_ctrl,'Style','checkbox','Position',[15,390,220,20],'String','Caso 1: c2 = c1 (Misma vel.)','Value',1,'ForegroundColor','b');
    chk2 = uicontrol(pnl_ctrl,'Style','checkbox','Position',[15,360,220,20],'String','Caso 2: c2 = 0.5*c1 (Más lenta)','Value',0,'ForegroundColor','r');
    chk3 = uicontrol(pnl_ctrl,'Style','checkbox','Position',[15,330,220,20],'String','Caso 3: c2 = 1.5*c1 (Más rapido)','Value',0,'ForegroundColor','#77AC30');

    uicontrol(pnl_ctrl,'Style','text','Position',[10,270,220,20],'String','Velocidad de reproducción:','HorizontalAlignment','left','FontWeight','bold');
    menu_vel = uicontrol(pnl_ctrl,'Style','popupmenu','Position',[15,240,200,25],'String',{'Lenta (1x)','Normal (3x)','Rápida (6x)','Muy Rápida (10x)'},'Value',2);

    btn_iniciar = uicontrol(pnl_ctrl,'Style','pushbutton','Position',[35,150,160,40],'String','INICIAR / REINICIAR','FontSize',10,'FontWeight','bold','Callback',@iniciar_animacion);
    btn_detener = uicontrol(pnl_ctrl,'Style','pushbutton','Position',[35,90,160,40],'String','DETENER','FontSize',10,'Enable','off');
    simulacion_activa = false;

    function iniciar_animacion(~,~)
        if ~(chk1.Value || chk2.Value || chk3.Value)
            warndlg('Debe seleccionar al menos un caso para simular.','Aviso');
            return;
        end
        btn_iniciar.Enable = 'off';
        btn_detener.Enable = 'on';
        btn_detener.Callback = @(~,~) detener_simulacion();
        simulacion_activa = true;
        Puntos_t = 1001;
        Puntos_x = 201;
        xL = 1;
        x = linspace(0,xL,Puntos_x);
        t = linspace(0,8,Puntos_t);
        c1 = 0.33;
        saltos = [1,3,6,10];
        salto = saltos(menu_vel.Value);

        if chk1.Value, U1 = resolver_onda(x,t,c1,c1,Puntos_t,Puntos_x); end
        if chk2.Value, U2 = resolver_onda(x,t,c1,c1*0.5,Puntos_t,Puntos_x); end
        if chk3.Value, U3 = resolver_onda(x,t,c1,c1*1.5,Puntos_t,Puntos_x); end

        for j = 1:salto:Puntos_t
            if ~simulacion_activa || ~isgraphics(ax)
                break;
            end
            cla(ax);
            hold(ax,'on');
            xline(ax,2/3,'k--','Discontinuidad','LineWidth',1.5,'LabelVerticalAlignment','bottom');
            nombres_leyenda = {};

            if chk1.Value
                plot(ax,x,U1(j,:),'b','LineWidth',2);
                nombres_leyenda{end+1} = 'Caso 1 (c2=c1)';
            end
            if chk2.Value
                plot(ax,x,U2(j,:),'r','LineWidth',2);
                nombres_leyenda{end+1} = 'Caso 2 (c2=0.5*c1)';
            end
            if chk3.Value
                plot(ax,x,U3(j,:),'Color','#77AC30','LineWidth',2);
                nombres_leyenda{end+1} = 'Caso 3 (c2=1.5*c1)';
            end

            axis(ax,[0 xL -1 1.5]);
            xlabel(ax,'Posición x (m)');
            ylabel(ax,'Amplitud u(t,x)');
            title(ax,sprintf('Propagación de Onda | Tiempo t = %.2f s',t(j)));
            legend(ax,['Discontinuidad',nombres_leyenda],'Location','northeast');
            grid(ax,'on');
            drawnow;
        end

        if isgraphics(btn_iniciar)
            btn_iniciar.Enable = 'on';
            btn_detener.Enable = 'off';
            simulacion_activa = false;
        end
    end

    function detener_simulacion()
        simulacion_activa = false;
    end
end