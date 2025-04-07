% Aerosp 481 Group 3 - Libellula 
function [togw, w_empty] = togw_and_w_empty_calc(aircraft)
% Description: This function generates a the TOGW of our aircraft by calling
% another function, togw_regression_loop. It runs the regression loop 3 times for all 
% three missions and returns three separate TOGWs.
% 
% INPUTS:
% --------------------------------------------
%    aircraft
% 
% OUTPUTS:
% --------------------------------------------
%    togw
%    w_empty
% 
% See also: togw_regression_loop()
% Latest author:                   Niko/Victoria
% Version history revision notes:
%                                  v1: 9/10/2024

    w_0 = 35000; % set the w0 to our initial guess
    w_crew = aircraft.weight.components.crew;
    w_payload = aircraft.weight.components.payload;
    
    ff = aircraft.weight.ff; % calculate the fuel fraction

    A = 2.11;
    C = -0.13;

    epsilon = 10e-6; % error for convergence
    delta = 2*epsilon; % the amount the we are off from converging

    % generates a the TOGW of our aircraft based on
    % the algorithm given in section 2.5 of the meta guide.
    iterations = 0;
    while delta > epsilon
        iterations = iterations + 1;
        empty_weight_fraction = A*(w_0^C);

        w_0_new = (w_crew + w_payload)/(1 - ff - empty_weight_fraction);
        
        delta = abs(w_0_new-w_0)/abs(w_0_new);

        alpha = 0.8; % RELAXATION FACTOR
        w_0 = alpha*w_0_new + (1 - alpha)*w_0;
        %w_0 = w_0_new;
    end
    
    togw = w_0;
    w_empty = empty_weight_fraction*togw;

end