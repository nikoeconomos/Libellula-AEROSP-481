% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_init_weight_params(aircraft)
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

% Number of crew members to include onboard [TODO update if remote piloting]
aircraft.weight.components.crew = 0; % [number]

%% EMPTY WEIGHT %%
%%%%%%%%%%%%%%%%%%

% A guess weight for the start of the togw calculation. The empty weight of an F-35
aircraft.weight.guess = 15000; % [kg]

aircraft.weight.W_e_regression_calc = @ (W_0) 0.882*(ConvMass(W_0,'kg','lbm')^-0.055);

%% PAYLOAD WEIGHTS %%
%%%%%%%%%%%%%%%%%%%%%

% Weight of the missile we are tasked with using, AIM120 327 lb from RFP
% aircraft.weight.weapons.num_missiles = 4;
aircraft.weight.weapons.missile = ConvMass(327, 'lbm', 'kg'); %[kg]

% Weight of the cannon we are tasked with using, 275LB from RFP. not part of payload
aircraft.weight.weapons.m61a1.cannon = ConvMass(275, 'lbm', 'kg'); %[kg]

% Weight of the cannon we are tasked with using not ammo weight. 300 lbs from RFP
aircraft.weight.weapons.m61a1.feed_system = ConvMass(300, 'lbm', 'kg'); %[kg]

aircraft.weight.weapons.m61a1.num_rounds = 500;
aircraft.weight.weapons.m61a1.round = ConvMass(0.58, 'lbm', 'kg'); 
aircraft.weight.weapons.m61a1.casing = ConvMass(0.26, 'lbm', 'kg'); 
aircraft.weight.weapons.m61a1.bullet = aircraft.weight.weapons.m61a1.round - aircraft.weight.weapons.m61a1.casing;

aircraft.weight.weapons.m61a1.ammo = aircraft.weight.weapons.m61a1.round*aircraft.weight.weapons.m61a1.num_rounds;

aircraft.weight.weapons.m61a1.total_loaded = aircraft.weight.weapons.m61a1.feed_system + aircraft.weight.weapons.m61a1.cannon + aircraft.weight.weapons.m61a1.ammo;

% Weight of all usable weapons systems aboard. Missile weight*num missiles + weight of cannon ammo
aircraft.weight.components.payload = aircraft.weight.weapons.num_missiles*aircraft.weight.weapons.missile + ...
                          aircraft.weight.weapons.m61a1.feed_system + aircraft.weight.weapons.m61a1.ammo + aircraft.weight.weapons.m61a1.cannon; %aircraft.weight.weapons.m61a1.total_loaded;  %[kg]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GOVERNMENT FURNISHED EQUIPMENT %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    w = aircraft.weight;

    % Define mass of each component in kg
    w.gfe.ICNIA    = ConvMass(100, 'lbm', 'kg');
    w.gfe.databus = ConvMass(10, 'lbm', 'kg');
    w.gfe.INEWS    = ConvMass(100, 'lbm', 'kg');

    w.gfe.VMS = ConvMass(50, 'lbm', 'kg');

    w.gfe.EES  = ConvMass(300, 'lbm', 'kg');
    w.gfe.APU                = ConvMass(100, 'lbm', 'kg');
    w.gfe.IRSTS              = ConvMass(50, 'lbm', 'kg');
    w.gfe.AESA               = ConvMass(450, 'lbm', 'kg'); % active array radar

       
    % Calculate the total mass of all components
    w.components.gfe_total = w.gfe.ICNIA + w.gfe.databus + w.gfe.INEWS + ...
                             w.gfe.VMS + w.gfe.EES + ...
                             w.gfe.APU + w.gfe.IRSTS + w.gfe.AESA;

    aircraft.weight = w;

%% COMPONENT DENSITIES %%
%%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.weight.density.wing_area = 44; % kg/m^2, from Metabook pg 76

aircraft.weight.density.fuel = 802.837; %[kg/m^3] 6.7 lb per gal from RFP

aircraft.weight.density.oil = 1003.55; % kg/m3

aircraft.weight.density.aluminium = 2700;    % density of aluminium [kg/m^3]

%% Initial Weight Calculations %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aircraft.weight.ff = ff_total_calc(aircraft);

% INITIAL GUESS, TO BE UPDATED LATER IN PRELIM SIZING
[togw,w_e] = togw_and_w_empty_calc(aircraft);

aircraft.weight.togw = togw;
aircraft.weight.empty = w_e;

aircraft.weight.PDI_ff = 0.1530;
aircraft.weight.max_landing_weight = 1-(aircraft.weight.PDI_ff/2)* aircraft.weight.togw; % Googled common share of togw that is max landing weight

