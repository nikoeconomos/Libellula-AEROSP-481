function [T] = T_from_S_constraint_calc(aircraft,S, f)
% Description: This function returns an array of T values from S inputs
% based on a constraint function f
%
% INPUTS:
% --------------------------------------------%
%
%   f - function handle for the calculation of T/W
%   k - number of data points for the plot
%   s_min - minimum value of s for our input array
%   s_max - maximum value of s for our input array
%
% OUTPUTS:
% --------------------------------------------
%    S - array of length k with input S values
%    T - array of length k with output T values from f
%
% Author:                          Niko
% Version history revision notes:
%                                  v1: 9/24/2024
k = 200;
    T = zeros(k);
    
    for i = 1:length(S)
        S0 = S(i);          % Prescribe wing area
        T(i) = 191000;     % Initial thrust guess (N); based on F-35, reasoning in notes
        tolerance = 0.1;    % Convergence tolerance
        converged = false;
    
        while ~converged
            W = togw_as_func_of_T_S_calc(aircraft, T(i), S0);      % Compute TOGW TODO FINISH THIS FUNC
            wing_loading =  W/S0;                        % Compute wing loading
            thrust_to_weight_new = f(wing_loading);      % Compute T=W from constraint equation TODO 
            T_new = thrust_to_weight_new*W ;             % Compute new total thrust
            
            if abs(T_new - T(i)) <= tolerance            % Check for convergence
                converged = true;
            end
    
            T(i) = T_new;   % Update thrust value
        end
    end

end

