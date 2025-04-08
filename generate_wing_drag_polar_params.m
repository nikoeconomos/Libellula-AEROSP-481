function [aircraft] = generate_wing_drag_polar_params(aircraft)

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


%% Leakage and Protuberance Drag %%

CD0_lp_percent = 0.02; % Estimated from table in slides slide 20, 5% of total parasite drag

%% Total Parasitic Drag Calc %%

CD0_component_sum  = CD0_wing + % CD0_fuselage + CD0_htail + CD0_vtail + CD0_inlets;

aero.CD0.cruise = (CD0_component_sum(3) + CD0_misc)/(1-CD0_lp_percent); % 5 % of cd0 is leakage and protruberance
aero.CD0.dash  = (CD0_component_sum(6) + CD0_misc)/(1-CD0_lp_percent); 

%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE e VALUES %%
%%%%%%%%%%%%%%%%%%%%%%%%

aero.e.cruise              = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.cruise, 0, 0.98);
aero.e.dash                = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.dash, 0, 0.98);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LIFT INDUCED DRAG CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AR_wing = aircraft.geometry.wing.AR;

aero.CDi.cruise              = aero.CL.cruise^2 / (pi * AR_wing * aero.e.cruise);
aero.CDi.dash                = aero.CL.dash^2   / (pi * AR_wing * aero.e.cruise);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WAVE DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Values taken from CFD simulations:
flight_mach = [0.282, 0.54, 0.85, 0.9, 0.928, 0.953, 0.978, 1.002, 1.027, 1.052, 1.076, 1.101, 1.126, 1.151, 1.2, 1.6];
Cd_cfd = [0.00794828, 0.007731049, 0.008301784, 0.008040219, 0.008208084, 0.008468099, 0.008778918, 0.009233597, 0.01002093, 0.01143649, 0.01251037, 0.01714696, 0.02499639, 0.03132697, 0.04084863, 0.04596498];
M_DD = 0.95; % From airfoil sectional CFD analysis
M_crit  = M_DD - (0.1 / 80)^(1/3);
aero.CD_wave = 20 * (freestream_mach - M_crit).^4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TOTAL DRAG COEFFICIENT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TODO ADD WAVE, TRIM DRAG. These are calculated for a variety of Mach numbers. find out how to integrate that array
aero.CD.cruise = aero.CD0.cruise + aero.CDi.cruise + aero.CD_trim(3) + aero.CD_wave(3);
aero.CD.dash = aero.CD0.dash + aero.CDi.dash + aero.CD_trim(6) + aero.CD_wave(6);

%% REASSIGN %%
aircraft.aerodynamics = aero;
end