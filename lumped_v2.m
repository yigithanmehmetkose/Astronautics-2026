function [results_h,results_c] = lumped_v2(TimeEpSec,S,AngleX,AngleY,AngleZ,AngleAlb,Q_comp_c,Q_comp_h,X)

%% PRE-PROCESSING ---------------------------------------------------------
%Constants:
sigma = 5.67*10^-8;                 % Stefan-Boltzman constant
R_e = 6378;                         % Earth radius, km

%Variable Input Properties:
x_rad_left = X(1);
x_rad_right = X(2);
x_rad_down = X(3);
x_rad_up = X(4);
minus_x_rad_left = X(5);
minus_x_rad_right = X(6);
minus_x_rad_down = X(7);
minus_x_rad_up = X(8);
y_rad_left = X(9);
y_rad_right = X(10);
y_rad_down = X(11);
y_rad_up = X(12);

%Constant Input Properties:
h = 500;                            % altitude, km
alb_h = 0.35;                       % Albedo constant in hot case
alb_c = 0.25;                       % Albedo constant in cold case
I_h = 236;                          % Earth emission in hot case
I_c = 211;                          % Earth emission in cold case
a_r_h = 0.36;                       % radiator absorptivity in hot case
a_r_c = 0.15;                       % radiator absorptivity in cold case
e_r = 0.89;                         % radiator emissivity
a_MLI = 0.4;                        % MLI absorptivity
e_MLI = 0.6;                        % MLI emissivity
a_c = 0.64;                         % solar cell absorptivity
e_c = 0.9;                          % solar cell emissivity
a_ff = 0.5;                         % solar panel substrate absorptivity
e_ff = 0.5;                         % solar panel substrate emissivity
a_b = 0.2;                          % solar panel back side absorptivity
e_b = 0.2;                          % solar panel back side emissivity
W_x = 0.5;                          % X face width, m
L_x = 0.5;                          % X face length, m
W_y = 0.5;                          % Y face width, m
A_x = L_x*W_x;                      % X face area, m2
A_y = L_x*W_y;                      % Y face area, m2
A_z = W_y*W_x;                      % Z face area, m2
L_sp = 0.5;                         % solar panel length
W_sp = 0.5;                         % solar panel width
A_sp = L_sp*W_sp;                   % solar panel area, m2
eff_b = @(T) 0.465-4.5e-4*T;        % solar cell efficiency in BOL
eff_e = @(T) 0.44-4.53e-4*T;        % solar cell efficiency in EOL
pf = 0.8;                           % packing factor of solar panels
cp = 900;                           % specific heat of solar panel, J/kgK
m = 2;                              % solar panel wing mass, kg
m_bm = 2;                           % body-mounted solar panel mass, kg
G_bm = 1e-4;                        % conductance between body-mounted solar panel and satellite
k_mli_plusX = 1e-5;                 % conductance between MLI and satellite, W/K
k_mli_minusX = 1e-5;                % conductance between MLI and satellite, W/K
k_mli_plusY = 1e-5;                 % conductance between MLI and satellite, W/K
k_mli_plusZ = 1e-5;                 % conductance between MLI and satellite, W/K
k_mli_minusZ = 1e-5;                % conductance between MLI and satellite, W/K
rho_mli = 0.6;                      % MLI density, kg/m2
cp_mli = 1500;                      % specific heat of MLI, J/kgK
eff_EPS = 0.9;                      % electrical power system efficiency
eff_b_c = 0.95;                     % battery charge efficiency
eff_b_d = 0.91;                     % battery discharge efficiency
M = 59;                             % satellite mass, kg
Cp = 942;                           % satellite specific heat, J/kgK
Period = 95;                        % number of time steps in one orbit
N_t = 12;                           % number of periods for analysis
W_h_nom = 30;                       % heater power
T_c_min = 278;                      % minimum allowed temperature, K

%Parameter Arrangement:
a_f = a_c*pf + a_ff*(1-pf);                                                           % solar panel front face absorptivity
e_f = e_c*pf + e_ff*(1-pf);                                                           % solar panel front face emissivity

A_r_plusX = (x_rad_right-x_rad_left)*(x_rad_up-x_rad_down);                           % radiator area in +X and -X faces
A_r_minusX = (minus_x_rad_right-minus_x_rad_left)*(minus_x_rad_up-minus_x_rad_down);  % radiator area in +X and -X faces
A_r_plusY = (y_rad_right-y_rad_left)*(y_rad_up-y_rad_down);                           % radiator area in +Y face

A_MLI_plusX = A_x-A_r_plusX;                                                          % MLI area in +X face
A_MLI_minusX = A_x-A_r_minusX;                                                        % MLI area in -X face
A_MLI_plusY = A_y-A_r_plusY;                                                          % MLI area in +Y face
A_MLI_plusZ = A_z;                                                                    % MLI area in +Z face
A_MLI_minusZ = A_z;                                                                   % MLI area in -Z face

m_mli_plusX = A_MLI_plusX*rho_mli;                                                    % MLI mass in +X face
m_mli_minusX = A_MLI_minusX*rho_mli;                                                  % MLI mass in -X face
m_mli_plusY = A_MLI_plusY*rho_mli;                                                    % MLI mass in +Y face
m_mli_plusZ = A_MLI_plusZ*rho_mli;                                                    % MLI mass in +Z face
m_mli_minusZ = A_MLI_minusZ*rho_mli;                                                  % MLI mass in -Z face

N = length(TimeEpSec);                                                                % number of steps
A_r = A_r_plusX + A_r_minusX + A_r_plusY;                                             % total radiator area
A_bmsp = L_sp*W_sp;                                                                  % body-mounted solar panel area

