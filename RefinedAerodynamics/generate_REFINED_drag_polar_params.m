% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_REFINED_drag_polar_params(aircraft)
% Description: This function generates a struct that holds parameters used in
% calculating the drag polar of the aerodynamics system of the aircraft based
% on an optimized airfoil.
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct with specs
% 
% OUTPUTS:
% --------------------------------------------
%    aircraft - aircraft param with struct, updated with drag polar
%    parameters
%                       
% 
% See also: None
% Author:                          Victoria
% Version history revision notes:
%                                  v1: 11/8/2024

% Need to calculate drag at each component, then add together for total
% drag

%%%%%%%%%%%%%%%%%%%%
%% INITIALIZATION %%
%%%%%%%%%%%%%%%%%%%%

aircraft = generate_CL_params(aircraft);

wing = aircraft.geometry.wing;
aero = aircraft.aerodynamics;
htail = aircraft.geometry.htail;

% For all aircraft aspects - Given in table in drive under utilities
S_ref_wing = wing.S_ref; % [m^2]

freestream_mach = aircraft.performance.mach.arr; %0.282 0.54 0.85 0.9 1.2 1.6
aero.mach = freestream_mach;

wing_airfoil_mach = freestream_mach.*cos(aircraft.geometry.wing.sweep_LE);

[~, ~, ~, a_SL]    = standard_atmosphere_calc(0);
[~, ~, ~, a_6000]  = standard_atmosphere_calc(6000);
[~, ~, ~, a_10600] = standard_atmosphere_calc(10600);
speed_of_sound = [a_SL a_6000 a_10600 a_10600 a_10600 a_10600];

kinematic_viscosity = [0.00001461 0.00002416 0.00003706 0.00003706 0.00003706 0.00003706];

Cf_turbulent_calc = @(Re) 0.455 ./ ((log10(Re)).^2.58 .* (1 + 0.144 .* freestream_mach.^2).^0.65); % turbulent

%%%%%%%%%%%%%%%%%%%%%%
%% CD0 CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%%

%% Fuselage %%

% Aircraft parameters
l_fuselage     = aircraft.geometry.fuselage.length;
S_wet_fuselage = aircraft.geometry.fuselage.S_wet; % [m^2]
A_max_fuselage = aircraft.geometry.fuselage.A_max; % Estimated cross-sectional area

Q_fuselage     = 1; % Interference factor, given on slide 16 of lecture 14

Re_fuselage = speed_of_sound .* wing_airfoil_mach .* l_fuselage ./ kinematic_viscosity;
%Re_fuselage_values = [72630000, 81690000, 75060000, 81320000, 87570000, 93830000, 100090000, 112600000, 125110000, 131360000, 137620000, 141370000, 150130000];

% Skin friction coefficients - from slides
Cf_fuselage = Cf_turbulent_calc(Re_fuselage);

% No laminar flow as we're a camoflaged fighter jet
% x_laminar = 0; % Estimated from slide 11 of lecture 14 (military jet with camo = 0)
% Cf_fuselage_laminar   = 1.328 ./ sqrt(Re_fuselage);
% Cf_fuselage_effective = x_laminar * Cf_fuselage_laminar + (1 - x_laminar) * Cf_fuselage_turbulent;

% Fineness ratio and form factor for fuselage, slide 13
f_fuse = l_fuselage / sqrt(4 * pi * A_max_fuselage);
FF_fuselage = 0.9 + (5 / (f_fuse^1.5)) + (f_fuse / 400); 

CD0_fuselage = ((Cf_fuselage .* FF_fuselage .* Q_fuselage .* S_wet_fuselage) / S_ref_wing);

%% Wings (Both) %%

% Wing parameters
S_wet_wing = aircraft.geometry.wing.S_wet; % [m^2]
Q_wing    = 1; % Assumed 1 for a mid-wing configuration

loc_max_thickness_wing = aircraft.geometry.wing.chordwise_loc_max_thickness; % [unitless]
t_c_wing               = aircraft.geometry.wing.t_c_root; % Average is 6%

sweep_HC_wing = aircraft.geometry.wing.sweep_HC; % [degrees] Sweep angle of max thickness line
MAC_wing      = aircraft.geometry.wing.MAC; % [m] chord

Re_wing = Re_fuselage * (MAC_wing / l_fuselage);

