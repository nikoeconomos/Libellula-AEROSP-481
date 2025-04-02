function [aircraft] = dt_empty_weight_calc(aircraft, fuel_weight)
% dropTankMass: Estimates the empty structural mass of an aircraft drop tank
%               with elliptical end caps given the fuel mass required.
%
% Syntax:
%   m_empty = dropTankMass(fuel_mass)
%   m_empty = dropTankMass(fuel_mass, fuel_density)
%   m_empty = dropTankMass(fuel_mass, fuel_density, L_cap)
%
% Inputs:
%   fuel_mass   - Fuel mass to be carried by the tank (kg)
%   fuel_density- (Optional) Density of the fuel (kg/m^3). Default: 800.
%   L_cap       - (Optional) Axial semi–length of each elliptical cap (m).
%                 (The cap is modeled as half of a prolate spheroid with
%                  semi–axes [R, R, L_cap] where R = 0.375 m). Default: 0.15.
%
% Assumptions:
%   - The tank has a constant overall diameter D = 0.75 m (thus radius R = 0.375 m).
%   - The fuel volume is stored in a cylindrical section plus two elliptical end caps.
%     The total fuel volume is:
%           V_fuel = π R^2 L_cyl + (4/3) π R^2 L_cap
%   - The skin is a 3 mm (0.003 m) thick aluminium shell covering the full outer
%     surface (cylinder plus both end caps). Aluminium density is assumed to be 2700 kg/m^3.
%   - Hoop frames are placed along the cylindrical section every 0.5 m.
%     Each hoop is approximated as a 1 inch (0.0254 m) thick annular plate with:
%         outer diameter = 0.748 m  →  r_outer = 0.748/2
%         inner diameter = 0.68 m   →  r_inner = 0.68/2.
%   - Stringers: In each gap between hoop frames (n-1 gaps), 6 stringers are used.
%     Each stringer is modeled as a 2 cm x 2 cm (0.02 m x 0.02 m) solid aluminium rod.
%
% Output:
%   m_empty     - Estimated empty structural mass of the tank (kg)
%
% Example:
%   m_empty = dropTankMass(200) % for 200 kg of fuel, with defaults

    % Simplify variable calling
    D = aircraft.geometry.drop_tank.diameter;         % overall tank diameter [m]
    R = aircraft.geometry.drop_tank.radius;          % tank radius [m]
    t_skin = aircraft.geometry.drop_tank.skin_thckness;   % skin thickness [m]
    rho_al = aircraft.weight.density.aluminium;    % density of 6061 aluminium [kg/m^3]
    fuel_density = aircraft.weight.density.fuel; % density of jet-A fuel [kg/m^3]
    g = 9.81;

    % --- Determine the required cylindrical length to hold the fuel ---
    % Total fuel volume needed (m^3)
    
    fuel_mass = fuel_weight / g;

    V_fuel = fuel_mass / fuel_density;

    % Volume of the two elliptical end caps:
    % For an ellipsoid with semi–axes (R, R, L_cap), volume = 4/3 π R^2 L_cap.
    % Each cap is half an ellipsoid so its volume = (2/3) π R^2 L_cap.
    
    L_cap = 2*pi*R;

    V_caps = (4/3) * pi * R^2 * L_cap;
    
    % Solve for cylindrical length L_cyl:
    
    L_cyl = (V_fuel - V_caps) / (pi * R^2);
    
    if L_cyl < 0
        error('Fuel mass is too small to fill the required end caps.');
    end

    % --- Compute skin (aluminium) mass ---
    % 1. Cylindrical portion skin area:
    A_cyl = pi * D * L_cyl;
   
    % 2. Elliptical end caps skin area:
    % Approximate each cap as half of a prolate spheroid with semi–axes a = R and c = L_cap.
    % For a full prolate spheroid (with c>=a) the surface area is:
    %    S = 2*pi*a^2 * (1 + (c/(a*e))*asin(e))
    % where e = sqrt(1 - (a^2/c^2)). Here we use a = R and c = L_cap.
    if L_cap < R
        error('For the prolate spheroid approximation, L_cap must be >= tank radius (%.3f m).', R);
    end

    e = sqrt(1 - (R^2 / L_cap^2));
    S_prolate = 2 * pi * R^2 * (1 + (L_cap/(R*e)) * asin(e));
    
    % Since each end cap is half a prolate spheroid, the total area for both is S_prolate.
    A_caps = S_prolate;
    
    % Total skin area:
    A_skin = A_cyl + A_caps;
    
    % Skin volume:
    V_skin = A_skin * t_skin;
    
    % Skin mass:
    m_skin = V_skin * rho_al;

    % --- Compute hoop frame mass ---
    % Hoop frame geometry (assume inner diameter = 0.68 m and outer diameter = 0.748 m)
    r_outer = 0.748 / 2;  % [m]
    r_inner = 0.68 / 2;   % [m]
    
    A_ring = pi * (r_outer^2 - r_inner^2); % annular area [m^2]
    
    t_hoop = 0.0254;      % hoop plate thickness [m] (1 inch)
    
    V_hoop = A_ring * t_hoop;  % volume of one hoop [m^3]
    
    m_hoop = V_hoop * rho_al;  % mass of one hoop [kg]
    
    % Number of hoops along the cylindrical section (placed every 0.5 m)
    n_hoops = floor(L_cyl / 0.5) + 1;  
    m_hoops = n_hoops * m_hoop;

    % --- Compute stringer mass ---
    % Stringer geometry: 2 cm x 2 cm square rod => side = 0.02 m.
    side_str = 0.02;                % [m]
    A_stringer = side_str^2;        % cross-sectional area [m^2]
    
    % The stringers connect adjacent hoop frames.
    % There are (n_hoops - 1) gaps. For each gap, the average gap length is computed as:
    
    if n_hoops > 1
        gap_length = L_cyl / (n_hoops - 1);
    else
        gap_length = 0;
    end
    % In each gap, there are 6 stringers.
    n_stringers = (n_hoops - 1) * 6;
    % Total volume of stringers:
    V_inner_stringers = n_stringers * A_stringer * gap_length;
    
    % Add approx for stringers in end caps
    V_end_stringers = 2 * A_stringer * L_cap;

    % Mass of stringers:
    m_stringers = (V_inner_stringers + V_end_stringers)* rho_al;

    % --- Total empty structural mass ---
    m_empty = m_skin + m_hoops + m_stringers;

    % Optional: display intermediate values
    fprintf('Computed cylindrical length: %.3f m\n', L_cyl);
    fprintf('Skin mass: %.2f kg\n', m_skin);
    fprintf('Total hoop mass (%d hoops): %.2f kg\n', n_hoops, m_hoops);
    fprintf('Total stringer mass (%d stringers): %.2f kg\n', n_stringers, m_stringers);
    fprintf('Total empty mass: %.2f kg\n', m_empty);

    % Save drop tank parameters
    aircraft.geometry.drop_tank.hoops.number = n_hoops;
    aircraft.geometry.drop_tank.hoops.mass = m_hoops;

    aircraft.geometry.drop_tank.stringers.number = n_stringers;
    aircraft.geometry.drop_tank.stringers.mass = m_stringers;
    
    aircraft.geometry.drop_tank.length = L_cyl + 2*L_cap;

     aircraft.geometry.drop_tank.volume_proximity = (V_caps + L_cyl*pi*R^2) / V_fuel; % 1 indicates perfect approximation to fuel volume, greater than one means over approx, less than one means under approx

    aircraft.geometry.drop_tank.empty_mass = m_empty;
  
end
