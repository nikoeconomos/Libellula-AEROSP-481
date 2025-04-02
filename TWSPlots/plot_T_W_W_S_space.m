function [] = plot_T_W_W_S_space(aircraft)
% Description: This function generates a plot of T/W vs W/S as it
% corresponds to each curve we are plotting for various segments of flight.
% 
% 
% INPUTS:
% --------------------------------------------
%    aircraft - aircraft struct with specs
% 
% OUTPUTS:
% --------------------------------------------
%    none
%                       
% 
% See also: generate_prelim_sizing_params.m - required to run prior to this
% script
% Author:                          Joon Kyo Kim
% Version history revision notes:
%                                  v1: 9/21/2024

    l = 1000; % wing loading limit - want this to cover up to 750 kg/m^2
    t = 1.5; % TW limit
    k = 300; % number of points on the plot

    aircraft.utility.des_pt.W_S_int = l / k;
    aircraft.utility.des_pt.T_W_int = t / k;

    % WS and TW arrays to pull from
    W_S_space =  linspace(0,l,k); %kg per m^2
    T_W_space =  linspace(0,t,k); %kg per m^2

    % Array Initialization
    T_W_cruise_arr = zeros(1,k);
    T_W_dash_arr   = zeros(1,k);

    T_W_takeoff_field_length_arr = zeros(1,k);

    T_W_sustained_turn_09_arr = zeros(1,k);
    T_W_sustained_turn_12_arr = zeros(1,k);

    T_W_sp_ex_pwr_arr_1 = zeros(1,k);
    T_W_sp_ex_pwr_arr_2 = zeros(1,k);
    T_W_sp_ex_pwr_arr_3 = zeros(1,k);
    T_W_sp_ex_pwr_arr_4 = zeros(1,k);
    T_W_sp_ex_pwr_arr_5 = zeros(1,k);
    T_W_sp_ex_pwr_arr_6 = zeros(1,k);

    for i = 1:k
        % Takeoff
        T_W_takeoff_field_length_arr(i) = T_W_takeoff_field_length_calc(aircraft, W_S_space(i));

        % Cruise
        T_W_cruise_arr(i) = T_W_cruise_calc(aircraft, W_S_space(i));
        T_W_dash_arr(i)   = T_W_dash_calc(aircraft, W_S_space(i));

        % Sustained Turn
        T_W_sustained_turn_09_arr(i) = T_W_sustained_turn_09_calc(aircraft, W_S_space(i));
        T_W_sustained_turn_12_arr(i) = T_W_sustained_turn_12_calc(aircraft, W_S_space(i));

        % Spec Excess Power
        T_W_sp_ex_pwr_arr_1(i) = T_W_sp_ex_pwr_calc_1(aircraft, W_S_space(i));
        T_W_sp_ex_pwr_arr_2(i) = T_W_sp_ex_pwr_calc_2(aircraft, W_S_space(i));
        T_W_sp_ex_pwr_arr_3(i) = T_W_sp_ex_pwr_calc_3(aircraft, W_S_space(i));
        T_W_sp_ex_pwr_arr_4(i) = T_W_sp_ex_pwr_calc_4(aircraft, W_S_space(i));
        T_W_sp_ex_pwr_arr_5(i) = T_W_sp_ex_pwr_calc_5(aircraft, W_S_space(i));
        T_W_sp_ex_pwr_arr_6(i) = T_W_sp_ex_pwr_calc_6(aircraft, W_S_space(i));
    end

    % Climb
    T_W_climb_arr_1 = ones(1, k) .* T_W_climb_calc_1(aircraft, NaN); % does not depend on W_S
    T_W_climb_arr_2 = ones(1, k) .* T_W_climb_calc_2(aircraft, NaN); 
    T_W_climb_arr_3 = ones(1, k) .* T_W_climb_calc_3(aircraft, NaN); 
    T_W_climb_arr_4 = ones(1, k) .* T_W_climb_calc_4(aircraft, NaN); 
    T_W_climb_arr_5 = ones(1, k) .* T_W_climb_calc_5(aircraft, NaN); 
    %T_W_climb_arr_6 = ones(1, k) .* T_W_climb_calc_6(aircraft, NaN); ONly 1 engine
 
    % Ceiling
    T_W_ceiling_arr = ones(1, k) .* T_W_ceiling_calc(aircraft, NaN);

    % Maneuver
    W_S_instantaneous_turn_arr = ones(1, k) .* W_S_instantaneous_turn_calc(aircraft, NaN);

    % Landing field length
    W_S_landing_field_length_arr = ones(1, k) .* W_S_landing_field_length_calc(aircraft, NaN); % does not depend on T_W
    
    %% Save for design point picking %%

    % 1st row is W/S value
    % 2nd row is T/W value
    aircraft.performance.constraint_space.WS_LFL = [W_S_landing_field_length_arr; T_W_space];

    aircraft.performance.constraint_space.TW_5g_4500m_Max= [W_S_space; T_W_sp_ex_pwr_arr_6];

    aircraft.performance.constraint_space.TW_5g_SL_Max = [W_S_space; T_W_sp_ex_pwr_arr_5];

    aircraft.performance.constraint_space.TW_1g_4500m_Max = [W_S_space; T_W_sp_ex_pwr_arr_4];

    aircraft.performance.constraint_space.TW_1g_SL_Max = [W_S_space; T_W_sp_ex_pwr_arr_3];

    aircraft.performance.constraint_space.TW_sust_turn = [W_S_space; T_W_sustained_turn_12_arr];


    %% Plotting the calculated values, all together%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure('Position', [50, 50, 1500, 800]); % Adjust figure size
    hold on;
    
    % Takeoff and Landing Constraints (Solid Lines - Distinct Colors)
    to = plot(W_S_space, T_W_takeoff_field_length_arr, 'Color', [1 0 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Red
    lf = plot(W_S_landing_field_length_arr, T_W_space, 'Color', [1, 0.5, 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Orange
    
    % Cruise Constraints (Dashed Lines - Distinct Colors)
    cs = plot(W_S_space, T_W_cruise_arr, 'Color', [0.4940 0.1840 0.5560], 'LineStyle', '--', 'LineWidth', 1.2); % Purple
    ds = plot(W_S_space, T_W_dash_arr, 'Color', 	[1 0 1], 'LineStyle', '--', 'LineWidth', 1.2); % Magenta
    
    % Maneuver Constraints (Dash-Dot Lines - Distinct Colors)
    m09 = plot(W_S_space, T_W_sustained_turn_09_arr, 'Color', [0 0 1], 'LineStyle', '-.', 'LineWidth', 1.2); % Light Blue
    m12 = plot(W_S_space, T_W_sustained_turn_12_arr, 'Color', [0, 0.75, 0.75], 'LineStyle', '-.', 'LineWidth', 1.2); % Teal
    it  = plot(W_S_instantaneous_turn_arr, T_W_space, 'Color', [0, 0, 0], 'LineStyle', '-.', 'LineWidth', 1.2); % black
    
    % Climb Constraints (Dotted Lines - Distinct Colors)
    c1 = plot(W_S_space, T_W_climb_arr_1, 'Color', [0.9, 0.6, 0], 'LineStyle', ':', 'LineWidth', 1.2); % Amber
    c2 = plot(W_S_space, T_W_climb_arr_2, 'Color', [0.4, 0.2, 0.6], 'LineStyle', ':', 'LineWidth', 1.2); % Dark Purple
    c3 = plot(W_S_space, T_W_climb_arr_3, 'Color', [0, 0.8, 0.3], 'LineStyle', ':', 'LineWidth', 1.2); % Mint Green
    c4 = plot(W_S_space, T_W_climb_arr_4, 'Color', [0.1, 0.7, 0.7], 'LineStyle', ':', 'LineWidth', 1.2); % Turquoise
    c5 = plot(W_S_space, T_W_climb_arr_5, 'Color', [0.7, 0.1, 0.2], 'LineStyle', ':', 'LineWidth', 1.2); % Reddish Brown
    %c6 = plot(W_S_space, T_W_climb_arr_6, 'Color', [0.3, 0.7, 0.3], 'LineStyle', ':', 'LineWidth', 1.2); % Olive Green
    
    % Specific Excess Power Constraints (Same Dotted Lines, Different Colors from Climb)
    sp1 = plot(W_S_space, T_W_sp_ex_pwr_arr_1, 'Color', [0.9, 0.4, 0.1], 'LineStyle', '-.', 'LineWidth', 1.2); % Burnt Orange
    sp2 = plot(W_S_space, T_W_sp_ex_pwr_arr_2, 'Color', [0.6, 0.4, 0.8], 'LineStyle', '-.', 'LineWidth', 1.2); % Lavender
    sp3 = plot(W_S_space, T_W_sp_ex_pwr_arr_3, 'Color', [0.4, 0.8, 0.2], 'LineStyle', '-.', 'LineWidth', 1.2); % Lime Green
    sp4 = plot(W_S_space, T_W_sp_ex_pwr_arr_4, 'Color', [0.2, 0.5, 0.7], 'LineStyle', '-.', 'LineWidth', 1.2); % Light Blue-Gray
    sp5 = plot(W_S_space, T_W_sp_ex_pwr_arr_5, 'Color', [0.7, 0.2, 0.4], 'LineStyle', '-.', 'LineWidth', 1.2); % Rose
    sp6 = plot(W_S_space, T_W_sp_ex_pwr_arr_6, 'Color', [0.5, 0.8, 0.2], 'LineStyle', '-.', 'LineWidth', 1.2); % Yellow-Green
    
    % Ceiling Constraint (Solid Line - Unique Color)
    ceil = plot(W_S_space, T_W_ceiling_arr, 'Color', [0.9, 0, 0.5], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Rose
        
    % Add legend
    legend([to,lf,cs,ds,m09,m12,it,c1,c2,c3,c4,c5,ceil,sp1,sp2,sp3,sp4,sp5,sp6], ...
        {'Takeoff field length','Landing field length',...
        'Cruise', 'Dash', ...
        '0.9 Mach sustained turn', '1.2 Mach sustained turn','Instantaneous turn',...
        'Takeoff climb','Transition climb','Second segment climb',...
        'Enroute climb','Balked landing climb'...
        'Ceiling', ...
        'Sp. Excess Power (1g, SL, Military)','Sp. Excess Power (1g, 4500m, Military)',...
        'Sp. Excess Power (1g, SL, Max)','Sp. Excess Power (1g, 4500m, Max)',...
        'Sp. Excess Power (5g, SL, Max)','Sp. Excess Power (5g, 4500m, Max)'});
    
    % Set axes limits and labels
    xlim([0 l]); 
    ylim([0 t]);
    xlabel('W/S [kg/m^2]');
    ylabel('T/W [N/N]');
    title('T/W - W/S plot for the F-81');
    
    hold off;


    %% Plotting the calculated values, Military Thrust %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure('Position', [50, 50, 1500, 800]); % Adjust figure size
    hold on;
    
    % Takeoff and Landing Constraints (Solid Lines - Distinct Colors)
    to = plot(W_S_space, T_W_takeoff_field_length_arr, 'Color', [1 0 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Red
    lf = plot(W_S_landing_field_length_arr, T_W_space, 'Color', [1, 0.5, 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Orange
    
    % Cruise Constraints (Dashed Lines - Distinct Colors)
    cs = plot(W_S_space, T_W_cruise_arr, 'Color', [0.4940 0.1840 0.5560], 'LineStyle', '--', 'LineWidth', 1.2); % Purple
    
    % Maneuver Constraints (Dash-Dot Lines - Distinct Colors)
    m09 = plot(W_S_space, T_W_sustained_turn_09_arr, 'Color', [0 0 1], 'LineStyle', '-.', 'LineWidth', 1.2); % Light Blue
    it  = plot(W_S_instantaneous_turn_arr, T_W_space, 'Color', [0, 0, 0], 'LineStyle', '-.', 'LineWidth', 1.2); % black
    
    % Climb Constraints (Dotted Lines - Distinct Colors)
    c1 = plot(W_S_space, T_W_climb_arr_1, 'Color', [0.9, 0.6, 0], 'LineStyle', ':', 'LineWidth', 1.2); % Amber
    c2 = plot(W_S_space, T_W_climb_arr_2, 'Color', [0.4, 0.2, 0.6], 'LineStyle', ':', 'LineWidth', 1.2); % Dark Purple
    c3 = plot(W_S_space, T_W_climb_arr_3, 'Color', [0, 0.8, 0.3], 'LineStyle', ':', 'LineWidth', 1.2); % Mint Green
    c4 = plot(W_S_space, T_W_climb_arr_4, 'Color', [0.1, 0.7, 0.7], 'LineStyle', ':', 'LineWidth', 1.2); % Turquoise
    c5 = plot(W_S_space, T_W_climb_arr_5, 'Color', [0.7, 0.1, 0.2], 'LineStyle', ':', 'LineWidth', 1.2); % Reddish Brown
    %c6 = plot(W_S_space, T_W_climb_arr_6, 'Color', [0.3, 0.7, 0.3], 'LineStyle', ':', 'LineWidth', 1.2); % Olive Green
    
    % Ceiling Constraint (Solid Line - Unique Color)
    ceil = plot(W_S_space, T_W_ceiling_arr, 'Color', [0.9, 0, 0.5], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Rose

    % Specific Excess Power Constraints (Same Dotted Lines, Different Colors from Climb)
    sp1 = plot(W_S_space, T_W_sp_ex_pwr_arr_1, 'Color', [0.9, 0.4, 0.1], 'LineStyle', '-.', 'LineWidth', 1.2); % Burnt Orange
    sp2 = plot(W_S_space, T_W_sp_ex_pwr_arr_2, 'Color', [0.6, 0.4, 0.8], 'LineStyle', '-.', 'LineWidth', 1.2); % Lavender
     
    %design point
    s_pt = plot(aircraft.performance.WS_design, aircraft.performance.TW_design_military, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); % black circle
    label = sprintf('(%.0f, %.2f)', aircraft.performance.WS_design, aircraft.performance.TW_design_military);  % Format the label with two decimal places
    text(aircraft.performance.WS_design + 15, aircraft.performance.TW_design_military+0.04, label, 'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 9, 'Color', 'k');

%{
% Find the indices where W_S_space is less than or equal to W_S_landing_field_length_arr(1)
indices_sp1 = find(W_S_space <= W_S_landing_field_length_arr(1));

% Ensure finite values for interpolation
finite_mask = isfinite(W_S_space) & isfinite(T_W_sp_ex_pwr_arr_1);
W_S_space_finite = W_S_space(finite_mask);
T_W_sp_ex_pwr_arr_1_finite = T_W_sp_ex_pwr_arr_1(finite_mask);

% Values for filling area
x_fill_sp1 = W_S_space(indices_sp1);
y_fill_sp1 = T_W_sp_ex_pwr_arr_1(indices_sp1);

% Append the vertical line point to close the polygon
x_intersection = W_S_landing_field_length_arr(1);
y_intersection = interp1(W_S_space_finite, T_W_sp_ex_pwr_arr_1_finite, x_intersection, 'linear', 'extrap');

% Complete polygon definition
x_fill = [x_fill_sp1, x_intersection, x_intersection];
y_fill = [y_fill_sp1, y_intersection, 1.5];

% Create the filled area
fill(x_fill, y_fill, 'c', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
%}

    % Add legend
    legend([to,lf,cs,m09,it,c1,c2,c3,c4,c5,ceil,sp1,sp2,s_pt], ...
        {'Takeoff field length','Landing field length',...
        'Cruise', ...
        '0.9 Mach sustained turn','Instantaneous turn',...
        'Takeoff climb','Transition climb','Second segment climb',...
        'Enroute climb','Balked landing climb'...
        'Ceiling', ...
        'Sp. Excess power (1g, SL, Military)','Sp. Excess power (1g, 4500m, Military)'...
        'Selected Design Point, Military'});
    
    % Set axes limits and labels
    xlim([0 l]); 
    ylim([0 t]);
    xlabel('W/S [kg/m^2]');
    ylabel('T/W [N/N]');
    title('T/W - W/S Plot for the F-81, Military Thrust');
        
    hold off;

    %% MAX THRUST PLOT %%
    %%%%%%%%%%%%%%%%%%%%%

    figure('Position', [50, 50, 1500, 800]); % Adjust figure size
    hold on;
    
    % Takeoff and Landing Constraints (Solid Lines - Distinct Colors)
    to = plot(W_S_space, T_W_takeoff_field_length_arr, 'Color', [1 0 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Red
    lf = plot(W_S_landing_field_length_arr, T_W_space, 'Color', [1, 0.5, 0], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Orange
    
    % Cruise Constraints (Dashed Lines - Distinct Colors)
    ds = plot(W_S_space, T_W_dash_arr, 'Color', 	[1 0 1], 'LineStyle', '--', 'LineWidth', 1.2); % Magenta
    
    % Maneuver Constraints (Dash-Dot Lines - Distinct Colors)
    m12 = plot(W_S_space, T_W_sustained_turn_12_arr, 'Color', [0, 0.75, 0.75], 'LineStyle', '-.', 'LineWidth', 1.2); % Teal
  
    % Specific Excess Power Constraints (Same Dotted Lines, Different Colors from Climb)
    sp3 = plot(W_S_space, T_W_sp_ex_pwr_arr_3, 'Color', [0.4, 0.8, 0.2], 'LineStyle', '-.', 'LineWidth', 1.2); % Lime Green
    sp4 = plot(W_S_space, T_W_sp_ex_pwr_arr_4, 'Color', [0.2, 0.5, 0.7], 'LineStyle', '-.', 'LineWidth', 1.2); % Light Blue-Gray
    sp5 = plot(W_S_space, T_W_sp_ex_pwr_arr_5, 'Color', [0.7, 0.2, 0.4], 'LineStyle', '-.', 'LineWidth', 1.2); % Rose
    sp6 = plot(W_S_space, T_W_sp_ex_pwr_arr_6, 'Color', [0.5, 0.8, 0.2], 'LineStyle', '-.', 'LineWidth', 1.2); % Yellow-Green
    
    % Ceiling Constraint (Solid Line - Unique Color)
    ceil = plot(W_S_space, T_W_ceiling_arr, 'Color', [0.9, 0, 0.5], 'LineStyle', '-', 'LineWidth', 1.2); % Bright Rose
        
    %design point
    s_pt = plot(aircraft.performance.WS_design, aircraft.performance.TW_design, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); % black circle
    label = sprintf('(%.0f, %.2f)', aircraft.performance.WS_design, aircraft.performance.TW_design);  % Format the label with two decimal places
    text(aircraft.performance.WS_design + 15, aircraft.performance.TW_design+0.04, label, 'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 9, 'Color', 'k');

    % Add legend
    legend([to,lf,ds,m12,ceil,sp3,sp4,sp5,sp6,s_pt], ...
        {'Takeoff field length','Landing field length',...
        'Dash', ...
        '1.2 Mach sustained turn', ...
        'Ceiling', ...
        'Sp. Excess power (1g, SL, Max)','Sp. Excess power (1g, 4500m, Max)',...
        'Sp. Excess power (5g, SL, Max)','Sp. Excess power (5g, 4500m, Max)'...
        'Selected Design Point, Military'});
    
    % Set axes limits and labels
    xlim([0 l]); 
    ylim([0 t]);
    xlabel('W/S [kg/m^2]');
    ylabel('T/W [N/N]');
    title('T/W - W/S Plot for the F-81, Maximum Thrust');
    
    hold off;
    
end