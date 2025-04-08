function [aircraft] = generate_wing_geom_mass(aircraft)
    %%%%%%%%%%%%%%%%%%%
    %% WING GEOMETRY %%
    %%%%%%%%%%%%%%%%%%%

    % for convenience
    wing = aircraft.geometry.wing;

    % wing.AR = aircraft.geometry.wing.AR; 
    % 
    % wing.S_ref = aircraft.geometry.wing.S_ref;
    
    
    %wing.S_wet = 27.35; %from CAD
    
    wing.b = sqrt(wing.AR*wing.S_ref);

    %wing.taper_ratio = 0.35; - now included in load inputs

    wing.c_root = 2*wing.S_ref / ( (1+wing.taper_ratio) * wing.b); % TODO where does this come from? - CAD ACCURATE
    wing.c_tip = wing.c_root*wing.taper_ratio;

    wing.t_c_root                    = 0.05; % 5% tc ratio, from our design airfoil
    %wing.chordwise_loc_max_thickness = 0.50; % input subject to SCREENING

    fuselage_width = 2.6; % max width of fuselage from Libellula Interceptor CAD

    approx_conc_wing = fuselage_width*wing.c_root;

    wing.S_exposed = wing.S_ref - approx_conc_wing; % from CAD

    wing.S_wet = 2 * wing.S_exposed; %m2

    %sweeps
    wing.sweep_LE = aircraft.geometry.wing.sweep_LE; % in radians, set in generate_geometry
    wing.sweep_QC = atan( tan(wing.sweep_LE) - (4 / wing.AR) * ((0.25 * (1 - wing.taper_ratio)) / (1 + wing.taper_ratio)) ); % formula from aerodynamics slide 24
    wing.sweep_HC = atan( tan(wing.sweep_LE) - (4 / wing.AR) * ((0.50 * (1 - wing.taper_ratio)) / (1 + wing.taper_ratio)) );
    wing.sweep_TE = atan( tan(wing.sweep_LE) - (4 / wing.AR) * ((1.00 * (1 - wing.taper_ratio)) / (1 + wing.taper_ratio)) );

    % % locations/MAC
    % wing.xRLE = 6.25;%7.083; %m positino of leading edge of the root chord, from CAD
    % wing.xR25 = wing.xRLE + 0.25*wing.c_root; % position of quarter chord at root of wing
    % 
    % wing.MAC   = aircraft.weight.func.MAC_calc  (wing.c_root, wing.c_tip);
    % wing.y_MAC = aircraft.weight.func.y_MAC_calc(wing.taper_ratio, wing.b);
    % 
    % wing.xMAC   = aircraft.weight.func.xMAC_calc(wing.xRLE, wing.b, wing.c_root, wing.c_tip, wing.sweep_LE);
    % wing.x40MAC = aircraft.weight.func.x40MAC_calc(wing.xMAC, wing.MAC);

    % Flaps and slats (IN GENERATE CL PARAMS)
      
    % re update aircraft struct
    aircraft.geometry.wing = wing;

    %%%%%%%%%%%%%%%
    %% WING MASS %%
    %%%%%%%%%%%%%%%

    % ROSKAM PART 5, 5.9 USAF
    % SELECTED FORMULA
    % A = Aspect ratio AR
    % S = wing area in ft^2
    K_w = 1; %for fixed wing aircraft
    n_ult = aircraft.performance.load_factor.ultimate_upper_limit;
    aircraft.weight.func.wing_weight_roskam_USAF = @(WTO) ...
                                                        ConvMass( 3.08 * ( ...
                                                                         ( (K_w * n_ult * ConvMass(WTO, 'kg', 'lbm') ) / (wing.t_c_root) ) ...
                                                                         * ( ( tan(wing.sweep_LE) - 2 * (1 - wing.taper_ratio) / (wing.AR * (1 + wing.taper_ratio) ) )^2 + 1) * 10^-6 ...
                                                                         )^0.593 ...
                                                                         * ( wing.AR*( 1 + wing.taper_ratio ) )^0.89 * ( ConvArea(wing.S_ref, 'm2', 'ft2') )^0.741 ...
                                                                         * aircraft.weight.fudge_factor.wing, ...
                                                                         'lbm', 'kg');
    

end