%Pre-allocation
Albedo_PlusX_h = zeros(1,N);        % albedo irradiation on +X face
Albedo_PlusX_c = zeros(1,N);
Albedo_MinusX_h = zeros(1,N);       % albedo irradiation on -X face
Albedo_MinusX_c = zeros(1,N);
Albedo_PlusY_h = zeros(1,N);        % albedo irradiation on +Y face
Albedo_PlusY_c = zeros(1,N);
Albedo_MinusY_h = zeros(1,N);       % albedo irradiation on -Y face
Albedo_MinusY_c = zeros(1,N);
Albedo_PlusZ_h = zeros(1,N);        % albedo irradiation on +Z face
Albedo_PlusZ_c = zeros(1,N);
Albedo_PlusSP_h = zeros(1,N);       % albedo irradiation on rear face of the solar panel in +X side
Albedo_PlusSP_c = zeros(1,N);
Albedo_MinusSP_h = zeros(1,N);      % albedo irradiation on rear face of the solar panel in -X side
Albedo_MinusSP_c = zeros(1,N);
Albedo_PlusMLI_h = zeros(1,N);      % albedo irradiation on MLI in +X side
Albedo_PlusMLI_c = zeros(1,N);
Albedo_MinusMLI_h = zeros(1,N);     % albedo irradiation on MLI in -X side
Albedo_MinusMLI_c = zeros(1,N);
Flux_PlusX_h = zeros(1,N);          % total heat flux incident on radiator on +X face
Flux_PlusX_c = zeros(1,N);
Flux_MinusX_h = zeros(1,N);         % total heat flux incident on radiator on -X face
Flux_MinusX_c = zeros(1,N);
Flux_PlusY_h = zeros(1,N);          % total heat flux incident on radiator on +Y face
Flux_PlusY_c = zeros(1,N);
q_sp_f_h = zeros(1,N);              % total heat flux incident on front face of solar panels
q_sp_f_c = zeros(1,N);
q_sp_b_h = zeros(1,N);              % total heat flux incident on rear face of solar panels in +X side
q_sp_b_c = zeros(1,N);
q_sp_b_minus_h = zeros(1,N);        % total heat flux incident on rear face of solar panels in -X side
q_sp_b_minus_c = zeros(1,N);
q_MLI_PlusX_h = zeros(1,N);         % total heat flux incident on MLI in +X side
q_MLI_PlusX_c = zeros(1,N);
q_MLI_MinusX_h = zeros(1,N);        % total heat flux incident on MLI in -X side
q_MLI_MinusX_c = zeros(1,N);
q_MLI_PlusY_h = zeros(1,N);         % total heat flux incident on MLI in +X side
q_MLI_PlusY_c = zeros(1,N);
q_MLI_PlusZ_h = zeros(1,N);         % total heat flux incident on MLI in +Z side
q_MLI_PlusZ_c = zeros(1,N);
q_MLI_MinusZ_h = zeros(1,N);        % total heat flux incident on MLI in -Z side
q_MLI_MinusZ_c = zeros(1,N);
T_MLI_PlusX_h = zeros(1,N);         % temperature of MLI in +X side
T_MLI_PlusX_c = zeros(1,N);
T_MLI_MinusX_h = zeros(1,N);        % temperature of MLI in -X side
T_MLI_MinusX_c = zeros(1,N);
T_MLI_PlusY_h = zeros(1,N);         % temperature of MLI in +Y side
T_MLI_PlusY_c = zeros(1,N);
T_MLI_PlusZ_h = zeros(1,N);         % temperature of MLI in +Z side
T_MLI_PlusZ_c = zeros(1,N);
T_MLI_MinusZ_h = zeros(1,N);        % temperature of MLI in -Z side
T_MLI_MinusZ_c = zeros(1,N);
T_PlusSP_h = zeros(1,N);            % temperature of solar panel in +X side
T_PlusSP_c = zeros(1,N);
T_MinusSP_h = zeros(1,N);           % temperature of solar panel in -X side
T_MinusSP_c = zeros(1,N);
T_BMSP_h = zeros(1,N);              % temperature of body-mounted solar panel
T_BMSP_c = zeros(1,N);
P_gen_e = zeros(1,N);               % power generated by solar panels
P_gen_b = zeros(1,N);
T_h = zeros(1,N);                   % temperature of the satellite
T_c = zeros(1,N);
A_sh = zeros(1,N);                  % shadow area
Albedo = zeros(1,N);
alpha_x = zeros(1,N);               % shadow angles
alpha_y = zeros(1,N);
Sun_PlusX_h = zeros(1,N);             % solar irradiation on +X face
Sun_MinusX_h = zeros(1,N);
Sun_PlusMLI_h = zeros(1,N);
Sun_PlusSP_h = zeros(1,N);
Sun_PlusX_c = zeros(1,N);
Sun_PlusMLI_c = zeros(1,N);
Sun_PlusSP_c = zeros(1,N);
Sun_MinusMLI_h = zeros(1,N);
Sun_MinusSP_h = zeros(1,N);
Sun_MinusX_c = zeros(1,N);
Sun_MinusMLI_c = zeros(1,N);
Sun_MinusSP_c = zeros(1,N);
Sun_MinusY = zeros(1,N);
Sun_PlusZ = zeros(1,N);
Sun_MinusZ = zeros(1,N);
Q_PCDU_h = zeros(1,N);              % PCDU heat generation in entire time period
Q_PCDU_c = zeros(1,N);
Q_bat_h = zeros(1,N);               % battery heat generation of components except EPS & battery
Q_bat_c = zeros(1,N);
Q_in_h = zeros(1,N);                % total heat generation in entire time period
Q_in_c = zeros(1,N);
W_h = zeros(1,N);                   % heater power consumption
q_r_PlusX_h = zeros(1,Period*N_t);
q_r_MinusX_h = zeros(1,Period*N_t);
q_r_PlusY_h = zeros(1,Period*N_t);
q_PlusSP_h = zeros(1,Period*N_t);
q_MinusSP_h = zeros(1,Period*N_t);
q_mli_PlusX_h = zeros(1,Period*N_t);
q_mli_MinusX_h = zeros(1,Period*N_t);
q_mli_PlusY_h = zeros(1,Period*N_t);
q_mli_PlusZ_h = zeros(1,Period*N_t);
q_mli_MinusZ_h = zeros(1,Period*N_t);
q_r_PlusX_c = zeros(1,Period*N_t);
q_r_MinusX_c = zeros(1,Period*N_t);
q_r_PlusY_c = zeros(1,Period*N_t);
q_PlusSP_c = zeros(1,Period*N_t);
q_MinusSP_c = zeros(1,Period*N_t);
q_mli_PlusX_c = zeros(1,Period*N_t);
q_mli_MinusX_c = zeros(1,Period*N_t);
q_mli_PlusY_c = zeros(1,Period*N_t);
q_mli_PlusZ_c = zeros(1,Period*N_t);
q_mli_MinusZ_c = zeros(1,Period*N_t);
Solar_MinusY_h = zeros(1,Period*N_t);
Solar_MinusY_c = zeros(1,Period*N_t);
q_SP_f_h = zeros(1,Period*N_t);
q_SP_f_c = zeros(1,Period*N_t);

