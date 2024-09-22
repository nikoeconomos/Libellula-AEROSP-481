% Aerosp 481 Group 3 - Libellula 
function [aircraft] = generate_cruise_speed(aircraft)
% Description: This function generates a struct of aircraft parameters that
% relate to cruise speed.
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct with specs
% 
% OUTPUTS:
% --------------------------------------------
%    cruise_speed of the aircraft at the different missions
%                       
% 
% See also: None
% Author:                          Victoria
% Version history revision notes:
%                                  v1: 9/22/2024

    % Similar to maneuver, but set n=1
    aircraft.aerodynamics.wing_loading_maneuver = linspace(0,250,250); %psf
    aircraft.aerodynamics.wing_loading_maneuver_psi = aircraft.aerodynamics.wing_loading_maneuver/12^2; %psi, for calculations
    aircraft.aerodynamics.parasitic_drag_coeff_est = aircraft.aerodynamics.skin_friction_coefficient*aircraft.aerodynamics.Swet./(aircraft.weight.togw./aircraft.aerodynamics.wing_loading_maneuver_psi);
    [t,p,rho,a] = standard_atmosphere_calc(10668); %35000ft = 10668m
    q = rho*(a*aircraft.performance.max_sustained_turn_mach)^2/2; % Pa
    n = 1; % For cruise
    q = q*0.000145; %psi
    aircraft.aerodynamics.thrust_cruise_speed = q*aircraft.aerodynamics.parasitic_drag_coeff_est./aircraft.aerodynamics.wing_loading_maneuver_psi + (n/(q*pi*aircraft.geometry.aspect_ratio*aircraft.aerodynamics.span_efficiency))*aircraft.aerodynamics.wing_loading_maneuver_psi;
    
    % Plotting
    plot(aircraft.aerodynamics.cruise_speed,aircraft.aerodynamics.thrust_cruise_speed);
    title('T/W vs W/S plot cruise requirement');
    xlabel('W/S (psi)'); ylabel('T/W');

end