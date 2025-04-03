% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_plot_cost_params(aircraft)
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

fudge_factor_composite = 1.8; % for materials pg 697


%% Engine & Avionics

cost_avi_percent_flyaway = 0.4; % raymer pg 698, can be bumped up to 40 according to roskam pg 367 sec 8

% engine cost, based on contract with Lockhead Martin F-16 Fleet in 2000 (adjusted for inflation)
engine_base_year = 2000;
engine_order_80  = 400000000; % from source online
engine_cost_base = engine_order_80/80;
engine_cost = adjust_cost_inflation_calc(engine_cost_base, engine_base_year, target_year);

N_eng = Q; % Number of engines required, single engine plane

cost.RTDE_flyaway.engines = engine_cost*N_eng;

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

cost.RTDE_flyaway.engineering   = HE    *RE;
cost.RTDE_flyaway.tooling       = HT    *RT;
cost.RTDE_flyaway.manufacturing = HM_adj*RM;
cost.RTDE_flyaway.quality_ctrl  = HQ_adj*RQ;

%% Cost of development

CD_2012 = 67.400 * W_e^0.630 * V_max^1.3;               % development support cost
CF_2012 = 1974   * W_e^0.325 * V_max^0.822 * FTA^1.21;  % flight test cost
CM_2012 = 31.2   * W_e^0.921 * V_max^0.621 * Q^0.799;   % manufacturing materials cost

cost.RTDE_flyaway.development_support    = adjust_cost_inflation_calc(CD_2012, DAPCA_base_year, target_year);
cost.RTDE_flyaway.flight_test            = adjust_cost_inflation_calc(CF_2012, DAPCA_base_year, target_year);
cost.RTDE_flyaway.manufacturing_material = adjust_cost_inflation_calc(CM_2012, DAPCA_base_year, target_year);

% Loop to converge on avionics cost
tol = 1e-3;
converged = false;

cost_curr = 25000000000; % initial estimate of 25 billion

while converged == false
        
    cost.RTDE_flyaway.avionics = cost_curr*cost_avi_percent_flyaway;

    cost_new = cost.RTDE_flyaway.engineering + ...
               cost.RTDE_flyaway.tooling + ...       
               cost.RTDE_flyaway.manufacturing + ...
               cost.RTDE_flyaway.quality_ctrl + ...
               cost.RTDE_flyaway.development_support + ...
               cost.RTDE_flyaway.flight_test + ...
               cost.RTDE_flyaway.manufacturing_material + ...
               cost.RTDE_flyaway.engines + ...
               cost.RTDE_flyaway.avionics;

    if abs(cost_new - cost_curr) <= tol
        converged = true;
    end

    cost_curr = cost_new;
end

cost.RTDE_flyaway.total = cost_curr;
cost.RTDE_flyaway.average = cost_curr/Q;

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

cost.operation = struct();

%% FUEL ROSKAM 6.1 %% 

% Assuming worst case that every mission is DCA

t_mis = sum(aircraft.mission.time)/3600; % in hours
U_annflt  = 350; % middle of the range, ramer table 6.1 fligth hours per aircplane per year
N_mission = U_annflt/t_mis;

N_acq  = Q;
N_res  = 0.1*N_acq;

N_yr = 40; % number of years in service, upper amount in peacetime because assuming new aircraft last longer

L_R = 2.0; % ANNUAL LOSS RATE OF AIRCRAFT PER 10^5 FLYING HOURS, avg taken from table 6.2 roskam part 8

% Loop to converge on pair of service and lost aircraft
tol = 1e-3;
converged = false;

N_serv = 1000; % initial estimate of 25 billion
N_loss = 0;
while converged == false
 
    N_loss_new = L_R/(10^5) * N_serv * U_annflt * N_yr;
    N_serv_new = N_acq - N_res - 0.5*N_loss_new;

    if abs(N_loss_new - N_loss) <= tol
        if abs(N_serv_new - N_serv) <= tol
            converged = true;
        end
    end

    N_loss = N_loss_new;
    N_serv = N_serv_new;
end

F_OL = 1.005; %oil and lubricant factor

W_f = aircraft.weight.components.fuel; % kg

