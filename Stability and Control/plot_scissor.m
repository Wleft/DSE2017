function [] = plot_scissor(x_ac,l_h,c,V_h_V,de_da,C_L_h,C_La_h,C_L_Ah,C_La_Ah,C_m_ac)
%Plot scissor, plots the scissor plot describing the stability and
%controllabitiy of and aircraft and can be used to size the tail
%   Input variables
% x_cg      Centre of gravity location on MAC
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

% example input: plot_scissor(0.132,10,2,1,0.336,-0.696,5.797,6.226,6.760,-1.48)



SM = 0.05; %stability margin
acc = 0.01; %accuracy of plot
ShS = 0:acc:1; %set surface area ratio vector

% stability curve
stab_x_cg = x_ac+(C_La_h/C_La_Ah)*(1-de_da)*(ShS)*(l_h/c)*(V_h_V)-SM;

%controllability curve
cont_x_cg = x_ac-(C_m_ac/C_L_Ah)+(C_L_h/C_L_Ah)*(ShS)*(l_h/c)*(V_h_V);

%%

figure
hold on
plot(stab_x_cg,ShS)
plot(cont_x_cg,ShS)

xlabel('x_{cg} / MAC')
ylabel('S_{h} / S')
hold off

end