%Initial Values:
T_h(1) = 270;
T_c(1) = 330;
T_PlusSP_h(1) = 350;
T_PlusSP_c(1) = 350;
T_MinusSP_h(1) = 350;
T_MinusSP_c(1) = 350;
T_BMSP_h(1) = 350;
T_BMSP_c(1) = 350;

%% VIEW FACTORS -----------------------------------------------------------

F_y_e = -1*sqrt(((R_e+h)/R_e)^2-1)/(pi*((R_e+h)/R_e)^2) + 1/pi*atan(1/sqrt(((R_e+h)/R_e)^2-1));     % view factor from Y panels to Earth
F_z_e = 1/((R_e+h)/R_e)^2;                                                                          % view factor from +Z panel to Earth

F_x_e = 0.2278;     % view factor from X panels to Earth, calculated using MCRT algorithm
F_sp_e = 0.2278;    % view factor from solar panel back surface to Earth, calculated using MCRT algorithm
F_x_sp = 0.2;       % view factor from X panels to solar panel

F_r_sp = F_rect_to_rect(x_rad_left,x_rad_right,x_rad_down,x_rad_up,0,W_sp,0,L_sp);
F_minus_r_sp = F_rect_to_rect(minus_x_rad_left,minus_x_rad_right,minus_x_rad_down,minus_x_rad_up,0,W_sp,0,L_sp);

F_sp_r = F_r_sp*A_r_plusX/A_sp;
F_minus_sp_r = F_minus_r_sp*A_r_minusX/A_sp;

F_plus_mli_sp = (F_x_sp*A_x-F_r_sp*A_r_plusX)/A_MLI_plusX;
F_minus_mli_sp = (F_x_sp*A_x-F_minus_r_sp*A_r_minusX)/A_MLI_minusX;
F_plus_sp_mli = F_plus_mli_sp*A_sp/A_MLI_plusX;
F_minus_sp_mli = F_minus_mli_sp*A_sp/A_MLI_minusX;

%% GEBHART FACTORS
%1: Radiator, 2: Solar Panel, 3: MLI

%HOT CASE
%Plus Side, Solar, WHC
A_plus_s_h = [1, -F_r_sp*(1-a_b), 0; -F_sp_r*(1-a_r_h), 1, -F_plus_sp_mli*(1-a_MLI); 0, -F_plus_mli_sp*(1-a_b), 1];
F_plus_s_h = [0, F_r_sp*a_b, 0; F_sp_r*a_r_h, 0, F_plus_sp_mli*a_MLI; 0, F_plus_mli_sp*a_b, 0];
B_plus_s_h = A_plus_s_h\F_plus_s_h;

%Minus Side, Solar, WHC
A_minus_s_h = [1, -F_minus_r_sp*(1-a_b), 0; -F_minus_sp_r*(1-a_r_h), 1, -F_minus_sp_mli*(1-a_MLI); 0, -F_minus_mli_sp*(1-a_b), 1];
F_minus_s_h = [0, F_minus_r_sp*a_b, 0; F_minus_sp_r*a_r_h, 0, F_minus_sp_mli*a_MLI; 0, F_minus_mli_sp*a_b, 0];
B_minus_s_h = A_minus_s_h\F_minus_s_h;

%Plus Side, Infrared, WHC
A_plus_i_h = [1, -F_r_sp*(1-e_b), 0; -F_sp_r*(1-e_r), 1, -F_plus_sp_mli*(1-e_MLI); 0, -F_plus_mli_sp*(1-e_b), 1];
F_plus_i_h = [0, F_r_sp*e_b, 0; F_sp_r*e_r, 0, F_plus_sp_mli*e_MLI; 0, F_plus_mli_sp*e_b, 0];
B_plus_i_h = A_plus_i_h\F_plus_i_h;

%Minus Side, Infrared, WHC
A_minus_i_h = [1, -F_minus_r_sp*(1-e_b), 0; -F_minus_sp_r*(1-e_r), 1, -F_minus_sp_mli*(1-e_MLI); 0, -F_minus_mli_sp*(1-e_b), 1];
F_minus_i_h = [0, F_minus_r_sp*e_b, 0; F_minus_sp_r*e_r, 0, F_minus_sp_mli*e_MLI; 0, F_minus_mli_sp*e_b, 0];
B_minus_i_h = A_minus_i_h\F_minus_i_h;

%COLD CASE
%Plus Side, Solar, WCC
A_plus_s_c = [1, -F_r_sp*(1-a_b), 0; -F_sp_r*(1-a_r_c), 1, -F_plus_sp_mli*(1-a_MLI); 0, -F_plus_mli_sp*(1-a_b), 1];
F_plus_s_c = [0, F_r_sp*a_b, 0; F_sp_r*a_r_c, 0, F_plus_sp_mli*a_MLI; 0, F_plus_mli_sp*a_b, 0];
B_plus_s_c = A_plus_s_c\F_plus_s_c;

%Minus Side, Solar, WCC
A_minus_s_c = [1, -F_minus_r_sp*(1-a_b), 0; -F_minus_sp_r*(1-a_r_c), 1, -F_minus_sp_mli*(1-a_MLI); 0, -F_minus_mli_sp*(1-a_b), 1];
F_minus_s_c = [0, F_minus_r_sp*a_b, 0; F_minus_sp_r*a_r_c, 0, F_minus_sp_mli*a_MLI; 0, F_minus_mli_sp*a_b, 0];
B_minus_s_c = A_minus_s_c\F_minus_s_c;

%Plus Side, Infrared, WCC
A_plus_i_c = [1, -F_r_sp*(1-e_b), 0; -F_sp_r*(1-e_r), 1, -F_plus_sp_mli*(1-e_MLI); 0, -F_plus_mli_sp*(1-e_b), 1];
F_plus_i_c = [0, F_r_sp*e_b, 0; F_sp_r*e_r, 0, F_plus_sp_mli*e_MLI; 0, F_plus_mli_sp*e_b, 0];
B_plus_i_c = A_plus_i_c\F_plus_i_c;

%Minus Side, Infrared, WCC
A_minus_i_c = [1, -F_minus_r_sp*(1-e_b), 0; -F_minus_sp_r*(1-e_r), 1, -F_minus_sp_mli*(1-e_MLI); 0, -F_minus_mli_sp*(1-e_b), 1];
F_minus_i_c = [0, F_minus_r_sp*e_b, 0; F_minus_sp_r*e_r, 0, F_minus_sp_mli*e_MLI; 0, F_minus_mli_sp*e_b, 0];
B_minus_i_c = A_minus_i_c\F_minus_i_c;

