% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_performance_params(aircraft)
% Description: This function generates a struct that holds parameters used in
% calculating the initial weight estimate of our aircraft
% 
% 
% INPUTS:
% --------------------------------------------
%    None
% 
% OUTPUTS:
% --------------------------------------------
%    aircraft -struct containing aircraft specifications given by RFP
% 
% See also: None
% Author:                          Niko
% Version history revision notes:
%                                  v1: 9/10/2024
%                                  v1.1: 9/15/2024 - Added tentative
%                                  parameters based on the F100-PW-229.
%                                  v2: 3/11/2025 - Changed relevamt RFP variable inputs
%                                  to be loaded from table, removed design
%                                  point declaaration and moved to separate
%                                  function call inside TW/WS generation
%                                  

aircraft.name = 'Libellula';

%% OUR DESIGN POINTS

%aircraft.performance.TW_design_military = 0.62; % A SPOT WE MANUALLY CHOOSE FROM THE TW-WS DIAGRAM [N/N]
%aircraft.performance.TW_design = 1.05; % A SPOT WE MANUALLY CHOOSE FROM THE TW-WS DIAGRAM [N/N]
%aircraft.performance.WS_design = 550; % A SPOT WE MANUALLY CHOOSE FROM THE TW-WS DIAGRAM, [N/m^2]

%% Loads
aircraft.performance.load_factor.upper_limit = 7; % [g's] with 50% fuel
aircraft.performance.load_factor.lower_limit = -3; % [g's]  with 50% fuel
aircraft.performance.load_factor.ultimate_upper_limit = 7*1.5; % [g's] with 50% fuel
aircraft.performance.load_factor.ultimate_lower_limit = -3*1.5; % [g's]  with 50% fuel
aircraft.performance.dynamic_pressure_load = 102128.48; %[Pa], 2133 psf in rfp

%% Altitude
aircraft.performance.cruise_alt = 10668; % [m]

%% Mach Numbers
aircraft.performance.mach.cruise    = 0.85; % TODO UPDATE --> estimate from online
aircraft.performance.mach.dash      = 1.6; % from rfp
aircraft.performance.mach.max_alt   = 1.6; %[Mach number], at 35000 feet
aircraft.performance.mach.endurance = 0.4; % estimate from online
aircraft.performance.mach.climb   = 0.548; % TODO UPDATE 
aircraft.performance.mach.takeoff = 0.282; %estimate from?
% aircraft.performance.mach.max_sustained_turn = 1.2; %[Mach] from RFP
% aircraft.performance.mach.min_sustained_turn = 0.9; %[Mach] from RFP

m = aircraft.performance.mach;

aircraft.performance.mach.arr = [m.takeoff, m.climb, m.cruise,...
                                 m.min_sustained_turn, m.max_sustained_turn, m.dash];

%% Instantaneous turn

aircraft.performance.bank_angle_360 = deg2rad(60); %[rad] ESTIMATE FROM ONLINE

%% INST TURN

g = 9.8067;

% included in inputs file - aircraft.performance.max_instantaneous_turn_rate = deg2rad(18); %rad/s

% included in inputs file - aircraft.performance.corner_speed_TAS = 262; % knots 
aircraft.performance.corner_speed = aircraft.performance.corner_speed_TAS / 1.944; % m/s TODO UPDATE With VN diagram

aircraft.performance.n_inst = sqrt( ((aircraft.performance.max_instantaneous_turn_rate*aircraft.performance.corner_speed)/g)^2+1); %raymer 5.19

%% MISC

aircraft.safety_factor = 1.5;

aircraft.service_life = 2000; %[hours]

end