JP4_price_per_gallon = adjust_cost_inflation_calc(3.06, 2020, target_year); % from FY2020
FP = JP4_price_per_gallon/0.00378541;%$/m3

JP4_density_lb_per_ft3 = 50.420; % at 72 degrees F, lb/ft3
FD = JP4_density_lb_per_ft3*16.0185; %kg/m3

cost.operation.fuel_oil_lubricant = (F_OL * W_f * FP/FD * N_mission * N_serv * N_yr);

%% Direct personnel 6.2 %%

% flight crew

R_cr   = 1.1; % crew ratio roskam table 6.1
N_crew = 2; %2 operators on the ground, similar to reaper (sensors and pilot)

Pay_crew_1990 = 29268 + 12*400 + 12000; % may be out of date due to congressional action
Pay_crew      = adjust_cost_inflation_calc(Pay_crew_1990, 1990, target_year);

OHR_crew = 3.0; %given by roskam pg 154

cost.operation.direct_personnel.flight_crew = N_serv * N_crew * R_cr * Pay_crew * OHR_crew * N_yr;

% maintenance crew

MHR_flthr = 35; % upper range in table 6.5
R_mml = adjust_cost_inflation_calc(45, 1989, target_year); % eq 6.12

cost.operation.direct_personnel.maintenance_crew  = N_serv * N_yr * U_annflt * MHR_flthr * R_mml;

cost.operation.direct_personnel.total = cost.operation.direct_personnel.maintenance_crew +  cost.operation.direct_personnel.flight_crew;

%% Indirect personnel 6.3 %%

f_persind = mean([0.14, 0.2]); % table 6.6 avg of the fighters

%cost.operation.indirect_personnel = f_persind * C_OPS; see total OPs cost below

%% Consumable materials 6.4 %%

R_conmat = adjust_cost_inflation_calc(6.5, 1989, target_year);

cost.operation.consumable_materials = N_serv * N_yr * U_annflt * MHR_flthr * R_conmat;

%% Cost of Spares C_spares 6.5 %%

f_spares = mean([0.13 0.16 0.27, 0.12 0.16]); % table 6.6 avg of all of the planes

% cost.operation.spares = f_spares * C_OPS;

%% Cost of depot 6.6 %%

f_depot = mean([0.2 0.15 0.22 0.13 0.16]); % table 6.6 avg of all of the planes

% %cost.operation.depot = f_depot* C_OPS;

%% Miscellaneous items Cmisc 6.7 %%

cost.operation.misc = 4*cost.operation.consumable_materials; % roskam eq 6.19

%% Total operating cost %%

% Loop to converge on individual/total costs of operation
tol = 1e-3;
converged = false;

C_OPS = 22000000000; %initial estimate
while converged == false
 
    cost.operation.indirect_personnel = f_persind * C_OPS;
    cost.operation.spares             = f_spares * C_OPS;
    cost.operation.depot              = f_depot * C_OPS;

    C_OPS_new = cost.operation.fuel_oil_lubricant                + ... % pre calculated
                cost.operation.direct_personnel.flight_crew      + ... % pre calculated
                cost.operation.direct_personnel.maintenance_crew + ... % pre calculated
                cost.operation.indirect_personnel                + ...
                cost.operation.consumable_materials              + ... % pre calculated
                cost.operation.spares                            + ...
                cost.operation.depot                             + ...
                cost.operation.misc;                                   % pre calculated

    if abs(C_OPS_new - C_OPS) <= tol
        if abs(N_serv_new - N_serv) <= tol
            converged = true;
        end
    end

    C_OPS = C_OPS_new;
end

cost.operation.total = C_OPS;
total_service_hours = N_serv * N_yr * U_annflt;
cost.operation.per_hour = C_OPS/total_service_hours;

%%%%%%%%%%%%%%
%% PLOTTING %%
%%%%%%%%%%%%%%

