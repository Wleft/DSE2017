function []=plot_flight_envelope(CL_max,WS,V_B,V_C,V_D,C_L_alpha,c,option)
% example plot_flight_envelope(1.8,110.25,15.24,16,1.25*16,5,0.8)
% inputs are
% CL_max; maximum lift coefficient
% WS; Weight over surface area (wing loading)
% V_B; High angle of attack speed
% V_C; Cruise speed
% V_D; Dive speed
% C_L_alpha; Change in lift coefficient by angle of attack
% c; cord
% option: graphing options
% options for this function are:
% 1 plot both maneuver and gust load diagram in one figure
% 2 plot only maneuver load diagram
% 3 plot only gust load diagram

if exist('option')==0
    option = 1;
end
%% errors messages
if V_C>0.8*V_D
    error('V_cruise should be smaller of equal to 0.8 * V_dive')
elseif or(or(CL_max<0,WS<0),or(V_C<0,V_D<0))
    error('variables should be larger than 0')
else
    %% this script is for graphing the flight envelope diagrams, the maneuver load diagram and the gust load diagram
    
    %%Parameters straight from requirements
    
    % requirement speed ranges [m/s]
    req_V_stall = [15, 20]/ 1.94384; %knot to m/s
    req_V_cruise = [30, 40]/ 1.94384;
    rangereq = 1; % set to 1 to insert speed requirements range bars in plots
    
    % required load factors [g]
    req_N_lim = [4, -2];
    req_N_ult = [6, -3];
    
    % required wind gusts [m/s]
    req_V_gust = 10.7; % 10.7 m/s = 5 beaufort
    
    
    %% constants
    acc = 0.1; % number of datapoints
    rho = 1.225; % density of air at sealevel
    g = 9.81; % gravitational constant
    dx = 0.25; dy = 0.25; % displacement so the text does not overlay the data points
    
    if or(option==1,option==2)
        %% the maneuver load diagram
        % calculate speeds
        V_S = sqrt(WS/(0.5*rho*CL_max)); %determine V_stall
        V_A = sqrt((req_N_lim(1)*WS)/(0.5*rho*CL_max)); %determine V_A from limit load requirement
        V_H = sqrt((req_N_lim(2)*WS)/(-0.5*rho*CL_max));
        
        if V_S>V_C
            error('V_stall can not be larger than V_cruise')
        end
        
        % make speed vectors
        V_0A = 0:acc:V_A; % make speed vector from 0 to V_A
        V_0H = 0:acc:V_H;
        
        % make load vectors
        N_0A = 0.5*rho*CL_max*V_0A.^2/WS; % Calc N_01
        N_0H = -0.5*rho*CL_max*V_0H.^2/WS;
        
        % make vector to plot points
        MLD_points = [0 V_A V_D V_H V_C V_D;0 req_N_lim(1) req_N_lim(1) req_N_lim(2) req_N_lim(2) 0];
        MLD_points_text = cellstr(["A";"D";"H";"F";"E";"V_{s}";"V_{A}";"V_{C}";"V_{D}"]);
        MLD_points_text_x = [MLD_points(1,2:end)+dx,V_S,V_A,V_C+1,V_D+2];
        MLD_points_text_x(4) = MLD_points_text_x(4)+2*dx;
        MLD_points_text_x(5) = MLD_points_text_x(5)-2;
        MLD_points_text_y = [MLD_points(2,2:end)+dy,-0.25,-0.25,0.25,-0.25];
        MLD_points_text_y(4) = MLD_points_text_y(4)-dy;
    end
    if or(option==1,option==3)
        %% gust load diagram
        mu = (2*WS)/(rho*g*c*C_L_alpha); % equivelent mass ratio
        K = (0.8*mu)/(5.3+mu); % load alleviation factor for subsonic
        %K = (mu^1.03)/(6.95+mu^1.03); % load alleviation factor for supersonic
        
        % indexing part for statictical gust velocities
        alt = 1000*0.3048; % altitude transformed to meter
        if alt>50000*0.3048
            delta_u_ft = [38 25 12.5]; % statistical gust velocity [high angle, cruise, dive]
        elseif alt<20000*0.3048
            delta_u_ft = [26.25 26.25 26.25]; %[66 50 25];
        else
            delta_u_ft(1)=(66-38)/30000*(alt-20000)+38;
            delta_u_ft(2)=(50-25)/30000*(alt-20000)+25;
            delta_u_ft(3)=(25-12.5)/30000*(alt-20000)+12.5;
        end
        delta_u = delta_u_ft*0.3048; % convert to meter
        
        u=K*delta_u; % gust velocity
        V=[V_B V_C V_D]; % Velocty vector
        delta_N = (rho*V.*u*C_L_alpha)/(2*WS); % load change due to gust
        N_gust(1,:) = 1+delta_N;
        N_gust(2,:) = 1-delta_N;
        if V_B<min(V_A,V_S*sqrt(N_gust(1,2)))
            error('V_B is too small')
        end
        GLD_text = cellstr(["B'";"C'";"D'";"G'";"F'";"E'";"V_{B}"]);
        GLD_text_x = [V+dx,V+dx,V_B+1];
        GLD_text_y = [N_gust(1,:)+dy,N_gust(2,:)-dy,0.25];
    end
    
    %% Make the graph
    
    if option==2
        figure
        hold on
        % maneuver load diagram
        plot(V_0A,N_0A,'Color',[0 0.4470 0.7410])
        plot(V_0H,N_0H,'Color',[0 0.4470 0.7410])
        scatter(MLD_points(1,:),MLD_points(2,:),'filled','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        text(MLD_points_text_x,MLD_points_text_y,MLD_points_text)
        axis([0 V_D*1.1 req_N_lim(2)-1 req_N_lim(1)+1])
        line([V_H V_C], [req_N_lim(2) req_N_lim(2)])
        line([V_A V_D], [req_N_lim(1) req_N_lim(1)])
        line([V_C V_D], [req_N_lim(2) 0])
        line([V_D V_D], [0 req_N_lim(1)])
        line([0 V_D*1.1], [1 1],'LineStyle','-.') % stall line
        line([V_S V_S], [0 1],'LineStyle','--') % stall speed line
        line([V_C V_C], [0 req_N_lim(2)],'LineStyle','--') % cruise speed line
        line([V_A V_A], [0 req_N_lim(1)],'LineStyle','--') % V_A line
        
        if rangereq==1
            % stall range
            ar = area(req_V_stall,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_stall,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            % cruise range
            ar = area(req_V_cruise,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_cruise,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
        end
        
        x=xlabel('Reference airspeed V [m/s]');
        set(x, 'position', get(x,'position')+[8,0,0]);
        ylabel('Load factor N [-]');
        
        ax = gca;
        ax.XAxisLocation = 'origin';
        hold off
    elseif option==3
        figure
        hold on
        scatter([V_B V_C V_D],N_gust(1,:),'filled','k')
        scatter([V_B V_C V_D],N_gust(2,:),'filled','k')
        text(GLD_text_x,GLD_text_y,GLD_text)
        text([V_C+1 V_D+2],[0.25 0.25],cellstr(["V_{C}";"V_{D}"]))
        axis([0 V_D*1.1 req_N_lim(2)-1 req_N_lim(1)+1])
        line([0 V_B], [1 N_gust(1,1)],'LineStyle','-')
        line([0 V_B], [1 N_gust(2,1)],'LineStyle','-')
        line([V_B V_C], [N_gust(1,1) N_gust(1,2)],'LineStyle','-')
        line([V_B V_C], [N_gust(2,1) N_gust(2,2)],'LineStyle','-')
        line([V_C V_D], [N_gust(1,2) N_gust(1,3)],'LineStyle','-')
        line([V_C V_D], [N_gust(2,2) N_gust(2,3)],'LineStyle','-')
        line([V_D V_D], [N_gust(1,3) N_gust(2,3)],'LineStyle','-')
        
        line([0 V_C], [1 N_gust(1,2)],'LineStyle','--')
        line([0 V_C], [1 N_gust(2,2)],'LineStyle','--')
        line([0 V_D], [1 N_gust(1,3)],'LineStyle','--')
        line([0 V_D], [1 N_gust(2,3)],'LineStyle','--')
        
        line([V_B V_B], [N_gust(1,1) N_gust(2,1)],'LineStyle','--')
        line([V_C V_C], [N_gust(1,2) N_gust(2,2)],'LineStyle','--')
        
        if rangereq==1
            % stall range
            ar = area(req_V_stall,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_stall,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            % cruise range
            ar = area(req_V_cruise,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_cruise,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
        end
        
        x=xlabel('Reference airspeed V [m/s]');
        set(x, 'position', get(x,'position')+[8,0,0]);
        ylabel('Load factor N [-]');
        
        ax = gca;
        ax.XAxisLocation = 'origin';
        hold off
    end
    
    if option==1
        figure
        hold on
        
        if rangereq==1
            % stall range
            ar = area(req_V_stall,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_stall,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            % cruise range
            ar = area(req_V_cruise,[req_N_lim(1)+1 req_N_lim(1)+1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
            ar = area(req_V_cruise,[req_N_lim(2)-1 req_N_lim(2)-1]);
            ar.FaceAlpha = 0.2;
            ar.LineStyle = 'none';
            ar.FaceColor = 'green';
        end
        
        % maneuver load diagram
        plot(V_0A,N_0A,'Color',[0 0.4470 0.7410])
        plot(V_0H,N_0H,'Color',[0 0.4470 0.7410])
        scatter(MLD_points(1,:),MLD_points(2,:),'filled','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        text(MLD_points_text_x,MLD_points_text_y,MLD_points_text)
        text(GLD_text_x,GLD_text_y,GLD_text)
        axis([0 V_D*1.1 req_N_lim(2)-1 req_N_lim(1)+1])
        line([V_H V_C], [req_N_lim(2) req_N_lim(2)])
        line([V_A V_D], [req_N_lim(1) req_N_lim(1)])
        line([V_C V_D], [req_N_lim(2) 0])
        line([V_D V_D], [0 req_N_lim(1)])
        line([0 V_D*1.1], [1 1],'LineStyle','-.') % stall line
        line([V_S V_S], [0 1],'LineStyle','--') % stall speed line
        %line([V_C V_C], [0 req_N_lim(2)],'LineStyle','--') % cruise speed line
        line([V_A V_A], [0 req_N_lim(1)],'LineStyle','--') % V_A line
        
        scatter([V_B V_C V_D],N_gust(1,:),'filled','k')
        scatter([V_B V_C V_D],N_gust(2,:),'filled','k')
        axis([0 V_D*1.1 req_N_lim(2)-1 req_N_lim(1)+1])
        
        line([0 V_B], [1 N_gust(1,1)],'LineStyle','-','Color','k')
        line([0 V_B], [1 N_gust(2,1)],'LineStyle','-','Color','k')
        line([V_B V_C], [N_gust(1,1) N_gust(1,2)],'LineStyle','-','Color','k')
        line([V_B V_C], [N_gust(2,1) N_gust(2,2)],'LineStyle','-','Color','k')
        line([V_C V_D], [N_gust(1,2) N_gust(1,3)],'LineStyle','-','Color','k')
        line([V_C V_D], [N_gust(2,2) N_gust(2,3)],'LineStyle','-','Color','k')
        line([V_D V_D], [N_gust(1,3) N_gust(2,3)],'LineStyle','-','Color','k')
        
        line([V_B V_B], [N_gust(1,1) N_gust(2,1)],'LineStyle','--')
        line([V_C V_C], [N_gust(1,2) N_gust(2,2)],'LineStyle','--')
        
        x=xlabel('Reference airspeed V [m/s]');
        set(x, 'position', get(x,'position')+[8,0,0]);
        ylabel('Load factor N [-]');
        
        ax = gca;
        ax.XAxisLocation = 'origin';
        hold off
        
        
    end
end