%% This code solves the Area ratio mach number relation
% Author : Arif Hossain - 10/10/2015

clear all; close all

design = input('Design Mach number of the Nozzle (0<M<5):  ');
L = input('Length of the Nozzle (inch) :  ');    % Noxxle diverging section length;
d_inlet = input('Throat diameter (inch) :  ');

M = (0.01:0.001:5); % Mach number range
gama = 1.4;
A = 2/(gama+1);
B = (gama-1)/2;
C = (gama+1)/(gama-1);

% Area Mach Relation
AR = sqrt((1./M.^2).*(A*(1+B*M.^2)).^C);
i = find(M>=1,1);
k = find(M>=design,1); 
figure(1);
if design < 1
    plot(AR(1:i),M(1:i), 'linewidth',2);
    hold on
    scatter(AR(k),M(k),'r','linewidth',2)
    xlabel('A/A^*','fontsize',14)
    ylabel('M','fontsize',14)
    set(gca,'fontsize',13)
    title('Area Mach Relation (Subsonic design)')
    grid on
    legend ('Subsonic design','Design point')
    xlim([0,10]);
    ylim([0,1]);

else
    plot(AR(i:end),M(i:end), 'linewidth',2);
    hold on
    scatter(AR(k),M(k),'r','linewidth',2)

    xlabel('A/A^*','fontsize',14)
    ylabel('M','fontsize',14)
    set(gca,'fontsize',13)
    title('Area Mach Relation (Supersonic design)')
    grid on
    legend ('Supersonic design','Design point','location','southeast')
end

%% Nozzle profile
% Considering a fifth order polinomial
% y = ax^5 + bx^4 + cx^3 + dx^2 + ex + f;
% Boundary condition : y(0) = d_inlet, y(L) = d_outlet
% Boundary condition : y'(0)=y"(0)=y'(L)=y"(L)=0 

% design = input('Design Mach number of the Nozzle :  ');
% L = input('Length of the Nozzle :  ');    % Noxxle diverging section length;
% d_inlet = input('Throat diameter :  ');

j = find(M>=design,1);
d_outlet = sqrt(AR(j))*d_inlet;
x = linspace(0,L,1000);

a_mat = [L^5 L^4 L^3; 5*L^4 4*L^3 3*L^2; 20*L^3 12*L^2 6*L];
c_mat = [d_outlet; 0; 0];

b_mat = a_mat\c_mat;   % Ax = b ; x = A\b; 

y = b_mat(1).*x.^5 + b_mat(2).*x.^4 + b_mat(3).*x.^3 + d_inlet; 

figure(2)
area(x,y,'linewidth',2);
hold on
area(x,-y,'linewidth',2);
xlim([0, L]);
ylim([-y(end), y(end)])

xlabel('x (inch)','fontsize',14)
ylabel('Diameter (inch)','fontsize',14)
set(gca,'fontsize',13)
title('Nozzle profile (Diverging section)')
grid on