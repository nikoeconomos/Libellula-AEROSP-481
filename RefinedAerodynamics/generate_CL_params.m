function [aircraft] = generate_CL_params(aircraft)
% Description: 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct
%    
% 
% OUTPUTS:
% --------------------------------------------
%    plugs in Cl max values and gets CL for different conditions                   
% 
% See also:
% Author:                          Juan
% Version history revision notes:
%                                  v1: 11/24/2024

%% Initial wing parameters %%

aircraft.geometry.S_wet_regression_calc = @(W0) ConvArea( 10^(-0.1289)*(ConvMass(W0,'kg','lbm'))^0.7506, 'ft2','m2'); 
aircraft.geometry.length_regression_calc = @(W0) 0.389*W0^0.39; % this is a historical regression from Raymer table 6.3

% aircraft.geometry.wing.AR = 3.6; %From trade studies

wing = aircraft.geometry.wing;

% wing.sweep_LE = deg2rad(44.9); %radians
% wing.S_ref = 25.25;

aircraft.performance.design_point.S_ref_1 = aircraft.geometry.wing.S_ref;

wing.S_flapped = 7.23*2; % TODO UPDATE
wing.S_slatted = 7.23*2; % TODO UPDATE

wing.b = sqrt(wing.AR * wing.S_ref);

wing.sweep_flap_hinge = deg2rad(wing.sweep_LE - 13.1);
wing.sweep_slat_hinge = deg2rad(wing.sweep_LE - 1.6); % [rad]

wing.c_flapped_over_c = 0.3; % ratio of flapped chord to chord
wing.c_slatted_over_c = 0.1; 

wing.flap_deflect_takeoff = deg2rad(15);
wing.flap_deflect_landing = deg2rad(30);
wing.slat_deflect_takeoff = deg2rad(7);
wing.slat_deflect_landing = deg2rad(16);

aircraft.geometry.wing = wing;

%% Define constant parameters

sectional_clean_Cl  = 0.5248542; % From simulation at AOA = 2, takeoff speed

sectional_cruise_Cl = 0.6305; % From simulation at AOA = 2, cruise

% From simulation at AOA = 2 (incidence angle)
sectional_slat_TO_Cl = 0.7371579; % deflection of 30 degrees
sectional_flap_TO_Cl = 1.295017; % deflection of 25 degrees

% From simulation at AOA = 10
sectional_slat_L_Cl = 1.492933; % deflection of 20 degrees
sectional_flap_L_Cl = 1.713832; % deflection of 20 degrees

del_Cl_TO_slat = abs(sectional_clean_Cl - sectional_slat_TO_Cl);
del_Cl_TO_flap = abs(sectional_clean_Cl - sectional_flap_TO_Cl);

del_Cl_L_slat = abs(sectional_clean_Cl - sectional_slat_L_Cl);
del_Cl_L_flap = abs(sectional_clean_Cl - sectional_flap_L_Cl);


%% Calculate change in wing CL

aircraft.aerodynamics.CL.takeoff_clean = 0.9 * sectional_clean_Cl;
base_CL_w = aircraft.aerodynamics.CL.takeoff_clean;

aircraft.aerodynamics.CL.cruise = 0.9 * sectional_cruise_Cl;

% Take Off TODO include which raymer eq this was pulled from

del_CL_wing_TO_slat = 0.9 * del_Cl_TO_slat * wing.S_slatted/wing.S_ref * cos(wing.sweep_slat_hinge);
del_CL_wing_TO_flap = 0.9 * del_Cl_TO_flap * wing.S_flapped/wing.S_ref * cos(wing.sweep_flap_hinge);

aircraft.aerodynamics.CL.takeoff_flaps_slats = base_CL_w + del_CL_wing_TO_slat + del_CL_wing_TO_flap;

% Landing

del_CL_wing_L_slat = 0.9 * del_Cl_L_slat * wing.S_slatted/wing.S_ref * cos(wing.sweep_slat_hinge);
del_CL_wing_L_flap = 0.9 * del_Cl_L_flap * wing.S_flapped/wing.S_ref * cos(wing.sweep_flap_hinge);

aircraft.aerodynamics.CL.landing_flaps_slats = base_CL_w + del_CL_wing_L_slat + del_CL_wing_L_flap;

aircraft.aerodynamics.CL.dash = 0.9*0.2140571;

end