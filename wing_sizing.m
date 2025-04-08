% Aerosp 740 - Juan Esteban Vega - Interceptor Wing Design 
% main file
clear;
clc;
close all;

%% POPULATE INITIAL AIRCRAFT STRUCTS %%

tGlobalStart = tic;

aircraft = struct();

inputs = readmatrix('740_inputs.csv', 'Range', 'A2');

output_mat = zeros(size(inputs,1),12);

for ind = 1:size(inputs,1)
    
    % Start a timer for the current iteration
    tStart = tic;
    
    try
        % Create and populate the aircraft struct for the current index
        aircraft = load_inputs(inputs, ind);
        
        aircraft = generate_performance_params(aircraft);
        
        aircraft = generate_DCA_mission(aircraft);

        aircraft = generate_init_weight_params(aircraft); % gives a TOGW

        aircraft = generate_CL_params(aircraft); % guess S_ref is input

        aircraft = generate_wing_geom_mass(aircraft);

        aircraft = generate_wing_drag_polar_params(aircraft);
        
        % Optional: Input F35 parameters if desired
        % aircraft = generate_F35_params(aircraft);
        
        %% GENERATE PRELIMINARY SIZING PLOTS %%
        aircraft = select_TW_WS_design_point(aircraft);
        
        %% REFINE SIZING %%
        aircraft = generate_component_weights(aircraft);
        aircraft = generate_REFINED_drag_polar_params(aircraft);
        
        %% FIND AIRCRAFT COST %%
        aircraft = generate_plot_cost_params(aircraft);
        
        %% PRINT %%
        % Compute the sizing results (assuming output_sizing_results returns a column vector)
        current_result = output_sizing_results(aircraft);
        
        % Append current_result to output_mat as a new column
        output_mat(:, ind) = current_result;
        
        elapsedTime = toc(tStart); % End timing for current iteration
        fprintf('Iteration %d took %.4f seconds\n', ind, elapsedTime);
        
    catch ME
        % If an error occurs, display a message and skip to the next iteration
        fprintf('Iteration %d failed: %s\n', ind, ME.message);
        continue;
    end

end

writematrix(output_mat, 'output.csv');

aircraft;

disp(newline)

disp("Design Space Complete")