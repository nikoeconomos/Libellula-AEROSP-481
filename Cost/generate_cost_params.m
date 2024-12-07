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
% Author:                          Niko
% Version history revision notes:
%                                  v1: 9/14/2024
%                                  v2: 10/29/2024
%                                  v3: 12/7/2024

%%%%%%%%%%%%%%%%%%%%%%%%
%% General Parameters %%
%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.cost = struct();
cost = aircraft.cost;

target_year = 2024;

block_time = block_time_calc(aircraft); % for DCA

CEF_calc = @(byear, tyear) (5.17053 + 0.104981 *(tyear-2006))/(5.17053 + 0.104981*(byear - 2006)); %From metabook chapter 3

x = 0.926; %(95% learning curve))
learning_curve_95 = @(H1, Q) H1 * (1/Q)^(1-x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DAPCA IV CALCULATIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IMPORTANT VARIABLES

DAPCA_base_year = 2012;

W_e  = aircraft.weight.empty;

[~, ~, rho_SL, ~] = standard_atmosphere_calc(0); % kg/m3
[~, ~, rho_c,  ~] = standard_atmosphere_calc(10668); % kg/m3
TAS_to_EAS = @(V_tas, rho) V_tas * sqrt(rho / rho_SL); % TAS to EAS conversion

V_max_tas = velocity_from_flight_cond(aircraft.performance.mach.dash, 10668);
V_max     = TAS_to_EAS(V_max_tas, rho_c); % m/s of EAS

Q = 1000; % Production number
FTA = 6; % Flight test aircraft

N_eng = Q; % Number of engines required

fudge_factor_composite = 1.8; % for materials pg 697


%% Engine & Avionics

cost_avi_percent_flyaway = 0.4; % raymer pg 698, can be bumped up to 40 according to roskam pg 367 sec 8

% engine cost, based on contract with Lockhead Martin F-16 Fleet in 2000 (adjusted for inflation)
engine_base_year = 2000;
engine_order_80  = 400000000; % from source online
engine_cost_base = engine_order_80/80;

cost.engine = adjust_cost_inflation_calc(engine_cost_base, engine_base_year, target_year);

%% RTDE DAPCA RATES & COST

RE = adjust_cost_inflation_calc(115, DAPCA_base_year, target_year);  % Engineering rate
RT = adjust_cost_inflation_calc(118, DAPCA_base_year, target_year);  % Tooling rate
RM = adjust_cost_inflation_calc(98,  DAPCA_base_year, target_year);  % Manufacturing rate
RQ = adjust_cost_inflation_calc(108, DAPCA_base_year, target_year);  % Quality control rate

% Equations based on the provided image, all for MKS units
HE = (5.18  * W_e^0.777 * V_max^0.894 * Q^0.163) * fudge_factor_composite; % engineering hours
HT = (7.22  * W_e^0.777 * V_max^0.696 * Q^0.263) * fudge_factor_composite; % tooling hours
HM = (10.5  * W_e^0.820 * V_max^0.484 * Q^0.641) * fudge_factor_composite; % manufacturing hours
HQ = (0.133 * HM) * fudge_factor_composite; % quality contorl hours

HM_adj = learning_curve_95(HM, Q); % adjust for learning curve for manufacturing hours only, 95 % because we expect to see less improvement in newer programs
HQ_adj = learning_curve_95(HQ, Q); 

cost.engineering   = HE    *RE;
cost.tooling       = HT    *RT;
cost.manufacturing = HM_adj*RM;
cost.quality_ctrl  = HQ_adj*RQ;

%% Cost of development

CD_2012 = 67.400 * W_e^0.630 * V_max^1.3;               % development support cost
CF_2012 = 1974   * W_e^0.325 * V_max^0.822 * FTA^1.21;  % flight test cost
CM_2012 = 31.2   * W_e^0.921 * V_max^0.621 * Q^0.799;      % manufacturing materials cost

cost.development_support    = adjust_cost_inflation_calc(CD_2012, DAPCA_base_year, target_year);
cost.flight_test            = adjust_cost_inflation_calc(CF_2012, DAPCA_base_year, target_year);
cost.manufacturing_material = adjust_cost_inflation_calc(CM_2012, DAPCA_base_year, target_year);

% Loop to converge on avionics cost
tol = 1e-3;
converged = false;

cost_curr = 25000000000; % initial estimate of 25 billion

while converged == false
        
    cost.avionics = cost_curr*cost_avi_percent_flyaway;

    cost_new = cost.engineering + ...
               cost.tooling + ...       
               cost.manufacturing + ...
               cost.quality_ctrl + ...
               cost.development_support + ...
               cost.flight_test + ...
               cost.manufacturing_material + ...
               cost.engine*N_eng + ...
               cost.avionics;

    if abs(cost_new - cost_curr) <= tol
        converged = true;
    end

    cost_curr = cost_new;
end

cost.total = cost_curr;


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Roskam Caq Section 8 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Finish this for more granularity
%{
W_TO = ConvMass(aircraft.weight.togw, 'kg', 'lb'); % lb
W_ampr = 10^(0.1936 + 0.8645 * log10(W_TO)); % roskam pt 8 3.8 % lb

[~, ~, rho_SL, ~] = standard_atmosphere_calc(0); % kg/m3
[~, ~, rho_c,  ~] = standard_atmosphere_calc(10668); % kg/m3
TAS_to_EAS = @(V_tas, rho) V_tas * sqrt(rho / rho_SL); % TAS to EAS conversion

V_max_tas =  ConvVel(velocity_from_flight_cond(aircraft.performance.mach.dash, 10668), 'm/s', 'ft/s');
V_max = TAS_to_EAS(V_max_tas, rho_c);

N_rdte = 10; % number of flight test aircraft, 6-20 for fighters

F_diff = 2.0; % factor of aggressiveness. 2 because first of its kind autonomous fighter
F_cad  = 0.8; %for manufactures which are experienced using CAD

MHR_aed_r = 0.0396 * (W_ampr^0.791) * (V_max^1.526) * (N_rdte^0.183) * (F_diff) * (F_cad);

R_e_r = 

C_aed_r = MHR_aed_r * R_e_r;
%}

%%%%%%%%%%%%%%%%%%%%%
%% OPERATING COSTS %%
%%%%%%%%%%%%%%%%%%%%%


%% Labor %

maintenance_labor_rate = 24.81; % $ as of June 2024


%% FUEL %%

t_mis = sum(aircraft.mission.time);
U_annflt = 325; % middle of the range, ramer table 6.1

N_mission = U_annflt/t_mis;

%N_serv = Q

F_OL = 1.005;
%W_f = 

fuel_price = 2.14/0.00378541; % $/m3 as of September 13, 2024
oil_price = 113.92/0.00378541; % $/m3 as of September 13, 2024
fuel_cost = 1.02*aircraft.weight.ff*aircraft.weight.togw*fuel_price/aircraft.weight.density.fuel;
oil_cost  = 1.02*aircraft.weight.components.oil*oil_price/aircraft.weight.density.oil;



%% Engine maintenance %%

engine_base_year = 1993;

T_max_lbf = ConvForce(aircraft.propulsion.T_max, 'N', 'lbf');

Cml_eng = (0.645+(0.05*T_max_lbf/10000))*(0.566+0.434/block_time)*maintenance_labor_rate;
Cmm_eng = (25+(18*T_max_lbf/10000))*(0.62+0.38/block_time)*CEF_calc(engine_base_year, target_year);

engine_maint_cost = aircraft.propulsion.num_engines*(Cml_eng+Cmm_eng)*block_time;


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

Uannual = 1.5*10^3 * (3.4546*block_time + 2.994 - (12.289*block_time^2 - 5.6626*block_time + 8.964)^0.5 );

IRa = 0.02; % Hull insurance rate

cost.insurance = (IRa*cost.airframe/Uannual)*block_time;

%% Update struct

aircraft.cost = cost;

end




















