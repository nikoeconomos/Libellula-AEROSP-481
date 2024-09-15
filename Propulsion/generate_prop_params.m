% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_prop_params(aircraft)
% Description: This function generates a struct that holds parameters related to the propulsion system of the aircraft.
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft param with struct
% 
% OUTPUTS:
% --------------------------------------------
%    aircraft - aircraft param with struct, updated with propulsion
%    parameters
%                       
% 
% See also: None
% Author:                          Joon
% Version history revision notes:
%                                  v1: 9/13/2024
%                                  v2: 9/15/2024: Altered input arguments
%                                  to match format of parameter generation
%                                  codes.

%% PARAMETERS %%
%%%%%%%%%%%

aircraft.propulsion.fuel_density = 839.98; % kg/m3
aircraft.propulsion.oil_density = 1003.55; % kg/m3
aircraft.propulsion.maintenance_labor_rate = 24.81; % $ as of June 2024
aircraft.propulsion.weight_oil = 0.0125*aircraft.weight.ff*aircraft.weight.togw*block_time_calc(aircraft)/100;
%% UPDATE AIRCRAFT %%
%%%%%%%%%%%%%%%%%%%%%

%aircraft.propulsion = propulsion;

end