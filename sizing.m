%% SECTION TITLE
% DESCRIPTIVE TEXT
% Aerosp 481 Group 3 - Libellula 
% main file
clear;
clc;
close all;

%% POPULATE INITIAL AIRCRAFT STRUCTS %%

 aircraft = struct();

inputs = readmatrix('740_inputs.csv', 'Range', 'A2');

for ind = 1:size(inputs,2)

tic;

aircraft = load_inputs(inputs,ind);

aircraft = generate_performance_params(aircraft);
aircraft = generate_DCA_mission(aircraft);

aircraft = generate_init_weight_params(aircraft); % gives a togw
aircraft = generate_prop_params(aircraft);

aircraft = generate_CL_params(aircraft); % this is where guess S_ref is input
aircraft = generate_aerodynamics_params(aircraft);

aircraft = generate_init_weight_params(aircraft); % run again for better estimate - gives a togw

aircraft = generate_climb_segments(aircraft);


% INPUT F35 PARAMETERS IF DESIRED
% aircraft = generate_F35_params(aircraft);

%% GENERATE PRELIMINARY SIZINCAG PLOTS %%

aircraft = select_TW_WS_design_point(aircraft);

% plot_T_W_W_S_space(aircraft)

% plot_T_S_space_F35(aircraft)
% [togw, ff, W_e] = togw_as_func_of_T_S_calc(aircraft, aircraft.propulsion.T_max, aircraft.geometry.wing.S_ref)

%% REFINE SIZING

aircraft = generate_component_weights(aircraft);

aircraft = generate_REFINED_drag_polar_params(aircraft);
%plot_drag_polar(aircraft);

%plot_V_n_diagram(aircraft);


%% FIND AIRCRAFT COST

aircraft = generate_plot_cost_params(aircraft);
%plot_cost_pie_chart(aircraft);


%% PRINT %%

output_mat = zeros(Size(inputs,1), ind);
output_mat(:,ind) = output_sizing_results(aircraft);

elapsedTime = toc; % Stop timing and record the elapsed time
fprintf('Iteration %d took %.4f seconds\n', ind, elapsedTime);

end

writematrix(output_mat, 'output.csv');

aircraft;

disp(newline)

disp("Design Space Complete")
