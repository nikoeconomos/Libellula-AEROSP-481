% Aerosp 481 Group 3 - Libellula 
function total_prop_cost = prop_cost_calc(aircraft)
% Description: This function generates a struct that holds parameters used in
% calculating the cost of the propulsion system of the aircraft.
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct with specs
% 
% OUTPUTS:
% --------------------------------------------
%    total_prop_cost - Total cost of the propulsion system, in 2024 dollars
%                       
% 
% See also: block_time_calc.m, ff_total_calc.m
% Author:                          Joon
% Version history revision notes:
%                                  v1: 9/14/2024
%                                  v1.1: 9/15/2024 - Modified to use
%                                  aircraft struct input argument. (Joon)
    
    
    block_time = block_time_calc(aircraft);
    % vvv PARAMETERIZE THIS SECTION IF NEEDED!!! vvv
    base_year = 1993;
    then_year = 2024;
    bcef = 5.17053+0.104981*(base_year-2006);
    tcef = 5.17053+0.104981*(then_year-2006);
    cef = tcef/bcef;
    % ^^^ PARAMETERIZE THIS SECTION IF NEEDED!!! ^^^
    T_max_lbf = aircraft.propulsion.T_max*0.224809/aircraft.propulsion.engine_count; %Thrust of an individual engine, in lbf
    Cml = (0.645+(0.05*T_max_lbf/10000))*(0.566+0.434/block_time)*aircraft.propulsion.maintenance_labor_rate;
    Cmm = (25+(18*T_max_lbf/(10000*aircraft.propulsion.engine_count)))*(0.62+0.38/block_time)*cef;
    engine_maint_cost = aircraft.propulsion.engine_count*(Cml+Cmm)*block_time;
    total_prop_cost = aircraft.propulsion.engine_cost + aircraft.propulsion.fuel_cost + aircraft.propulsion.oil_cost + engine_maint_cost;
end