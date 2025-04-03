function [aircraft] = load_inputs(file,ind)
% Description: This function loads an ordered column of inputs the outputs 
% into their respective indices within the aircraft struct. It can be
% called again based on the design of experiments and initiates the sizing
% process
% 
%
%
% INPUTS:
% --------------------------------------------
%    file - m x n matrix containing input values
%           - m is number of rows equal to the number of inputs
%           - n is number of columns equal to the number of design points
%           in experiment
%    ind - column index to load into sizing code
%
% OUTPUTS:
% --------------------------------------------
%    aircraft struct with parametrized input values
% 
% See also: fuel_weight(), velocity_from_flight_cond(), max_lift_to_drag(), main.m
% Author:                          Juan
% Version history revision notes:
%                                  v1: 3/19/2025

%%%%%%%%%%%%%
%% Mission %%
%%%%%%%%%%%%%

aircraft.weight.weapons.num_missiles = file(ind,1); % Missile count

aircraft.performance.mach.max_sustained_turn = file(ind,2); % First maneuver speed

aircraft.performance.maneuver_mach = file(ind,3);

aircraft.performance.max_maneuver_g_load = file(ind,4);

aircraft.performance.max_instantaneous_turn_rate = deg2rad(file(ind,5)); % Maximum instantaneous turn rate

aircraft.performance.corner_speed_TAS = file(ind,6); % Corner speed

%%%%%%%%%%%%%%%%%
%% Wing Design %%
%%%%%%%%%%%%%%%%%

aircraft.geometry.wing.S_ref = file(ind,7); % Wing aspect ratio

aircraft.geometry.wing.AR = file(ind,8); % Wing aspect ratio

aircraft.geometry.wing.sweep_LE = file(ind,9); % Wing sweep angle

aircraft.geometry.wing.taper_ratio = file(ind,10); % Wing taper ratio

%%%%%%%%%%%%%%%%%%%%%%
%% Engine Selection %%
%%%%%%%%%%%%%%%%%%%%%%
 % 
 % = file(9,ind); % Engine dry weight
 % 
 % = file(10,ind); % Engine Military Thrust
 % 
 % = file(11,ind); % Engine Maximum Thrust
 % 
 % = file(12,ind); % Engine TSFC

end