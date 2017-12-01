function [] = plot_scissor(x_ac,l_h,c,V_h_V,de_da,C_L_h,C_La_h,C_L_Ah,C_La_Ah,C_m_ac)
%Plot scissor, plots the scissor plot describing the stability and
%controllabitiy of and aircraft and can be used to size the tail
%   Input variables
% x_ac      Aerodynamic centre of the aircraft less tail
% l_h       Tail arm
% c         Cord
% V_h_V     Tail/wing speed ratio (0.85 for fuselage mounted, 0.95 for fin
% mounted, 1 for canard of T-tail)
% de_da     downwash effect of wing on tail
% C_L_h     Lift rate coefficient of the wing
% C_La_h    Lift rate coefficient of the horizontal tail
% C_L_Ah    Aircraft less tail lift coefficient
% C_La_Ah   Aircraft less tail lift rate coefficient
% C_m_ac    Zero Lift pitching moment coefficient of the aircraft without tail

% example inputs:
% plot_scissor(0.132,10,2,1,0.336,-0.696,3.38,6.226,6.760,-1.48) normal config
% plot_scissor(0.132,-3,2,1,0,1.3,3,0.9,6,-0.45) canard config


SM = 0.05; %stability margin
acc = 0.01; %accuracy of plot
max_ShS = 1.5; %max area ratio for plotting
ShS = 0:acc:max_ShS; %set surface area ratio vector

% stability curve
stab_x_cg = x_ac+(C_La_h/C_La_Ah)*(1-de_da)*(ShS)*(l_h/c)*(V_h_V^2)-SM;

%controllability curve
cont_x_cg = x_ac-(C_m_ac/C_L_Ah)+(C_L_h/C_L_Ah)*(ShS)*(l_h/c)*(V_h_V^2);

x_min = min([stab_x_cg cont_x_cg]);
x_max = max([stab_x_cg cont_x_cg]);

figure
hold on
%% instability area plotting
if ((C_La_h/C_La_Ah)*(1-de_da)*(l_h/c)*(V_h_V^2))<0
    st=area([min(stab_x_cg) x_max],[max_ShS max_ShS]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
end

if (C_L_h/C_L_Ah)*(l_h/c)*(V_h_V^2)>0 % incontrollability area plotting (only this condition has to be here because of the white area's)
    st=area([x_min max(cont_x_cg)],[max_ShS max_ShS]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
    
    st=area([min(cont_x_cg) max(cont_x_cg)],[0 max_ShS]);
    st.FaceAlpha = 1;
    st.LineStyle = 'none';
    st.FaceColor = 'white';
    
    if not(x_max==max(cont_x_cg))
        st=area([max(cont_x_cg) x_max],[max_ShS max_ShS]);
        st.FaceAlpha = 1;
        st.LineStyle = 'none';
        st.FaceColor = 'white';
    end
end

if ((C_La_h/C_La_Ah)*(1-de_da)*(l_h/c)*(V_h_V^2))<0
    st=area([min(stab_x_cg) max(stab_x_cg)],[max_ShS 0]);
    st.FaceAlpha = 1;
    st.LineStyle = 'none';
    st.FaceColor = 'white';
    
    if not(x_min==min(stab_x_cg))
        st=area([x_min min(stab_x_cg)],[max_ShS max_ShS]);
        st.FaceAlpha = 1;
        st.LineStyle = 'none';
        st.FaceColor = 'white';
    end
end

if ((C_La_h/C_La_Ah)*(1-de_da)*(l_h/c)*(V_h_V^2))==0
    st=area([x_ac-SM x_max],[max_ShS max_ShS]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
elseif ((C_La_h/C_La_Ah)*(1-de_da)*(l_h/c)*(V_h_V^2))>0
    st=area([x_ac-SM max(stab_x_cg)],[0 max_ShS]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
    
    if not(x_max==max(stab_x_cg))
        st=area([max(stab_x_cg) x_max],[max_ShS max_ShS]);
        st.FaceAlpha = 0.2;
        st.LineStyle = 'none';
        st.FaceColor = 'red';
    end
end

%% incontrollability area plotting
if (C_L_h/C_L_Ah)*(l_h/c)*(V_h_V^2)<0
    st=area([min(cont_x_cg) max(cont_x_cg)],[max_ShS 0]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
    
    if not(x_min==min(cont_x_cg))
        st=area([x_min min(cont_x_cg)],[max_ShS max_ShS]);
        st.FaceAlpha = 0.2;
        st.LineStyle = 'none';
        st.FaceColor = 'red';
    end
elseif (C_L_h/C_L_Ah)*(l_h/c)*(V_h_V^2)==0
    st=area([x_min min(cont_x_cg)],[max_ShS max_ShS]);
    st.FaceAlpha = 0.2;
    st.LineStyle = 'none';
    st.FaceColor = 'red';
end

stab = plot(stab_x_cg,ShS,'LineWidth',2,'color','b');
cont = plot(cont_x_cg,ShS,'LineWidth',2,'color','r');

legend([stab,cont],'Stability','Controllability','Location','Southeast')
xlabel('x_{cg} / MAC')
ylabel('S_{h} / S')
hold off
end
