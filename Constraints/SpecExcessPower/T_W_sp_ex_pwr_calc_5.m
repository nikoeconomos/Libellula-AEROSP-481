function [T_W] = T_W_sp_ex_pwr_calc_5(aircraft, W_S)
%
% function [T_W] = SpecExcessPower(aircraft, W_S)
%
% Calculate required thrust-to-weigth ratio from a given wing-loading for a
% sustained turn at a specific excess power Ps, (along with flight 
% conditions and aircraft specs: parasitic drag coefficient and aspect 
% ratio). Feeds into the general calculation, this function is for deciding
% values.
%
% Parameter = Description [units]
%   
% INPUTS:
%   aircraft
%   W_S = Wing loading (at takeoff)          [N/m^2]
%
% OUTPUTS:
%   T_W = Thrust-to-weight ratio             []
% -------------------------------------------------------------------------

alt = ConvLength(0,'ft','m');
mach = aircraft.performance.maneuver_mach;
CD0 = aircraft.aerodynamics.CD0.cruise;
e = aircraft.aerodynamics.e.cruise;
n = aircraft.performance.max_maneuver_g_load;
Ps = ConvLength(300,'ft','m');

T_W = T_W_spec_excess_power_calc_general(aircraft, W_S, alt, mach, CD0, e, n, Ps);

end 