%% EXTERNAL HEAT FLUX CALCULATION -----------------------------------------
%INCIDENT SOLAR

%X-direction
for i=1:N
    alpha_x(i) = acos(cosd(AngleX(i))/sqrt(cosd(AngleX(i))^2+cosd(AngleY(i))^2));
    alpha_y(i) = acos(cosd(AngleY(i))/sqrt(cosd(AngleZ(i))^2+cosd(AngleY(i))^2));
    if AngleX(i) ~= 180 && alpha_x(i) < pi/2
        h_sh = W_sp*tan(alpha_x(i));
        if h_sh > W_x
            h_sh = W_x;
        end
        A_sh(i) = (2*L_x-h_sh*tan(pi-alpha_y(i)))/2*h_sh;

        %Hot Case
        Sun_PlusX_h(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_r_h + B_plus_s_h(1,1)*(1-a_r_h) + B_plus_s_h(3,1)*(1-a_MLI));
        Sun_PlusMLI_h(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_MLI + (1-a_r_h)*B_plus_s_h(1,3) + (1-a_MLI)*B_plus_s_h(3,3));
        Sun_PlusSP_h(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*((1-a_r_h)*B_plus_s_h(1,2) + (1-a_MLI)*B_plus_s_h(3,2));

        %Cold Case
        Sun_PlusX_c(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_r_c + B_plus_s_c(1,1)*(1-a_r_c) + B_plus_s_c(3,1)*(1-a_MLI));
        Sun_PlusMLI_c(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_MLI + (1-a_r_h)*B_plus_s_c(1,3) + (1-a_MLI)*B_plus_s_c(3,3));
        Sun_PlusSP_c(i) = S(i)*cosd(AngleX(i))*(A_x-A_sh(i))/(A_x)*((1-a_r_c)*B_plus_s_c(1,2) + (1-a_MLI)*B_plus_s_c(3,2));
    elseif AngleX(i) ~= 180 && alpha_x(i) >= pi/2
        h_sh = W_sp*tan(pi-alpha_x(i));
        if h_sh > W_x
            h_sh = W_x;
        end
        A_sh(i) = (2*L_x-h_sh*tan(pi-alpha_y(i)))/2*h_sh;

        %Hot Case
        Sun_MinusX_h(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_r_h + B_minus_s_h(1,1)*(1-a_r_h) + B_minus_s_h(3,1)*(1-a_MLI));
        Sun_MinusMLI_h(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_MLI + (1-a_r_h)*B_minus_s_h(1,3) + (1-a_MLI)*B_minus_s_h(3,3));
        Sun_MinusSP_h(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*((1-a_r_h)*B_minus_s_h(1,2) + (1-a_MLI)*B_minus_s_h(3,2));

        %Cold Case
        Sun_MinusX_c(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_r_c + B_minus_s_c(1,1)*(1-a_r_c) + B_minus_s_c(3,1)*(1-a_MLI));
        Sun_MinusMLI_c(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*(a_MLI + (1-a_r_c)*B_minus_s_c(1,3) + (1-a_MLI)*B_minus_s_c(3,3));
        Sun_MinusSP_c(i) = S(i)*cosd(180-AngleX(i))*(A_x-A_sh(i))/(A_x)*((1-a_r_c)*B_minus_s_c(1,2) + (1-a_MLI)*B_minus_s_c(3,2));
    end
end

%Y-direction
for i=1:N
    if AngleY(i) > 90 && AngleY(i) ~= 180
        Sun_MinusY(i) = S(i)*cosd(180-AngleY(i));
    end
end

%Z-direction
for i=1:N
    if AngleZ(i) < 90 && AngleZ(i) > 0
        Sun_PlusZ(i) = S(i)*cosd(AngleZ(i));
    elseif AngleZ(i) > 90 && AngleZ(i) ~= 180
        Sun_MinusZ(i) = S(i)*cosd(180-AngleZ(i));
    end
end

%INCIDENT ALBEDO
for i=1:N
    Albedo(i) = 180-AngleAlb(i);
    if Albedo(i)<90

        %Hot Case
        Albedo_PlusX_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_r_h*F_x_e + B_plus_s_h(1,1)*F_x_e*(1-a_r_h) + B_plus_s_h(2,1)*F_sp_e*(1-a_b) + B_plus_s_h(3,1)*F_x_e*(1-a_MLI));
        Albedo_MinusX_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_r_h*F_x_e + B_minus_s_h(1,1)*F_x_e*(1-a_r_h) + B_minus_s_h(2,1)*F_sp_e*(1-a_b) + B_minus_s_h(3,1)*F_x_e*(1-a_MLI));
        Albedo_PlusY_h(i) = alb_h*S(i)*cosd(Albedo(i))*F_y_e;
        Albedo_MinusY_h(i) = alb_h*S(i)*cosd(Albedo(i))*F_y_e;
        Albedo_PlusZ_h(i) = alb_h*S(i)*cosd(Albedo(i))*F_z_e;
        Albedo_PlusSP_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_b*F_sp_e + F_x_e*(1-a_r_h)*B_plus_s_h(1,2) + F_sp_e*(1-a_b)*B_plus_s_h(2,2) + F_x_e*(1-a_MLI)*B_plus_s_h(3,2));
        Albedo_MinusSP_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_b*F_sp_e + F_x_e*(1-a_r_h)*B_minus_s_h(1,2) + F_sp_e*(1-a_b)*B_minus_s_h(2,2) + F_x_e*(1-a_MLI)*B_minus_s_h(3,2));
        Albedo_PlusMLI_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_MLI*F_x_e + F_x_e*(1-a_r_h)*B_plus_s_h(1,3) + F_sp_e*(1-a_b)*B_plus_s_h(2,3) + F_x_e*(1-a_MLI)*B_plus_s_h(3,3));
        Albedo_MinusMLI_h(i) = alb_h*S(i)*cosd(Albedo(i))*(a_MLI*F_x_e + F_x_e*(1-a_r_h)*B_minus_s_h(1,3) + F_sp_e*(1-a_b)*B_minus_s_h(2,3) + F_x_e*(1-a_MLI)*B_minus_s_h(3,3));
        
        %Cold Case
        Albedo_PlusX_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_r_c*F_x_e + B_plus_s_c(1,1)*F_x_e*(1-a_r_c) + B_plus_s_c(2,1)*F_sp_e*(1-a_b) + B_plus_s_c(3,1)*F_x_e*(1-a_MLI));
        Albedo_MinusX_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_r_c*F_x_e + B_minus_s_c(1,1)*F_x_e*(1-a_r_c) + B_minus_s_c(2,1)*F_sp_e*(1-a_b) + B_minus_s_c(3,1)*F_x_e*(1-a_MLI));
        Albedo_PlusY_c(i) = alb_c*S(i)*cosd(Albedo(i))*F_y_e;
        Albedo_MinusY_c(i) = alb_c*S(i)*cosd(Albedo(i))*F_y_e;
        Albedo_PlusZ_c(i) = alb_c*S(i)*cosd(Albedo(i))*F_z_e;
        Albedo_PlusSP_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_b*F_sp_e + F_x_e*(1-a_r_c)*B_plus_s_c(1,2) + F_sp_e*(1-a_b)*B_plus_s_c(2,2) + F_x_e*(1-a_MLI)*B_plus_s_c(3,2));
        Albedo_MinusSP_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_b*F_sp_e + F_x_e*(1-a_r_c)*B_minus_s_c(1,2) + F_sp_e*(1-a_b)*B_minus_s_c(2,2) + F_x_e*(1-a_MLI)*B_minus_s_c(3,2));
        Albedo_PlusMLI_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_MLI*F_x_e + F_x_e*(1-a_r_c)*B_plus_s_c(1,3) + F_sp_e*(1-a_b)*B_plus_s_c(2,3) + F_x_e*(1-a_MLI)*B_plus_s_c(3,3));
        Albedo_MinusMLI_c(i) = alb_c*S(i)*cosd(Albedo(i))*(a_MLI*F_x_e + F_x_e*(1-a_r_c)*B_minus_s_c(1,3) + F_sp_e*(1-a_b)*B_minus_s_c(2,3) + F_x_e*(1-a_MLI)*B_minus_s_c(3,3));
    end
