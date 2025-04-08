% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_drag_polar_params(aircraft, CD0_clean)
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

%% ----------- Clean Configuration (Cruise) -----------
% parasite drag coefficient (CD0) for clean configuration
aero.CD0.cruise = CD0_clean; 

aero.e.cruise = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.cruise, 0, 0.98);
aero.CD.cruise = aero.CD_parabolic_drag_polar_calc(aero.CD0.cruise, aero.CL.cruise, aero.e.cruise);

%% Maneuver/combat

aero.e.supersonic = 0.5; %historical values from aerotoolbox
aero.CL.combat = aircraft.aerodynamics.CL.dash;

%%
aircraft.aerodynamics = aero; % REASSIGN

% %% ----------- Takeoff Configuration 2 (Flaps Deployed, gear up ) -----------
% 
% % calculate new parasitic drag
% delta_CD0_takeoff_flaps_slats = 0.010;  % Additional drag due to takeoff flaps, metabook table 4.2
% aero.CD0.takeoff_flaps_slats = aero.CD0.cruise + delta_CD0_takeoff_flaps_slats;
% 
% aero.e.takeoff_flaps_slats = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.takeoff_flaps_slats, 0,  0.98);
% 
% aero.CD.takeoff_flaps_slats = aero.CD_parabolic_drag_polar_calc(aero.CD0.takeoff_flaps_slats, aero.CL.takeoff_flaps_slats, aero.e.takeoff_flaps_slats);
% 
% %% ----------- Takeoff Configuration 1 (Flaps deployed, gear down) -------------
% 
% delta_CD0_gear_down = 0.015;  % Additional drag due to LG, metabook table 4.2
% aero.CD0.takeoff_flaps_slats_gear = aero.CD0.cruise + delta_CD0_takeoff_flaps_slats + delta_CD0_gear_down;
% aero.CD.takeoff_flaps_slats_gear = aero.CD_parabolic_drag_polar_calc(aero.CD0.takeoff_flaps_slats_gear, aero.CL.takeoff_flaps_slats, aero.e.takeoff_flaps_slats);
% 
% %% ----------- Landing Configuration 1 (Flaps, gear up) -----------
% 
% % calculate new parasitic drag
% delta_CD0_landing_flaps_slats = 0.055;  % Additional drag due to landing flaps, metabook table 4.2
% aero.CD0.landing_flaps_slats = aero.CD0.cruise + delta_CD0_landing_flaps_slats;
% 
% %aero.e_landing_flaps = 0.70; % from table 4.2 metabook
% aero.e.landing_flaps_slats = oswaldfactor(aircraft.geometry.wing.AR, aircraft.geometry.wing.sweep_LE,'shevell', aero.CD0.landing_flaps_slats, 0,  0.98);
% aero.CD.landing_flaps_slats = aero.CD_parabolic_drag_polar_calc(aero.CD0.landing_flaps_slats, aero.CL.landing_flaps_slats, aero.e.landing_flaps_slats);
% 
% %% ----------- Landing Configuration 2 (Flaps and Gear Deployed) -----------
% 
% delta_CD0_gear_down = 0.015;  % Additional drag due to LG, metabook table 4.2
% aero.CD0.landing_flaps_slats_gear = aero.CD0.cruise + delta_CD0_landing_flaps_slats + delta_CD0_gear_down;
% 
% aero.CD.landing_flaps_slats_gear = aero.CD_parabolic_drag_polar_calc(aero.CD0.landing_flaps_slats_gear, aero.CL.landing_flaps_slats, aero.e.landing_flaps_slats);
% 
% aero.LD.max_landing_flaps_gear = aero.LD_max_calc(aero.e.landing_flaps_slats, aero.CD0.landing_flaps_slats_gear);

end