%     %% FORMULAS AND CALCULATIONS FOR WING REFINEMENT %%
% 
%     aircraft.weight.func.MAC_calc   = @(c_root, c_tip) 2/3*(c_root + c_tip - (c_root*c_tip)/(c_root + c_tip));
%     aircraft.weight.func.y_MAC_calc = @(taper_ratio, b) b * ( (1 + 2*taper_ratio) / (1 + taper_ratio))/6;
% 
%     aircraft.weight.func.xMAC_calc = @(xRLE, b, c_root, c_tip, sweep_LE) xRLE + b/6 * (c_root + 2*c_tip)/(c_root + c_tip) + tan(sweep_LE);
% 
%     aircraft.weight.func.x40MAC_calc = @(xMAC, MAC) xMAC + 0.4*MAC;
% 
% 
%     %% FUDGE FACTORS %% 
% 
%     % (Metabook 7.3.4) Chose lowest end of fudge factors for max weight
%     % saving
% 
%     aircraft.weight.fudge_factor.wing = 0.85;
%     aircraft.weight.fudge_factor.tail = 0.83;
%     aircraft.weight.fudge_factor.fuselage = 0.90;
% 
% aircraft = generate_wing_geometry(aircraft);
% 
%     %%%%%%%%%%%%%%%
%     %% WING MASS %%
%     %%%%%%%%%%%%%%%
% 
%     % AREA DENSITY ALREADY DEFINED IN GEOMETRY
% 
%     % Area based calculation
%     aircraft.weight.func.wing_weight_area = @(S_ref) (S_ref * aircraft.weight.density.wing_area) * aircraft.weight.fudge_factor.wing; % 44 * S
% 
%     % RAYMER METABOOK 7.11, cargo/transport
%     N_z = aircraft.performance.load_factor.ultimate_upper_limit;
%     aircraft.weight.func.wing_weight_raymer = @(W_0) aircraft.weight.fudge_factor.wing * ...
%                                                      ConvMass( 0.0051 * ( ConvMass(W_0, 'kg', 'lbm') * N_z)^0.557 ...
%                                                                     * ConvArea(wing.S_ref, 'm2', 'ft2')^0.649 * wing.AR^0.5 ... 
%                                                                     * (wing.t_c_root)^(-0.4) * (1 + wing.taper_ratio)^0.1 * (cos(wing.sweep_QC))^(-1) ...
%                                                                     * ConvArea(wing.S_ctrl_surf, 'm2', 'ft2')^0.1, ...
%                                                                     'lbm', 'kg'); % metabook 7.11  
% 
%     % KROO METABOOK 7.12, general?
%     n = aircraft.performance.load_factor.ultimate_upper_limit;
%     aircraft.weight.func.wing_weight_kroo   = @(W_0, W_zf) aircraft.weight.fudge_factor.wing *  ...
%                                                            ConvMass( 4.22 * ConvArea(wing.S_ref, 'm2', 'ft2') ... 
%                                                                         + 1.642e-6 * (n * ConvLength(wing.b^3, 'm', 'ft') * sqrt(ConvMass(W_0, 'kg', 'lbm') * ConvMass(W_zf, 'kg', 'lbm'))...
%                                                                             * (1 + 2 * wing.taper_ratio)) ...
%                                                                           / ( ConvArea(wing.S_ref, 'm2', 'ft2') * (wing.t_c_root) ...
%                                                                             * cos(wing.sweep_QC)^2 * (1 + wing.taper_ratio)), ...
%                                                                             'lbm', 'kg'); % sweep QC should be of the structural elastic axis
% 
%     % ROSKAM PART 5, 5.9 USAF SELECTED FORMULA A = Aspect ratio AR S = wing
%     % area in ft^2
%     K_w = 1; %for fixed wing aircraft
%     n_ult = aircraft.performance.load_factor.ultimate_upper_limit;
%     aircraft.weight.func.wing_weight_roskam_USAF = @(WTO) ...
%                                                         ConvMass( 3.08 * ( ...
%                                                                          ( (K_w * n_ult * ConvMass(WTO, 'kg', 'lbm') ) / (wing.t_c_root) ) ...
%                                                                          * ( ( tan(wing.sweep_LE) - 2 * (1 - wing.taper_ratio) / (wing.AR * (1 + wing.taper_ratio) ) )^2 + 1) * 10^-6 ...
%                                                                          )^0.593 ...
%                                                                          * ( wing.AR*( 1 + wing.taper_ratio ) )^0.89 * ( ConvArea(wing.S_ref, 'm2', 'ft2') )^0.741 ...
%                                                                          * aircraft.weight.fudge_factor.wing, ...
%                                                                          'lbm', 'kg');
% 
%     % ROSKAM PART 5, 5.10 USN A = Aspect ratio AR S = wing area in ft^2
%     K_w = 1; %for fixed wing aircraft
%     n_ult = aircraft.performance.load_factor.ultimate_upper_limit;
%     aircraft.weight.func.wing_weight_roskam_USN = @(WTO)  ...
%                                                        ConvMass( 19.29 * ( ...
%                                                                          ( (K_w * n_ult * ConvMass(WTO, 'kg', 'lbm') ) / (wing.t_c_root) ) ...
%                                                                          * ( ( tan(wing.sweep_LE) - 2 * (1 - wing.taper_ratio) / (wing.AR * (1 + wing.taper_ratio) ) )^2 + 1) * 10^-6 ...
%                                                                          )^0.464 ...
%                                                                          * ( wing.AR*( 1 + wing.taper_ratio ) )^0.70 * ( ConvArea(wing.S_ref, 'm2', 'ft2') )^0.58 ...
%                                                                          * aircraft.weight.fudge_factor.wing, ...
%                                                                          'lbm', 'kg');

end