end

%INCIDENT EARTH FLUX

%Hot Case
q_e_plusX_h = I_h*(e_r*F_x_e + F_x_e*(1-e_r)*B_plus_s_h(1,1) + F_sp_e*(1-e_b)*B_plus_s_h(1,2) + F_x_e*(1-e_MLI)*B_plus_s_h(1,3));
q_e_minusX_h = I_h*(e_r*F_x_e + F_x_e*(1-e_r)*B_minus_s_h(1,1) + F_sp_e*(1-e_b)*B_minus_s_h(1,2) + F_x_e*(1-e_MLI)*B_minus_s_h(1,3));
q_e_Y_h = I_h*F_y_e;
q_e_Z_h = I_h*F_z_e;
q_e_plusSP_h = I_h*(e_b*F_sp_e + F_x_e*(1-e_r)*B_plus_s_h(2,1) + F_sp_e*(1-e_b)*B_plus_s_h(2,2) + F_x_e*(1-e_MLI)*B_plus_s_h(2,3));
q_e_minusSP_h = I_h*(e_b*F_sp_e + F_x_e*(1-e_r)*B_minus_s_h(2,1) + F_sp_e*(1-e_b)*B_minus_s_h(2,2) + F_x_e*(1-e_MLI)*B_minus_s_h(2,3));
q_e_plusMLI_h = I_h*(e_MLI*F_x_e + F_x_e*(1-e_r)*B_plus_s_h(3,1) + F_sp_e*(1-e_b)*B_plus_s_h(3,2) + F_x_e*(1-e_MLI)*B_plus_s_h(3,3));
q_e_minusMLI_h = I_h*(e_MLI*F_x_e + F_x_e*(1-e_r)*B_minus_s_h(3,1) + F_sp_e*(1-e_b)*B_minus_s_h(3,2) + F_x_e*(1-e_MLI)*B_minus_s_h(3,3));

%Cold Case
q_e_plusX_c = I_c*(e_r*F_x_e + F_x_e*(1-e_r)*B_plus_s_c(1,1) + F_sp_e*(1-e_b)*B_plus_s_c(1,2) + F_x_e*(1-e_MLI)*B_plus_s_c(1,3));
q_e_minusX_c = I_c*(e_r*F_x_e + F_x_e*(1-e_r)*B_minus_s_c(1,1) + F_sp_e*(1-e_b)*B_minus_s_c(1,2) + F_x_e*(1-e_MLI)*B_minus_s_c(1,3));
q_e_Y_c = I_c*F_y_e;
q_e_Z_c = I_c*F_z_e;
q_e_plusSP_c = I_c*(e_b*F_sp_e + F_x_e*(1-e_r)*B_plus_s_c(2,1) + F_sp_e*(1-e_b)*B_plus_s_c(2,2) + F_x_e*(1-e_MLI)*B_plus_s_c(2,3));
q_e_minusSP_c = I_c*(e_b*F_sp_e + F_x_e*(1-e_r)*B_minus_s_c(2,1) + F_sp_e*(1-e_b)*B_minus_s_c(2,2) + F_x_e*(1-e_MLI)*B_minus_s_c(2,3));
q_e_plusMLI_c = I_c*(e_MLI*F_x_e + F_x_e*(1-e_r)*B_plus_s_c(3,1) + F_sp_e*(1-e_b)*B_plus_s_c(3,2) + F_x_e*(1-e_MLI)*B_plus_s_c(3,3));
q_e_minusMLI_c = I_c*(e_MLI*F_x_e + F_x_e*(1-e_r)*B_minus_s_c(3,1) + F_sp_e*(1-e_b)*B_minus_s_c(3,2) + F_x_e*(1-e_MLI)*B_minus_s_c(3,3));