Cf_wing = Cf_turbulent_calc(Re_wing);

FF_wing = (1 + (0.6 / (loc_max_thickness_wing)) * (t_c_wing) + 100 * (t_c_wing)^4) * (1.34 * freestream_mach.^0.18 * cos(sweep_HC_wing)^0.28);

CD0_wing = (Cf_wing .* FF_wing * Q_wing * S_wet_wing) ./ S_ref_wing;

%% Horizontal Stabilizer (Both) %%

% Horizontal stabilizer parameters
S_wet_htail = aircraft.geometry.htail.S_wet; % [m^2]
Q_htail = 1.0; % Assumed 1

loc_max_thickness_htail  = aircraft.geometry.htail.chordwise_loc_max_thickness; % [unitless]
t_c_htail                = aircraft.geometry.htail.t_c_root; % Average is 6%

sweep_HC_htail = aircraft.geometry.htail.sweep_HC; % [degrees] Sweep angle of max thickness line
MAC_htail      = aircraft.geometry.htail.MAC; % [m]

Re_htail = Re_fuselage * (MAC_htail / l_fuselage);

Cf_htail = Cf_turbulent_calc(Re_htail);

FF_htail = (1 + (0.6 / (loc_max_thickness_htail)) * (t_c_htail) + 100 * (t_c_htail)^4) * (1.34 * freestream_mach.^0.18 * cos(sweep_HC_htail)^0.28);

CD0_htail = (Cf_htail .* FF_htail * Q_htail * S_wet_htail) ./ S_ref_wing;

%% Vertical Stabilizer (Both) %%

% Horizontal stabilizer parameters
S_wet_vtail = aircraft.geometry.vtail.S_wet; % [m^2]
Q_vtail = 1.0; % Assumed 1

loc_max_thickness_vtail  = aircraft.geometry.vtail.chordwise_loc_max_thickness; % [unitless]
t_c_vtail                = aircraft.geometry.vtail.t_c_root; % Average is 6%

sweep_HC_vtail = aircraft.geometry.vtail.sweep_HC; % [degrees] Sweep angle of max thickness line
MAC_vtail      = aircraft.geometry.vtail.MAC; % [m]

Re_vtail = Re_fuselage * (MAC_vtail / l_fuselage);

Cf_vtail = Cf_turbulent_calc(Re_vtail);

FF_vtail = (1 + (0.6 / (loc_max_thickness_vtail)) * (t_c_vtail) + 100 * (t_c_vtail)^4) * (1.34 * freestream_mach.^0.18 * cos(sweep_HC_vtail)^0.28);

CD0_vtail = (Cf_vtail .* FF_vtail * Q_vtail * S_wet_vtail) ./ S_ref_wing;

%% Landing Gear

%{
% Raymer table 12.6
streamline_wheel_tire_per_area = 0.18;
streamlined_strut_per_area = 0.05;

%frontal areas pulled from cad sketch of lg 11/24/2024
main_wheel_frontal_area = 0.158; %m^2 all from CAD
nose_wheel_frontal_area = 0.065;
main_strut_frontal_area = 0.165;
nose_strut_frontal_area = 0.071;

CD0_main_wheels = streamline_wheel_tire_per_area * main_wheel_frontal_area * 2;
CD0_nose_wheels = streamline_wheel_tire_per_area * nose_wheel_frontal_area * 2;
CD0_main_struts = streamlined_strut_per_area     * main_strut_frontal_area * 2;
CD0_nose_strut  = streamlined_strut_per_area     * nose_strut_frontal_area * 1; % only one of these

CD0_lg = CD0_main_wheels + CD0_nose_wheels + CD0_main_struts + CD0_nose_strut;
%}

CD0_lg = 0.015;  % Placeholder value from raymer

%% Miscellaneous Drag %%

CD0_misc = 0; % Assumed to be zero because no main sources apply to our aircraft

%% Leakage and Protuberance Drag %%

CD0_lp_percent = 0.02; % Estimated from table in slides slide 20, 5% of total parasite drag

%% Flap Drag %%

F_flap = 0.0144; % for plain flaps, lecture 14 slide 24

cf_c = aircraft.geometry.wing.c_flapped_over_c; % ratio of flapped chord to chord