% %% RTDE Flyaway %%
% 
% % Exclude "total" and create a pie chart
% labels = {'Engine', 'Quality Control', 'Engineering', 'Tooling', 'Manufacturing', ...
%           'Manufacturing Material', 'Flight Test', 'Avionics', 'Development Support'};
% 
% values = [cost.RTDE_flyaway.engines, cost.RTDE_flyaway.quality_ctrl, cost.RTDE_flyaway.engineering, ...
%           cost.RTDE_flyaway.tooling, cost.RTDE_flyaway.manufacturing, ...
%           cost.RTDE_flyaway.manufacturing_material, cost.RTDE_flyaway.flight_test, ...
%           cost.RTDE_flyaway.avionics,cost.RTDE_flyaway.development_support];
% 
% % Calculate the total
% cost.RTDE_flyaway.total = sum(values);
% 
% % Less muted color palette (slightly more vibrant)
% colors = [145, 163, 176; 174, 200, 202; 143, 179, 157; 191, 171, 141; ...
%           131, 119, 139; 167, 149, 139; 171, 186, 158; 149, 151, 169; ...
%           139, 139, 127] / 255;  % RGB normalized to 0-1
% 
% % Create the pie chart with percentages
% figure;
% h = pie(values);
% 
% % Add labels with percentages, showing 2 decimal points
% percentLabels = arrayfun(@(x) ...
%     [labels{x}, ' (', sprintf('%.2f', (values(x) / cost.RTDE_flyaway.total) * 100), '%)'], ...
%     1:length(values), 'UniformOutput', false);
% 
% textHandles = findobj(h, 'Type', 'Text');
% for i = 1:length(textHandles)
%     textHandles(i).String = percentLabels{i};
% end
% 
% % Apply less muted colors to each segment
% patchHandles = findobj(h, 'Type', 'Patch'); % Find pie chart patches
% for i = 1:length(patchHandles)
%     patchHandles(i).FaceColor = colors(i, :); % Assign vibrant color
% end
% 
% % Add a title with the rounded total formatted with commas
% rounded_total = round(cost.RTDE_flyaway.total / 1e6) * 1e6;
% formatted_total = sprintf('%0.0f', rounded_total);  % Format the number as a string with no decimal places
% formatted_total_with_commas = regexprep(formatted_total, '(?<=\d)(?=(\d{3})+(?!\d))', ',');
% 
% title(['Program RTDE & Flyaway Costs Breakdown']);
% 
% 
% %% Operations %%
% 
% % Exclude "total" and create a pie chart
% labels = {'Fuel, Oil, Lubricant', 'Flight Crew', 'Maintenance Crew', ...
%           'Consumable Materials', 'Misc', 'Indirect Personnel', ...
%           'Spares', 'Depot'};
% 
% values = [cost.operation.fuel_oil_lubricant, cost.operation.direct_personnel.flight_crew, ...
%           cost.operation.direct_personnel.maintenance_crew, cost.operation.consumable_materials, ...
%           cost.operation.misc, cost.operation.indirect_personnel, cost.operation.spares, ...
%           cost.operation.depot];
% 
% % Calculate the total
% cost.operation.total = sum(values);
% 
% % Updated muted blue-gray-purple color palette with navy-like darker shades
% colors = [142, 160, 186; 171, 184, 197; 154, 153, 174; 186, 175, 192; ...
%           123, 133, 161; 102, 116, 138; 89, 101, 129; 78, 92, 113] / 255;

% Create the pie chart with percentages
% figure;
% h = pie(values);
% 
% % Add labels with percentages, formatted to 2 decimal points
% percentLabels = arrayfun(@(x) ...
%     [labels{x}, ' (', sprintf('%.2f', (values(x) / cost.operation.total) * 100), '%)'], ...
%     1:length(values), 'UniformOutput', false);
% textHandles = findobj(h, 'Type', 'Text');
% for i = 1:length(textHandles)
%     textHandles(i).String = percentLabels{i};
% end
% 
% % Apply new colors to each segment
% patchHandles = findobj(h, 'Type', 'Patch'); % Find pie chart patches
% for i = 1:length(patchHandles)
%     patchHandles(i).FaceColor = colors(i, :); % Assign new color
% end
% 
% % Add a title with the total, formatted with commas
% rounded_total = round(cost.operation.total / 1e6) * 1e6;
% formatted_total = sprintf('%0.0f', rounded_total);  % Format without decimal places
% formatted_total_with_commas = regexprep(formatted_total, '(?<=\d)(?=(\d{3})+(?!\d))', ',');
% 
% title(['Program Operation Costs Breakdown']);


%% Update struct

aircraft.cost = cost;

end