%ABSORBED HEAT FLUX
for i = 1:N

    %Hot Case
    Flux_PlusX_h(i) =  Sun_PlusX_h(i) + Albedo_PlusX_h(i) + q_e_plusX_h;
    Flux_MinusX_h(i) = Sun_MinusX_h(i) + Albedo_MinusX_h(i) + q_e_minusX_h;
    Flux_PlusY_h(i) = a_r_h*Albedo_PlusY_h(i) + e_r*q_e_Y_h;
    q_sp_f_h(i) = a_f*Sun_MinusY(i) + a_f*Albedo_MinusY_h(i) + e_f*q_e_Y_h;
    q_sp_b_h(i) = Sun_PlusSP_h(i) + Albedo_PlusSP_h(i) + q_e_plusSP_h;
    q_sp_b_minus_h(i) = Sun_MinusSP_h(i) + Albedo_MinusSP_h(i) + q_e_minusSP_h;
    q_MLI_PlusX_h(i) = Sun_PlusMLI_h(i) + Albedo_PlusMLI_h(i) + q_e_plusMLI_h;
    q_MLI_MinusX_h(i) = Sun_MinusMLI_h(i) + Albedo_MinusMLI_h(i) + q_e_minusMLI_h;
    q_MLI_PlusY_h(i) = a_MLI*Albedo_PlusY_h(i) + q_e_Y_h;
    q_MLI_PlusZ_h(i) = a_MLI*Sun_PlusZ(i) + a_MLI*Albedo_PlusZ_h(i) + e_MLI*q_e_Z_h;
    q_MLI_MinusZ_h(i) = a_MLI*Sun_MinusZ(i);

    %Cold Case
    Flux_PlusX_c(i) =  Sun_PlusX_c(i) + Albedo_PlusX_c(i) + q_e_plusX_c;
    Flux_MinusX_c(i) = Sun_MinusX_c(i) + Albedo_MinusX_c(i) + q_e_minusX_c;
    Flux_PlusY_c(i) = a_r_c*Albedo_PlusY_c(i) + e_r*q_e_Y_c;
    q_sp_f_c(i) = a_f*Sun_MinusY(i) + a_f*Albedo_MinusY_c(i) + e_f*q_e_Y_c;
    q_sp_b_c(i) = Sun_PlusSP_c(i) + Albedo_PlusSP_c(i) + q_e_plusSP_c;
    q_sp_b_minus_c(i) = Sun_MinusSP_c(i) + Albedo_MinusSP_c(i) + q_e_minusSP_c;
    q_MLI_PlusX_c(i) = Sun_PlusMLI_c(i) + Albedo_PlusMLI_c(i) + q_e_plusMLI_c;
    q_MLI_MinusX_c(i) = Sun_MinusMLI_c(i) + Albedo_MinusMLI_c(i) + q_e_minusMLI_c;
    q_MLI_PlusY_c(i) = a_MLI*Albedo_PlusY_c(i) + q_e_Y_c;
    q_MLI_PlusZ_c(i) = a_MLI*Sun_PlusZ(i) + a_MLI*Albedo_PlusZ_c(i) + e_MLI*q_e_Z_c;
    q_MLI_MinusZ_c(i) = a_MLI*Sun_MinusZ(i);
end

Q_ext_h = Flux_PlusX_h*A_r_plusX + Flux_MinusX_h*A_r_minusX + Flux_PlusY_h*A_r_plusY;
Q_ext_c = Flux_PlusX_c*A_r_plusX + Flux_MinusX_c*A_r_minusX + Flux_PlusY_c*A_r_plusY;

%% INTERNAL HEAT CALCULATION ----------------------------------------------

for i=1:N
    t = i;
    while t>Period
        t=t-Period;
    end
    Q_in_h(i) = Q_comp_h(t);
    Q_PCDU_h(i) = Q_comp_h(t)*(1/eff_EPS-1);
    Q_in_c(i) = Q_comp_c(t);
    Q_PCDU_c(i) = Q_comp_c(t)*(1/eff_EPS-1);
end