S_flapped = aircraft.geometry.wing.S_flapped; % [m^2]

flap_deflect_takeoff = aircraft.geometry.wing.flap_deflect_takeoff;
flap_deflect_landing = aircraft.geometry.wing.flap_deflect_landing;

delta_CD0_takeoff_flaps_slats = F_flap * (cf_c) * (S_flapped / S_ref_wing) * (rad2deg(flap_deflect_takeoff) - 10);
delta_CD0_landing_flaps_slats = F_flap * (cf_c) * (S_flapped / S_ref_wing) * (rad2deg(flap_deflect_landing) - 10);

%% Total Parasitic Drag Calc %%

CD0_component_sum  = CD0_wing + % CD0_fuselage + CD0_htail + CD0_vtail + CD0_inlets;

aero.CD0.cruise = (CD0_component_sum(3) + CD0_misc)/(1-CD0_lp_percent); % 5 % of cd0 is leakage and protruberance
aero.CD0.dash  = (CD0_component_sum(6) + CD0_misc)/(1-CD0_lp_percent); 

% aero.CD0.takeoff_landing_clean = (CD0_component_sum(1) + CD0_misc)/(1-CD0_lp_percent); % 5 % of cd0 is leakage and protruberance
% 
% aero.CD0.takeoff_flaps_slats      = aero.CD0.takeoff_landing_clean + delta_CD0_takeoff_flaps_slats;
% aero.CD0.takeoff_flaps_slats_gear = aero.CD0.takeoff_flaps_slats + CD0_lg;
% 
% aero.CD0.landing_flaps_slats      = aero.CD0.takeoff_landing_clean + delta_CD0_landing_flaps_slats;
% aero.CD0.landing_flaps_slats_gear = aero.CD0.landing_flaps_slats + CD0_lg;

%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE e VALUES %%
%%%%%%%%%%%%%%%%%%%%%%%%

aero.e.cruise              = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.cruise, 0, 0.98);
aero.e.dash                = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.dash, 0, 0.98);
% aero.e.takeoff_flaps_slats = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.takeoff_flaps_slats, 0, 0.98);
% aero.e.landing_flaps_slats = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.landing_flaps_slats, 0, 0.98);
% 
% aero.e.htail = 1.78 * (1 - (0.045 * aircraft.geometry.htail.AR^0.68) ) - 0.64; % from the presentation slide 26

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LIFT INDUCED DRAG CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AR_wing = aircraft.geometry.wing.AR;

aero.CDi.cruise              = aero.CL.cruise^2 / (pi * AR_wing * aero.e.cruise);
aero.CDi.dash                = aero.CL.dash^2   / (pi * AR_wing * aero.e.cruise);

aero.CDi.takeoff_flaps_slats = aero.CL.takeoff_flaps_slats^2 / (pi * AR_wing * aero.e.takeoff_flaps_slats);
aero.CDi.landing_flaps_slats = aero.CL.landing_flaps_slats^2 / (pi * AR_wing * aero.e.landing_flaps_slats);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TRIM DRAG CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CMac_w spanwise points to integrate over 12 points, sectional Cl 12 
% simulations

