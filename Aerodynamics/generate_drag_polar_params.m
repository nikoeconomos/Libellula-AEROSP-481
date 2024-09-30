% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_drag_polar_params(aircraft, AR)
% Description: This function generates a struct that holds parameters used in
% calculating the cost of the aerodynamics system of the aircraft.
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
% Author:                          Niko
% Version history revision notes:
%                                  v1: 9/23/2024


%% Parasite Drag Coefficent & grabbing constants

aero = aircraft.aerodynamics;

Cf = aero.Cf;  % Skin friction coefficient (metabook table 4.4)
S_wet = aircraft.geometry.S_wet;
S_ref = aircraft.geometry.S_ref;

%% ----------- Clean Configuration (Cruise) -----------
% parasite drag coefficient (CD0) for clean configuration
aero.CD0_clean = CD0_calc(Cf, S_wet, S_ref);

aero.e_cruise = 0.80; %from table 4.2 metabook
aero.CL_cruise = 1.25; % from 06 Preliminary sizing presentation Slide 48
aero.CD_cruise = CD_parabolic_drag_polar_calc(aero.CD0_clean, aero.CL_cruise,...
                                                               AR, aero.e_cruise);

aero.LD_max_cruise = LD_max_calc(aero.e_cruise, aero.CD0_clean, AR);
aero.LD_cruise = aero.CL_cruise/aero.CD_cruise;

%% ----------- Takeoff Configuration 2 (Flaps Deployed, gear up ) -----------

aero.e_takeoff_flaps = 0.75; % from table 4.2 metabook
aero.CL_takeoff_flaps = 1.7; % from 06 Preliminary sizing presentation Slide 48

% calculate new parasitic drag
delta_CD0_takeoff_flaps = 0.010;  % Additional drag due to takeoff flaps, metabook table 4.2
aero.CD0_takeoff_flaps = aero.CD0_clean + delta_CD0_takeoff_flaps;

aero.CD_takeoff_flaps = CD_parabolic_drag_polar_calc(aero.CD0_takeoff_flaps, aero.CL_takeoff_flaps, ...
                                                                           AR, aero.e_takeoff_flaps);

aero.LD_max_takeoff_flaps = LD_max_calc(aero.e_takeoff_flaps, aero.CD0_takeoff_flaps, AR);
aero.LD_takeoff_flaps = aero.CL_takeoff_flaps/aero.CD_takeoff_flaps;

%% ----------- Takeoff Configuration 1 (Flaps deployed, gear down) -------------

delta_CD0_gear_down = 0.015;  % Additional drag due to LG, metabook table 4.2
aero.CD0_takeoff_flaps_gear = aero.CD0_clean + delta_CD0_takeoff_flaps + delta_CD0_gear_down;

aero.CD_takeoff_flaps_gear = CD_parabolic_drag_polar_calc(aero.CD0_takeoff_flaps_gear, aero.CL_takeoff_flaps, ...
                                                                      AR, aero.e_takeoff_flaps);

aero.LD_max_takeoff_flaps_gear = LD_max_calc(aero.e_takeoff_flaps, aero.CD0_takeoff_flaps_gear, AR);
aero.LD_takeoff_flaps_gear = aero.CL_takeoff_flaps/aero.CD_takeoff_flaps_gear;

%% ----------- Landing Configuration 1 (Flaps, gear up) -----------
aero.e_landing_flaps = 0.70; % from table 4.2 metabook
aero.CL_landing_flaps = 2.0; % from 06 Preliminary sizing presentation Slide 48

% calculate new parasitic drag
delta_CD0_landing_flaps = 0.055;  % Additional drag due to landing flaps, metabook table 4.2
aero.CD0_landing_flaps = aero.CD0_clean + delta_CD0_landing_flaps;

aero.CD_landing_flaps = CD_parabolic_drag_polar_calc(aero.CD0_landing_flaps, aero.CL_landing_flaps, ...
                                                                      AR, aero.e_landing_flaps);

aero.LD_max_landing_flaps = LD_max_calc(aero.e_landing_flaps, aero.CD0_landing_flaps, AR);
aero.LD_landing_flaps = aero.CL_landing_flaps/aero.CD_landing_flaps;

%% ----------- Landing Configuration 2 (Flaps and Gear Deployed) -----------

delta_CD0_gear_down = 0.015;  % Additional drag due to LG, metabook table 4.2
aero.CD0_landing_flaps_gear = aero.CD0_clean + delta_CD0_landing_flaps + delta_CD0_gear_down;

aero.CD_landing_flaps_gear = CD_parabolic_drag_polar_calc(aero.CD0_landing_flaps_gear, aero.CL_landing_flaps,...
                                                                           AR, aero.e_landing_flaps);

aero.LD_max_landing_flaps_gear = LD_max_calc(aero.e_landing_flaps, aero.CD0_landing_flaps_gear, AR);
aero.LD_landing_flaps_gear = aero.CL_landing_flaps/aero.CD_landing_flaps_gear;


%%
aircraft.aerodynamics = aero; % REASSIGN

end