%% LUMPED ANALYSIS --------------------------------------------------------
for i=1:N-1
    dt = TimeEpSec(i+1)-TimeEpSec(i);
    
    %HOT CASE
    %Solar Panel Temperatures:
    T_PlusSP_h(i+1) = T_PlusSP_h(i) + dt*A_sp/(m*cp)*(q_sp_f_h(i) + q_sp_b_h(i) + B_plus_i_h(2,1)*e_b*sigma*T_h(i)^4 + B_plus_i_h(2,3)*e_b*sigma*T_MLI_PlusX_h(i)^4 -(e_f+e_b*(1-B_plus_i_h(2,2)))*sigma*T_PlusSP_h(i)^4);
    T_MinusSP_h(i+1) = T_MinusSP_h(i) + dt*A_sp/(m*cp)*(q_sp_f_h(i) + q_sp_b_minus_h(i) + B_minus_i_h(2,1)*e_b*sigma*T_h(i)^4 + B_minus_i_h(2,3)*e_b*sigma*T_MLI_MinusX_h(i)^4 -(e_f+e_b*(1-B_minus_i_h(2,2)))*sigma*T_MinusSP_h(i)^4);
    T_BMSP_h(i+1) = T_BMSP_h(i) + dt*A_bmsp/(m_bm*cp)*(q_sp_f_h(i) + G_bm*(T_h(i)-T_BMSP_h(i)) -sigma*e_f*T_BMSP_h(i)^4);
    %EOL Power Generation:
    P_plus_e = A_sp*pf*S(i)*cosd(180-AngleY(i))*eff_e(T_PlusSP_h(i));
    P_minus_e = A_sp*pf*S(i)*cosd(180-AngleY(i))*eff_e(T_MinusSP_h(i));
    P_bm_e = A_bmsp*pf*S(i)*cosd(180-AngleY(i))*eff_e(T_BMSP_h(i));
    P_gen_e(i) = P_plus_e + P_minus_e + P_bm_e;
    %Index Arrangement:
    t = i;
    while t > Period
        t = t - Period;
    end
    %Battery Power Dissipation:
    if P_gen_e(i) > Q_comp_h(t)*(1/eff_EPS)
        Q_bat_h(i) = (P_gen_e(i) - Q_comp_h(t)*(1/eff_EPS))*(1-eff_b_c);
    else
        Q_bat_h(i) = -(P_gen_e(i) - Q_comp_h(t)*(1/eff_EPS))*(1-eff_b_d);
    end
    %Total Internal Heat Generation:
    Q_in_h(i) = Q_comp_h(t) + Q_PCDU_h(t) + Q_bat_h(t);
    %MLI Lumped Temperature:
    T_MLI_PlusX_h(i+1) = T_MLI_PlusX_h(i) + A_MLI_plusX*dt/(m_mli_plusX*cp_mli) * (q_MLI_PlusX_h(i) + B_plus_i_h(3,1)*e_MLI*sigma*T_h(i)^4 + B_plus_i_h(3,2)*e_MLI*sigma*T_PlusSP_h(i)^4 + ...
        (T_h(i)-T_MLI_PlusX_h(i))*k_mli_plusX - (1-B_plus_i_h(3,3))*sigma*e_MLI*T_MLI_PlusX_h(i)^4);
    T_MLI_MinusX_h(i+1) = T_MLI_MinusX_h(i) + A_MLI_minusX*dt/(m_mli_minusX*cp_mli) * (q_MLI_MinusX_h(i) + B_minus_i_h(3,1)*e_MLI*sigma*T_h(i)^4 + B_minus_i_h(3,2)*e_MLI*sigma*T_MinusSP_h(i)^4 + ...
        (T_h(i)-T_MLI_MinusX_h(i))*k_mli_minusX - (1-B_minus_i_h(3,3))*sigma*e_MLI*T_MLI_MinusX_h(i)^4);
    T_MLI_PlusY_h(i+1) = T_MLI_PlusY_h(i) + A_MLI_plusY*dt/(m_mli_plusY*cp_mli) * (q_MLI_PlusY_h(i) + (T_h(i)-T_MLI_PlusY_h(i))*k_mli_plusY - sigma*e_MLI*T_MLI_PlusY_h(i)^4);
    T_MLI_PlusZ_h(i+1) = T_MLI_PlusZ_h(i) + A_MLI_plusZ*dt/(m_mli_plusZ*cp_mli) * (q_MLI_PlusZ_h(i) + (T_h(i)-T_MLI_PlusZ_h(i))*k_mli_plusZ - sigma*e_MLI*T_MLI_PlusZ_h(i)^4);
    T_MLI_MinusZ_h(i+1) = T_MLI_MinusZ_h(i) + A_MLI_minusZ*dt/(m_mli_minusZ*cp_mli) * (q_MLI_MinusZ_h(i) + (T_h(i)-T_MLI_MinusZ_h(i))*k_mli_minusZ - sigma*e_MLI*T_MLI_MinusZ_h(i)^4);
    %Satellite Lumped Temperature:
    T_h(i+1) = T_h(i) + dt/(M*Cp) * (Q_ext_h(i) + Q_in_h(i) + A_r_plusX*e_r*sigma*(B_plus_i_h(1,1)*T_h(i)^4 + B_plus_i_h(1,2)*T_PlusSP_h(i)^4 + B_plus_i_h(1,3)*T_MLI_PlusX_h(i)^4) + ...
        A_r_minusX*e_r*sigma*(B_minus_i_h(1,1)*T_h(i)^4 + B_minus_i_h(1,2)*T_MinusSP_h(i)^4 + B_minus_i_h(1,3)*T_MLI_MinusX_h(i)^4) + G_bm*(T_BMSP_h(i)-T_h(i)) + (T_MLI_PlusX_h(i)-T_h(i))*k_mli_plusX + ...
        (T_MLI_MinusX_h(i)-T_h(i))*k_mli_minusX + (T_MLI_PlusY_h(i)-T_h(i))*k_mli_plusY + (T_MLI_PlusZ_h(i)-T_h(i))*k_mli_plusZ + (T_MLI_MinusZ_h(i)-T_h(i))*k_mli_minusZ - sigma*A_r*e_r*T_h(i)^4);

    %COLD CASE
    %Solar Panel Temperatures:
    T_PlusSP_c(i+1) = T_PlusSP_c(i) + dt*A_sp/(m*cp)*(q_sp_f_c(i) + q_sp_b_c(i) + B_plus_i_c(2,1)*e_b*sigma*T_c(i)^4 + B_plus_i_c(2,3)*e_b*sigma*T_MLI_PlusX_c(i)^4 -(e_f+e_b*(1-B_plus_i_c(2,2)))*sigma*T_PlusSP_c(i)^4);
    T_MinusSP_c(i+1) = T_MinusSP_c(i) + dt*A_sp/(m*cp)*(q_sp_f_c(i) + q_sp_b_minus_c(i) + B_minus_i_c(2,1)*e_b*sigma*T_c(i)^4 + B_minus_i_c(2,3)*e_b*sigma*T_MLI_MinusX_c(i)^4 -(e_f+e_b*(1-B_minus_i_c(2,2)))*sigma*T_MinusSP_c(i)^4);
    T_BMSP_c(i+1) = T_BMSP_c(i) + dt*A_bmsp/(m_bm*cp)*(q_sp_f_c(i) + G_bm*(T_c(i)-T_BMSP_c(i)) -sigma*e_f*T_BMSP_c(i)^4);
    %BOL Power Generation:
    P_plus_b = A_sp*pf*S(i)*cosd(180-AngleY(i))*eff_b(T_PlusSP_c(i));
    P_minus_b = A_sp*pf*S(i)*cosd(180-AngleY(i))*eff_b(T_MinusSP_c(i));
    P_bm_b = A_bmsp*pf*S(i)*cosd(180-AngleY(i))*eff_b(T_BMSP_c(i));
    P_gen_b(i) = P_plus_b + P_minus_b + P_bm_b;
    %Index Arrangement:
    t = i;
    while t > Period
        t = t - Period;
    end
    %Battery Power Dissipation:
    if P_gen_b(i) > Q_comp_c(t)*(1/eff_EPS)
        Q_bat_c(i) = (P_gen_b(i) - Q_comp_c(t)*(1/eff_EPS))*(1-eff_b_c);
    else
        Q_bat_c(i) = -(P_gen_b(i) - Q_comp_c(t)*(1/eff_EPS))*(1-eff_b_d);
    end
    %Total Internal Heat Generation:
    Q_in_c(i) = Q_comp_c(t) + Q_PCDU_c(t) + Q_bat_c(t);
    %Heater Power Consumption:
    Q_h = 0;
    if T_c(i) < T_c_min
        Q_h = W_h_nom;
        W_h(i) = Q_h;
    end
    %MLI Lumped Temperature:
    T_MLI_PlusX_c(i+1) = T_MLI_PlusX_c(i) + A_MLI_plusX*dt/(m_mli_plusX*cp_mli) * (q_MLI_PlusX_c(i) + B_plus_i_c(3,1)*e_MLI*sigma*T_c(i)^4 + B_plus_i_c(3,2)*e_MLI*sigma*T_PlusSP_c(i)^4 + ...
        (T_c(i)-T_MLI_PlusX_c(i))*k_mli_plusX - (1-B_plus_i_c(3,3))*sigma*e_MLI*T_MLI_PlusX_c(i)^4);
    T_MLI_MinusX_c(i+1) = T_MLI_MinusX_c(i) + A_MLI_minusX*dt/(m_mli_minusX*cp_mli) * (q_MLI_MinusX_c(i) + B_minus_i_c(3,1)*e_MLI*sigma*T_c(i)^4 + B_minus_i_c(3,2)*e_MLI*sigma*T_MinusSP_c(i)^4 + ...
        (T_c(i)-T_MLI_MinusX_c(i))*k_mli_minusX - (1-B_minus_i_c(3,3))*sigma*e_MLI*T_MLI_MinusX_c(i)^4);
    T_MLI_PlusY_c(i+1) = T_MLI_PlusY_c(i) + A_MLI_plusY*dt/(m_mli_plusY*cp_mli) * (q_MLI_PlusY_c(i) + (T_c(i)-T_MLI_PlusY_c(i))*k_mli_plusY - sigma*e_MLI*T_MLI_PlusY_c(i)^4);
    T_MLI_PlusZ_c(i+1) = T_MLI_PlusZ_c(i) + A_MLI_plusZ*dt/(m_mli_plusZ*cp_mli) * (q_MLI_PlusZ_c(i) + (T_c(i)-T_MLI_PlusZ_c(i))*k_mli_plusZ - sigma*e_MLI*T_MLI_PlusZ_c(i)^4);
    T_MLI_MinusZ_c(i+1) = T_MLI_MinusZ_c(i) + A_MLI_minusZ*dt/(m_mli_minusZ*cp_mli) * (q_MLI_MinusZ_c(i) + (T_c(i)-T_MLI_MinusZ_c(i))*k_mli_minusZ - sigma*e_MLI*T_MLI_MinusZ_c(i)^4);
    %Satellite Lumped Temperature:
    T_c(i+1) = T_c(i) + dt/(M*Cp) * (Q_h + Q_ext_c(i) + Q_in_c(i) + A_r_plusX*e_r*sigma*(B_plus_i_c(1,1)*T_c(i)^4 + B_plus_i_c(1,2)*T_PlusSP_c(i)^4 + B_plus_i_c(1,3)*T_MLI_PlusX_c(i)^4) + ...
        A_r_minusX*e_r*sigma*(B_minus_i_c(1,1)*T_c(i)^4 + B_minus_i_c(1,2)*T_MinusSP_c(i)^4 + B_minus_i_c(1,3)*T_MLI_MinusX_c(i)^4) + G_bm*(T_BMSP_c(i)-T_c(i)) + (T_MLI_PlusX_c(i)-T_c(i))*k_mli_plusX + ...
        (T_MLI_MinusX_c(i)-T_c(i))*k_mli_minusX + (T_MLI_PlusY_c(i)-T_c(i))*k_mli_plusY + (T_MLI_PlusZ_c(i)-T_c(i))*k_mli_plusZ + (T_MLI_MinusZ_c(i)-T_c(i))*k_mli_minusZ - sigma*A_r*e_r*T_c(i)^4);