%{
Kf = 0.033; % Fusselage pitching moment factor obtained from table from NACA TR 711 with %l_fus = 0.55
Wf = 2.4; % Max fusselage width

CM_fus_coeff = Kf * l_fuselage * Wf^2 / (wing.MAC * ...
    wing.S_ref);

CM_fus_SLF = CM_fus_coeff *  0;
CM_fus_TO  = CM_fus_coeff * 12;
CM_fus_L   = CM_fus_coeff * 16;

xt = htail.xMAC + 0.25 * htail.MAC;
xw = wing.xMAC + 0.25 * wing.MAC;

xt_comp = htail.xMAC + 0.5 * htail.MAC;
xw_comp = wing.xMAC  + 0.5 *  wing.MAC;

wing_chords = linspace(wing.c_root, wing.c_tip, 12);

b = linspace(0, (wing.b/2)-1.3,12); % Evenly spaced points along single wing span

b_xloc = linspace(1.3, wing.b/2,12); % To figure out x displacements along wing by using sweep

x_root = 1.3 .* tan(wing.sweep_QC);
x_root_comp = 1.3 .* tan(wing.sweep_HC);

x_ac = b_xloc .* tan(wing.sweep_QC) - x_root;

% Update value for M = 1.6 (only flight point at which airfoil sees supersonic flow)
x_ac_comp = b_xloc .* tan(wing.sweep_HC) - x_root_comp;

Re_chords = Re_fuselage' * wing_chords / l_fuselage;

% Changes in Cl along span are small for all but twisted sections at wing
% tip where airfoil AoA = 0 (last 2)
Cl = [0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.5279586, 0.3000464, 0.3000464; % M = 0.282 TO
1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.300741, 1.141948, 1.141948; ... % M = 0.282 L
0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.5545099, 0.3118555, 0.3118555; ... % 0.54
0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.6088894, 0.3456586, 0.3456586; ... % 0.85
0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.6550923, 0.3568663, 0.3568663; ... % 0.9
0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.7320457, 0.4254425, 0.4254425; ... % 1.2
0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, 0.2170855, -0.02614533, -0.02614533; ... % 1.6
0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9020024, 0.9065286, 0.9065286; ... % Del TO flaps
0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.524337, 0.567356, 0.567356]; % Del L flaps

% Changes in Cm along span are small for all but twisted sections at wing
% tip where airfoil AoA = 0 (last 2)

Cm_ac = [-0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.0794227, -0.07812929, -0.07812929; % M = 0.282 TO
-0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.05963526, -0.06916824, -0.06916824; ... % M = 0.282 L
-0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08260348, -0.08149004, -0.08149004; ... % 0.54
-0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.08520622, -0.09074765, -0.09074765; ... % 0.85
-0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.0932449, -0.09374932, -0.09374932; ... % 0.9
-0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1694612, -0.1518031, -0.1518031; ... % 1.2
-0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.1090707, -0.02614533, -0.02614533; ...; % 1.6
-0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.2471044, -0.24567651, -0.24567651; ... % Del TO flaps
-0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19837374, -0.19649686, -0.19649686]; % Del L flaps

CM_ac_w = zeros(1,9);

CM_ac_minus_tail = zeros(1,7);

CL_tail = zeros(1,7);

CD_trim = zeros(1,7);

CM_norm = 1 / (wing.MAC * wing.S_ref); % Normalize CM_ac_w integrals by wing dimensions

CL_t_coeff = xt / (htail.volume_coefficient * (xt - xw));

CL_t_coeff_comp = xt_comp / (htail.volume_coefficient * (xt_comp - xw_comp));

%aircraft.aerodynamics.CL.combat = 0.9 * 0.2170855; % HOPEFULLY THIS WILL
%ENLARGE OUR DESIGN SPACE MAINEFEST!!!!! B-)

CL_wing = [aero.CL.takeoff_flaps_slats, aero.CL.landing_flaps_slats, 0.9 * 0.5545099, ...
    aero.CL.cruise, 0.9 * 0.6550923, 0.9 * 0.7320457, 0.9 * 0.2170855];

for k = 1:length(CM_ac_w)
    
    left_func = Cl(k,:) .* wing_chords .* x_ac;
    right_func = Cm_ac(k,:) .* wing_chords.^2;

    if k == 7
        left_func = Cl(k,:) .* wing_chords .* x_ac_comp;
    end

    left_int = -2 * trapz(left_func, b);

    right_int = 2 * trapz(right_func, b);

    CM_ac_w(k) = CM_norm * (left_int + right_int);

end

for j = 1:length(CL_tail)
    
    if j == 1
        CM_ac_minus_tail(j) = CM_ac_w(j) + CM_fus_TO + CM_ac_w(7);
    elseif j == 2
        CM_ac_minus_tail(j) = CM_ac_w(j) + CM_fus_L + CM_ac_w(8);
    else
        CM_ac_minus_tail(j) = CM_ac_w(j) + CM_fus_SLF;
    end
    
    
    if j == 7
        CL_tail(j) = (CL_wing(j) * (xw / wing.MAC) + CM_ac_minus_tail(j)) * CL_t_coeff;
    else
        CL_tail(j) = (CL_wing(j) * (xw_comp / wing.MAC) + CM_ac_minus_tail(j)) * CL_t_coeff_comp;
    end

    CD_trim(j) = CL_tail(j)^2 * (htail.S_ref / (pi * aero.e.htail * htail.AR * wing.S_ref));

