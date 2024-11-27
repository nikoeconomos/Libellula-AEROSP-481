% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_cost_params(aircraft)
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
%    aircraft - aircraft param with struct, updated with cost
%    parameters
%                       
% 
% See also: None
% Author:                          Niko, Victoria, and Joon
% Version history revision notes:
%                                  v1: 9/14/2024
%                                  v2: 10/29/2024

%% General Parameters %%
%%%%%%%%%%%%%%%%%%%%%%%

target_year = 2024;

block_time = block_time_calc(aircraft); % for DCA

CEF_calc = @(byear, tyear) (5.17053 + 0.104981 *(tyear-2006))/(5.17053 + 0.104981*(byear - 2006)); %From metabook chapter 3

%% Individual Components %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.cost = struct();

cost = aircraft.cost;

%% Labor %

maintenance_labor_rate = 24.81; % $ as of June 2024

%% PROPULSION %%
fuel_price = 2.14/0.00378541; % $/m3 as of September 13, 2024
oil_price = 113.92/0.00378541; % $/m3 as of September 13, 2024
fuel_cost = 1.02*aircraft.weight.ff*aircraft.weight.togw*fuel_price/aircraft.weight.density.fuel;
oil_cost  = 1.02*aircraft.weight.components.oil*oil_price/aircraft.weight.density.oil;

% Engine maintenance
engine_base_year = 1993;

T_max_lbf = ConvForce(aircraft.propulsion.T_max, 'N', 'lbf');

Cml_eng = (0.645+(0.05*T_max_lbf/10000))*(0.566+0.434/block_time)*maintenance_labor_rate;
Cmm_eng = (25+(18*T_max_lbf/10000))*(0.62+0.38/block_time)*CEF_calc(engine_base_year, target_year);

engine_maint_cost = aircraft.propulsion.num_engines*(Cml_eng+Cmm_eng)*block_time;

% engine cost
cost.engine = 5660000; % Based on contract for F-15EX in 2021 (adjusted for inflation)

cost.aircraft = 10^(0.657+(1.4133*log10(aircraft.weight.togw*2.2))); % From Roskam
cost.airframe = cost.aircraft - cost.engine; %From metabook chapter 3

%% CREW %
crew_base_year = 1993;

% Route factor
route_factor = 4; % Route factor -- estimated, 800 nautical miles is around 1000 miles, domestic flight length, but only 1 pilot on the ground

mission_block_time = block_time_calc(aircraft);
airline_factor = 1; % Estimated

togw_lb = ConvMass(aircraft.weight.togw, 'kg', 'lbm');

% Initialize result
crew_costs = airline_factor * (route_factor * (togw_lb)^0.4 * mission_block_time);

cost.crew = adjust_cost_inflation_calc(crew_costs, crew_base_year, target_year);


%% Airframe maintenance %

airframe_weight = aircraft.weight.empty - aircraft.weight.components.engine;

Cml_af = 1.03*(3+0.067*airframe_weight/1000)*maintenance_labor_rate;

Cmm_af = 1.03*(30*CEF_calc(1989,target_year))+0.79*10^-5*cost.airframe;

airframe_maint = (Cml_af+Cmm_af)*block_time;


%% INSURANCE %%

Uannual = 1.5*10^3* (3.4546*block_time + 2.994 - (12.289*block_time^2 - 5.6626*block_time + 8.964)^0.5 );

IRa = 0.02; % Hull insurance rate

cost.insurance = (IRa*cost.airframe/Uannual)*block_time;

%% Missile cost
missile_cost_base = 386000;  % USD Pulled RFP year
missile_base_year = 2006;
missile_cost_2024 = adjust_cost_inflation_calc(missile_cost_base, missile_base_year, target_year); % USD
cost.missile    = missile_cost_2024*aircraft.weight.weapons.num_missiles;

%% Avionics cost 

avionics_cost_base = 2202000;  % 10% of airplane market price (Raymer)
avionics_base_year = 2006;  
cost.avionics = adjust_cost_inflation_calc(avionics_cost_base, avionics_base_year, target_year); % USD

%% Cannon cost
cannon_cost_base = 250290;  % USD
cannon_base_year = 2006;  
cost.cannon = adjust_cost_inflation_calc(cannon_cost_base, cannon_base_year, target_year); % USD

%% RTDE and flyaway cost from slides page 34

We = ConvMass(aircraft.weight.empty, 'kg', 'lbm');
V = ConvVel(velocity_from_flight_cond(aircraft.performance.mach.dash, 10668), 'm/s', 'ft/s');
Q = 1000; % Production number
FTA = 6; % Flight test aircraft

RE = 86;  % Engineering rate
RT = 88;  % Tooling rate
RQ = 81;  % Quality control rate
RM = 73;  % Manufacturing rate

% Equations based on the provided image
HE = 4.86  * We^0.777 * V^0.894 * Q^0.163;
HT = 5.99  * We^0.777 * V^0.696 * Q^0.263;
HM = 7.37  * We^0.820 * V^0.484 * Q^0.641;
HQ = 0.133 * HM;
CD = 66.0  * We^0.630 * V^1.3;
CF = 1807.1 * We^0.325 * V^0.822 * FTA^1.21;
CM = 16 * We^0.921 * V^0.621 * Q^0.799;

RDT_E_flyaway = HE * RE + HT * RT + HM * RM + HQ * RQ + CD + CF + CM + cost.engine + cost.avionics + cost.cannon;

RTDE_flyaway_adjusted = adjust_cost_inflation_calc(RDT_E_flyaway, 1999, target_year); % slides page 34


%% Flyaway cost with simple Roskam method

[cost.avg_flyaway_cost, cost.learning_curve_costs] = avg_flyaway_cost_calc(cost.aircraft, 1000);

%% Update struct

aircraft.cost = cost;

end




