end

%% OUTPUTS

[~,i_h] = max(T_h);
[~,i_c] = min(T_c);

fprintf('%d %d \n',i_h,i_c)

for i=1:Period*N_t

    %Hot Case
    q_r_PlusX_h(i) = Flux_PlusX_h(i_h - Period*N_t/2 + i);
    q_r_MinusX_h(i) = Flux_MinusX_h(i_h - Period*N_t/2 + i);
    q_r_PlusY_h(i) = Flux_PlusY_h(i_h - Period*N_t/2 + i);
    q_SP_f_h(i) = q_sp_f_h(i_h - Period*N_t/2 + i);
    q_PlusSP_h(i) = q_sp_b_h(i_h - Period*N_t/2 + i);
    q_MinusSP_h(i) = q_sp_b_minus_h(i_h - Period*N_t/2 + i);
    q_mli_PlusX_h(i) = q_MLI_PlusX_h(i_h - Period*N_t/2 + i);
    q_mli_MinusX_h(i) = q_MLI_MinusX_h(i_h - Period*N_t/2 + i);
    q_mli_PlusY_h(i) = q_MLI_PlusY_h(i_h - Period*N_t/2 + i);
    q_mli_PlusZ_h(i) = q_MLI_PlusZ_h(i_h - Period*N_t/2 + i);
    q_mli_MinusZ_h(i) = q_MLI_MinusZ_h(i_h - Period*N_t/2 + i);
    Solar_MinusY_h(i) = Sun_MinusY(i_h - Period*N_t/2 + i);

    %Cold Case   
    q_r_PlusX_c(i) = Flux_PlusX_c(i_c - Period*N_t/2 + i);
    q_r_MinusX_c(i) = Flux_MinusX_c(i_c - Period*N_t/2 + i);
    q_r_PlusY_c(i) = Flux_PlusY_c(i_c - Period*N_t/2 + i);
    q_SP_f_c(i) = q_sp_f_c(i_c - Period*N_t/2 + i);
    q_PlusSP_c(i) = q_sp_b_c(i_c - Period*N_t/2 + i);
    q_MinusSP_c(i) = q_sp_b_minus_c(i_c - Period*N_t/2 + i);
    q_mli_PlusX_c(i) = q_MLI_PlusX_c(i_c - Period*N_t/2 + i);
    q_mli_MinusX_c(i) = q_MLI_MinusX_c(i_c - Period*N_t/2 + i);
    q_mli_PlusY_c(i) = q_MLI_PlusY_c(i_c - Period*N_t/2 + i);
    q_mli_PlusZ_c(i) = q_MLI_PlusZ_c(i_c - Period*N_t/2 + i);
    q_mli_MinusZ_c(i) = q_MLI_MinusZ_c(i_c - Period*N_t/2 + i);
    Solar_MinusY_c(i) = Sun_MinusY(i_c - Period*N_t/2 + i);
end

results_h(:,1) = q_r_PlusX_h;
results_h(:,2) = q_r_MinusX_h;
results_h(:,3) = q_r_PlusY_h;
results_h(:,4) = q_SP_f_h;
results_h(:,5) = q_PlusSP_h;
results_h(:,6) = q_MinusSP_h;
results_h(:,7) = q_mli_PlusX_h;
results_h(:,8) = q_mli_MinusX_h;
results_h(:,9) = q_mli_PlusY_h;
results_h(:,10) = q_mli_PlusZ_h;
results_h(:,11) = q_mli_MinusZ_h;
results_h(:,12) = Solar_MinusY_h;

results_c(:,1) = q_r_PlusX_c;
results_c(:,2) = q_r_MinusX_c;
results_c(:,3) = q_r_PlusY_c;
results_c(:,4) = q_SP_f_c;
results_c(:,5) = q_PlusSP_c;
results_c(:,6) = q_MinusSP_c;
results_c(:,7) = q_mli_PlusX_c;
results_c(:,8) = q_mli_MinusX_c;
results_c(:,9) = q_mli_PlusY_c;
results_c(:,10) = q_mli_PlusZ_c;
results_c(:,11) = q_mli_MinusZ_c;
results_c(:,12) = Solar_MinusY_c;

end
