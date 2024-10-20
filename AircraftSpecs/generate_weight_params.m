% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_weight_params(aircraft)
% Description: This function generates a struct for the weights of aircraft
% using various helper methods
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct with specs
% 
% OUTPUTS:
% --------------------------------------------
%    aircraft - aircraft param with struct, updated with weight
%    parameters
%                       
% 
% See also: None
% Author:                          Niko
% Version history revision notes:
%                                  v1: 9/14/2024


%% CREW WEIGHTS %%
%%%%%%%%%%%%%%%%%%

% Average weight of crew member and carry on luggage given by the metabook. No checked baggage included in this.
aircraft.weight.crew_member = 82; % [kg]

% Number of crew members to include onboard [TODO update if remote piloting]
aircraft.weight.crew = 0; % [number]

%% EMPTY WEIGHT %%
%%%%%%%%%%%%%%%%%%

% A guess weight for the start of the togw calculation. The empty weight of an F-35
aircraft.weight.guess = 5000; % [kg]

aircraft.weight.W_e_regression_calc = @ (W_0) 0.882*(ConvMass(W_0,'kg','lbm')^-0.055);

%% PAYLOAD WEIGHTS %%
%%%%%%%%%%%%%%%%%%%%%

% Weight of the missile we are tasked with using, AIM120 327 lb from RFP
aircraft.payload.num_missiles = 6;
aircraft.weight.missile = 148.325; %[kg]

% Weight of the cannon we are tasked with using, 275LB from RFP. not part of payload
aircraft.weight.m61a1 = 124.738; %[kg]

% Weight of the cannon we are tasked with using TODO if this value is
% not ammo weight. 300 lbs from RFP
aircraft.weight.m61a1_feed_system = 136.078; %[kg]

% Weight of all usable weapons systems aboard. Missile weight*num missiles + weight of cannon ammo
aircraft.weight.payload = aircraft.payload.num_missiles*aircraft.weight.missile + ...
                          aircraft.weight.m61a1_feed_system + aircraft.weight.m61a1; %[kg]


%% Initial Weight Calculations %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.weight.ff = ff_total_calc(aircraft);

% INITIAL GUESS, TO BE UPDATED LATER IN PRELIM SIZING
[togw,w_e] = togw_and_w_empty_calc(aircraft);

aircraft.weight.togw = togw;
aircraft.weight.empty = w_e;

aircraft.weight.fuel = aircraft.weight.ff*aircraft.weight.togw;

aircraft.weight.max_landing_weight = 0.85 * aircraft.weight.togw; % Googled common share of togw that is max landing weight

%% COMPONENT DENSITIES %%
%%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.weight.wing_area_density = 44; % kg/m^2, from Metabook pg 76

aircraft.weight.fuel_density = 802.837; %[kg/m^3] 6.7 lb per gal from RFP

aircraft.weight.oil_density = 1003.55; % kg/m3

aircraft.weight.oil = 0.0125*aircraft.weight.fuel*block_time_calc(aircraft)/100;

end