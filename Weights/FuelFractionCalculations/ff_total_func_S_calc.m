function [ff_total_adjusted] = ff_total_func_S_calc(aircraft,S)
% Description: This function calculates the total fuel fraction for the
% any mission profile, using S to calculate CD0. 
%
% mission profile specs are generated on a case by case basis in their
% respective functions
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft specifications struct.
%
% OUTPUTS:
% --------------------------------------------
%    mission_ff - Double. Fuel empty fraction calculated for DCA mission [unitless]
% 
% See also: generate_DCA_mission(), max_lift_to_drag(), TBU
% Author:                          niko
% Version history revision notes:
%                                  v1: 9/14/2024

%% LD CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%

% TODO : EDIT FOR NEW CONSIDERATIONS. LD AND ALL OUR CONSTANTS SHOULD BE A VARIABLE WE CALCULATE
% UPFRONT IN THE AERODYNAMICS CODE AND ACCESS LATER

% Lift to drag estimated based on the F-35A, currently omitting the calculation method on the metabook, therefore
% function argument doesn't matter as lift_to_drag_calc() is currently defined and all argument values can be arbitrary.
%[LD_max, LD_cruise] = LD_calc(); 

% Expecting decrease in aerodynamic efficiency during dash due to 
% supersonic flight conditions, arbitrarily picked a loss of 7%
%LD_dash = 0.93 * LD_cruise; 

% Assuming aircraft is optimized for combat and has maximum lift_to_drag
% ratio during this mission segment
AR = 2.663; %based on historical data
e = 0.75;%based on historical data
k = 1 / (pi * AR * e);
% Calculate Drag Coefficient, Lift-to-Drag Ratio, and Cruise
Cf = 0.0035; % skin friction coefficient estimate figure 4.4 meta 
CD0 = CD0_func_S_calc(aircraft, S, Cf); % Calculate C_D0 as function of S

% Call the calculate_LD function
LD_ratio = LD_calc_new(CD0, k);

%% FUEL FRACTION DETERMINATION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cSL = 27191.05; % Specific fuel consumption at sea level [1/hr]
T = 79.2; % Maximum thrust [kN]

[togw] = togw_as_func_of_T_S_calc(aircraft, S);
W0 = togw;

mission = aircraft.mission;
mission.ff = NaN(size(mission.segments));

% this for loop goes through every defined mission segment and calculates
% the FF based on the defined type.
for i = 1:length(aircraft.mission.segments)

    if mission.segments(i) == "takeoff"
        mission.ff(i) = 1 - cSL * (15/60) * (0.05 * T / W0); % 15 min at 5% max thrust

    elseif mission.segments(i) == "climb"
        mission.ff(i) = 1 - cSL * (1/60) * (T / W0); % [unitless], pulled from meta guide

    elseif mission.segments(i) == "cruise"
        range = mission.range(i);
        TSFC = mission.TSFC(i);
        velocity = mission.velocity(i);
        mission.ff(i) = ff_cruise_calc(range, TSFC, velocity, LD_cruise);

    elseif mission.segments(i) == "dash" % differs only in LD from cruise
        range = mission.range(i);
        TSFC = mission.TSFC(i);
        velocity = mission.velocity(i);
        mission.ff(i) = ff_cruise_calc(range, TSFC, velocity, LD_dash);

    elseif mission.segments(i) == "combat" % differs only in LD from cruise, assumed to use max as it's optimized for combat
        range = mission.range(i);
        TSFC = mission.TSFC(i);
        velocity = mission.velocity(i);
        mission.ff(i) = ff_cruise_calc(range, TSFC, velocity, LD_max);

    elseif mission.segments(i) == "escort" % differs only in LD from cruise, assumed to use max but subject to change
        range = mission.range(i);
        TSFC = mission.TSFC(i);
        velocity = mission.velocity(i);
        mission.ff(i) = ff_cruise_calc(range, TSFC, velocity, LD_max);

    elseif mission.segments(i) == "loiter" || mission.segments(i) == "reserve" % currently no difference between them
        endurance = mission.endurance(i);
        TSFC = mission.TSFC(i);
        mission.ff(i) = ff_loiter_calc(endurance,TSFC,LD_cruise);

    elseif mission.segments(i) == "optimize" % TODO: UNSURE IF NEEDED. From the "return to optimal alt/speed" line in RFP.
        mission.ff(i) = 1; % set to 1 so it has no effect on total

    elseif mission.segments(i) == "descent"
        mission.ff(i) = 0.990; % [unitless] pulled from meta guide

    else
        error("Unaccepted mission segment variable name.")
    end

end

%% TOTAL FF CALCULATION %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Multiply fuel fractions at each stage to obtain total fuel empty fraction 
% from fuel consumption during mission segments

ff_total = mission.ff(1);
for i = 2:length(mission.ff) %start at the second index
    ff_total = ff_total*mission.ff(i);
end

% Second climb is accounted for in this equation with the same standard
% fuel fraction from Table 2.2 of the metabook TODO: Juan what does this
% mean? Can we take out optimize?

% Using equation 2.33 from metabook to account for trapped and reserve fuel
ff_total_adjusted = 1.06*(1-ff_total);

end

