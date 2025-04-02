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
%%%%%%%%%%%%%%%%

aircraft.propulsion.engine_name = 'F110-GE-129';

% number of engines
aircraft.propulsion.num_engines = 1;

% max thrust
aircraft.propulsion.T_max = 129000; %[N] TOTAL THRUST FROM BOTH ENGINES

% military thrust
aircraft.propulsion.T_military = 76300; %[N] TOTAL THRUST

aircraft.propulsion.bypass_ratio = 0.87;

aircraft.propulsion.max_diameter = 1.18; %m

aircraft.propulsion.airflow = 122.4; %kg/s

aircraft.propulsion.length = 4.6; %m


% Equation 1: T / T(V=0) = A * M_inf^(-n) anderson p 176
%T_T_V0 = A * M_inf^(-n);

% Equation 2: T / T0 = (rho / rho_0)^m
%T_T0 = (rho / rho_0)^m;


end