end

aero.CD_trim = CD_trim;
aero.CL_htail = CL_tail;
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TRIM DRAG CALCULATIONS IF CL_T IS STILL TOO BIG %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CL_tail = [0.9 0.6 0.7 0.72 0.78 0.2]; % MADE UP
CL_tail_landing = 1;
 
CD_trim = CL_tail.^2 * (htail.S_ref / (pi * aero.e.htail * htail.AR * wing.S_ref));
 
aero.CD_trim = CD_trim;
aero.CL_htail = CL_tail;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WAVE DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Values taken from CFD simulations:
flight_mach = [0.282, 0.54, 0.85, 0.9, 0.928, 0.953, 0.978, 1.002, 1.027, 1.052, 1.076, 1.101, 1.126, 1.151, 1.2, 1.6];
Cd_cfd = [0.00794828, 0.007731049, 0.008301784, 0.008040219, 0.008208084, 0.008468099, 0.008778918, 0.009233597, 0.01002093, 0.01143649, 0.01251037, 0.01714696, 0.02499639, 0.03132697, 0.04084863, 0.04596498];
M_DD = 0.95; % From airfoil sectional CFD analysis
M_crit  = M_DD - (0.1 / 80)^(1/3);
aero.CD_wave = 20 * (freestream_mach - M_crit).^4;
aero.CD_wave(1) = 0; %no wave drag at slow speeds
aero.CD_wave(2) = 0; %no wave drag at slow speeds

% figure()
% scatter(flight_mach,Cd_cfd)
% title('Change in Wing Airfoil Drag Coefficient with Mach Number')
% xlabel('Flight Mach Number')
% ylabel('Drag Coefficient')
% hold on
% xline(0.95,'r--',LineWidth=0.5);
% legend('','Drag Divergence Mach = 0.95')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TOTAL DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TODO ADD WAVE, TRIM DRAG. These are calculated for a variety of Mach numbers. find out how to integrate that array
aero.CD.cruise = aero.CD0.cruise + aero.CDi.cruise + aero.CD_trim(3) + aero.CD_wave(3);
aero.CD.dash = aero.CD0.dash + aero.CDi.dash + aero.CD_trim(6) + aero.CD_wave(6);
aero.CD.takeoff_flaps_slats      = aero.CD0.takeoff_flaps_slats      + aero.CDi.takeoff_flaps_slats + aero.CD_trim(1);
aero.CD.takeoff_flaps_slats_gear = aero.CD0.takeoff_flaps_slats_gear + aero.CDi.takeoff_flaps_slats + aero.CD_trim(1);
aero.CD.landing_flaps_slats      = aero.CD0.landing_flaps_slats      + aero.CDi.landing_flaps_slats + aero.CD_trim(2);
aero.CD.landing_flaps_slats_gear = aero.CD0.landing_flaps_slats_gear + aero.CDi.landing_flaps_slats + aero.CD_trim(2);

%{
% Plot to compare drag values with configurations
figure()
y_values = [aero.CD.cruise, aero.CD.takeoff_flaps_slats, aero.CD.takeoff_flaps_slats_gear, ...
    aero.CD.landing_flaps_slats, aero.CD.landing_flaps_slats_gear];
bar(y_values);
xticklabels(["Clean", "Take Off Configuration - No L.G.", ...
             "Take Off Configuration - L.G.", "Landing Configuration - No L.G.", ...
             "Landing Configuration - L.G."]);
% Add value markers above bars
for k = 1:length(y_values)
    text(k, y_values(k), sprintf('%.2f', y_values(k)), ... % Format value as needed
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', ...
         'FontSize', 10, 'Color', 'black');
end
title('Aircraft Drag Coefficient at Different Configurations')
data = [CD0_wing(3), CD0_fuselage(3), CD0_htail(3), CD0_vtail(3), CD0_lp_percent(3)];
labels = ['Wing: 0.007','Fusselage: 0.0147','Horizontal Tail: 0.0011','Vertical Tail: 0.6135','Leakage and Protuberance: 0.02'];
figure()
piechart(data, labels);
title("Aircraft Component Contributions to CD0 - Clean Configuration")
%}

%% REASSIGN %%
aircraft.aerodynamics = aero;
aircraft.geometry.htail = htail;

end