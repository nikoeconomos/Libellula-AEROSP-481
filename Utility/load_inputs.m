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

aircraft.weight.weapons.num_missiles = file(1,ind); % Missile count

aircraft.performance.mach.max_sustained_turn = file(2,ind); % First maneuver speed

aircraft.performance.mach.min_sustained_turn = file(3,ind);

aircraft.performance.max_instantaneous_turn_rate = deg2rad(file(4,ind)); % Maximum instantaneous turn rate

aircraft.performance.corner_speed_TAS = file(5,ind); % Corner speed

%%%%%%%%%%%%%%%%%
%% Wing Design %%
%%%%%%%%%%%%%%%%%

aircraft.geometry.wing.AR = file(6,ind); % Wing aspect ratio

aircraft.geometry.wing.sweep_LE = file(7,ind); % Wing sweep angle

aircraft.geometry.wing.taper_ratio = file(8,ind); % Wing taper ratio

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