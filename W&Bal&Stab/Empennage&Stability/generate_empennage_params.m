function [aircraft] = generate_empennage_params(aircraft)
% Description:
% Generates parameters that describe our empennage
%
% INPUTS:
% --------------------------------------------
%    aircraft
%
% OUTPUTS:
% --------------------------------------------
%    
%    aircraft
%
% 
% Author:                          Juan
% Version history revision notes:
%                                  v2: 11/15/2024


    %%%%%%%%%%%%%%%%%%%%%
    %% Horizontal TAIL %%
    %%%%%%%%%%%%%%%%%%%%%

    aircraft.geometry.htail.AR = 4;

    % for convenience
    htail = aircraft.geometry.htail;

    htail.lever_arm = 0.5 * aircraft.geometry.fuselage.length; % TODO: originally L_F, CONFIRM this is fuselage; lever arm distance between CoM and MAC of horizontal stabilizer 
    
    htail.volume_coefficient = 0.4;  % Raymer decision TODO CONFIRM
    
    htail.S_ref = htail.volume_coefficient * aircraft.geometry.wing.MAC * aircraft.geometry.wing.S_ref  / htail.lever_arm; % TODO CONFIRM WHETHER THIS IS 1 section or both
    htail.S_wet = 7.334; % from CAD

    htail.b = sqrt(htail.AR * htail.S_ref);

    htail.taper_ratio = 0.5;

    htail.c_root = 2*htail.S_ref / ( (1+htail.taper_ratio) * htail.b); % m TODO CONFIRM WHERE CAME FROM
    htail.c_tip  = htail.c_root*htail.taper_ratio;

    htail.sweep_LE = aircraft.geometry.wing.sweep_LE + deg2rad(5); % radians 
    htail.sweep_QC = atan( tan(htail.sweep_LE) - (4 / htail.AR) * ((0.25 * (1 - htail.taper_ratio)) / (1 + htail.taper_ratio)) ); % formula from aerodynamics slide 24
    htail.sweep_HC = atan( tan(htail.sweep_LE) - (4 / htail.AR) * ((0.50 * (1 - htail.taper_ratio)) / (1 + htail.taper_ratio)) );
    htail.sweep_TE = atan( tan(htail.sweep_LE) - (4 / htail.AR) * ((1.00 * (1 - htail.taper_ratio)) / (1 + htail.taper_ratio)) );

    htail.t_c_root                    = 0.0524; % 5% tc ratio, from our 1st optimization airfoil from mach aero
    htail.chordwise_loc_max_thickness = 0.575; % pulled from cad
    
    % htail.xRLE = 14.167; % m position of leading edge of the root chord, from CAD, from nose tip TODO UPDATE

    htail.xRLE = 0.8586 * aircraft.geometry.fuselage.length; % ratio from our interceptor design

    % MAC and CG = at 0.4MAC
    htail.MAC  = aircraft.weight.func.MAC_calc(htail.c_root, htail.c_tip);
    htail.y_MAC = aircraft.weight.func.y_MAC_calc(htail.taper_ratio, htail.b);

    htail.xMAC = aircraft.weight.func.xMAC_calc(htail.xRLE, htail.b, htail.c_root, htail.c_tip, htail.sweep_LE);

    htail.x40MAC = aircraft.weight.func.x40MAC_calc(htail.xMAC, htail.MAC);


    %%%%%%%%%%%%%%%%%%%
    %% Vertical TAIL %%
    %%%%%%%%%%%%%%%%%%%

    aircraft.geometry.vtail.AR = 2; % Highest seen in Raymer

    % for convenience
    vtail = aircraft.geometry.vtail;

    vtail.lever_arm = htail.lever_arm - 0.3; % Move in front of horizontal tail to avoid blanketing

    vtail.volume_coefficient = 0.07; % Raymer

    vtail.S_ref = vtail.volume_coefficient * aircraft.geometry.wing.b * aircraft.geometry.wing.S_ref / vtail.lever_arm; % TODO CONFIRM AND STATE LOCATION OF EQUATION
    vtail.S_wet = 3.943; % from CAD

    vtail.b = sqrt(vtail.AR * 2*vtail.S_ref);

    vtail.taper_ratio = 0.35;

    vtail.c_root = 4*vtail.S_ref / ( (1 + vtail.taper_ratio) * vtail.b); %previously equal to 1.3815 % TODO where did this come from?
    vtail.c_tip  = vtail.c_root*vtail.taper_ratio;  

    vtail.sweep_LE = deg2rad(55); % radians
    vtail.sweep_QC = atan( tan(vtail.sweep_LE) - (4 / vtail.AR) * ((0.25 * (1 - vtail.taper_ratio)) / (1 + vtail.taper_ratio)) ); % formula from aerodynamics slide 24
    vtail.sweep_HC = atan( tan(vtail.sweep_LE) - (4 / vtail.AR) * ((0.50 * (1 - vtail.taper_ratio)) / (1 + vtail.taper_ratio)) );
    vtail.sweep_TE = atan( tan(vtail.sweep_LE) - (4 / vtail.AR) * ((1.00 * (1 - vtail.taper_ratio)) / (1 + vtail.taper_ratio)) );

    vtail.t_c_root                    = 0.033; % 3.33%
    vtail.chordwise_loc_max_thickness = 0.500; % biconvex
    
    vtail.xRLE = 13.663; %m position of leading edge of the root chord, from CAD, from nose tip TODO UPDATE IF NECESSARY 

    % MAC and CG = at 0.4MAC
    vtail.MAC   = aircraft.weight.func.MAC_calc  (vtail.c_root, vtail.c_tip);
    vtail.y_MAC = aircraft.weight.func.y_MAC_calc(vtail.taper_ratio, vtail.b);

    vtail.xMAC   = aircraft.weight.func.xMAC_calc(vtail.xRLE, vtail.b, vtail.c_root, vtail.c_tip, vtail.sweep_LE);
    vtail.x40MAC = aircraft.weight.func.x40MAC_calc(vtail.xMAC, vtail.MAC);

    %% update

    aircraft.geometry.htail = htail;
    aircraft.geometry.vtail = vtail;
    
    
end