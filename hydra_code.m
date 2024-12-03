%%
% Gust lines
% Gust parameters
WS = 100; % wing loading (lbs/ft^2)
altitude_m = 20000 * 0.3048; % Altitude in meters
[~, ~, rho, a] = standard_atmosphere_calc(altitude_m); % Standard atmosphere properties
rho_i = rho * 0.00194032; % Convert air density to slug/ft^3
c_bar = 380 / 35.14; % Mean aerodynamic chord
Cla = 6.875; % From AVL
g = 32.174; % Gravitational acceleration
u = (2 * WS) / (rho_i * c_bar * Cla * g); % Reduced frequency parameter
Kg = (0.88 * u) / (5.3 + u); % Gust alleviation factor
VNE = 800;
% Define velocities (ft/s) and convert to knots
V_EAS = linspace(0, VNE, 1000); % Equivalent airspeed range in knots

% Gust velocities (ft/s)
Ug_b = 66; % Rough air gust
Ug_c = 50; % Max design gust
Ug_d = 25; % Max dive gust

% Calculate gust load factors
n_gust_b_pos = 1 + (Kg * Cla * Ug_b .* V_EAS) / (498 * WS); % Positive gust for Vb
n_gust_b_neg = 1 - (Kg * Cla * Ug_b .* V_EAS) / (498 * WS); % Negative gust for Vb

n_gust_c_pos = 1 + (Kg * Cla * Ug_c .* V_EAS) / (498 * WS); % Positive gust for Vc
n_gust_c_neg = 1 - (Kg * Cla * Ug_c .* V_EAS) / (498 * WS); % Negative gust for Vc

n_gust_d_pos = 1 + (Kg * Cla * Ug_d .* V_EAS) / (498 * WS); % Positive gust for Vd
n_gust_d_neg = 1 - (Kg * Cla * Ug_d .* V_EAS) / (498 * WS); % Negative gust for Vd


% Gust lines
hold on
plot(V_EAS, n_gust_b_pos);
plot(V_EAS, n_gust_b_neg);
plot(V_EAS, n_gust_c_pos);
plot(V_EAS, n_gust_c_neg);
plot(V_EAS, n_gust_d_pos);
plot(V_EAS, n_gust_d_neg);