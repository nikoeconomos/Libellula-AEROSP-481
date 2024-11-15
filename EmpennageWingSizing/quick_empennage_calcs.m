clear
close all
clc
AR = 3.068;
S_W = 24.5;
b_W = sqrt(AR*S_W);

lambda = 0.35; % taper ratio
c_root_W = 2*S_W / ( (1+lambda) * b_W);
c_tip_W = lambda * c_root_W;
c_bar_W = 2*c_root_W*((1 + lambda + lambda^2)/(1 + lambda))/3; % [m]

Y_bar = b_W * ((1 + 2*lambda) / (1 + lambda)) /6;

L_F = 16.3;
L_HT = 0.5 * L_F;
L_VT = L_HT + 0.4;


% Volume coefficients
c_VT = 0.07;
c_HT = 0.4;

S_VT = c_VT * b_W * S_W / L_VT
S_one_VT = S_VT/2

S_HT = c_HT * c_bar_W * S_W / L_HT
S_one_HT = S_HT/2

% gamma_vtail = atand(S_VT/S_HT); % degrees

% OEI Yaw Moment Calculation
To_thrust = 57.8e3;

yt = 0.8;

Nt_crit = To_thrust*yt;
Nt_drag = Nt_crit*0.15;
Nt_tot = Nt_drag + Nt_crit;

% Vertical Tail Dimensions
lambda_VT = 0.35;
AR_VT = 2;

b_VT = sqrt(AR_VT*S_VT);
b_VT_one = b_VT/2;

c_root_VT = 2*S_VT / ( (1 + lambda_VT) * b_VT)
c_tip_VT = lambda_VT * c_root_VT
c_bar_VT = 2*c_root_VT*((1 + lambda_VT + lambda_VT^2)/(1 + lambda_VT))/3;

Y_bar = b_VT * ((1 + 2*lambda) / (1 + lambda)) /6;

% Horizontal Tail Dimensions
lambda_HT = 0.5;
AR_HT = 4;

b_HT = sqrt(AR_HT*S_HT);
b_HT_one = b_HT/2;

c_root_HT = 2*S_HT / ( (1+lambda_HT) * b_HT)
c_tip_HT = lambda_HT * c_root_HT
c_bar_HT = 2*c_root_HT*((1 + lambda_HT + lambda_HT^2)/(1 + lambda_HT))/3;

Y_bar_HT = b_HT * ((1 + 2*lambda_HT) / (1 + lambda_HT)) /6;

%% Horizontal Stabilizer Lift Properties %%

% Takeoff Chordwise Mach = 0.18
x = [0 1 1.5 1.7 2 2.5 2.9]; % AOA until stall
y = [0  0.10357  0.15514  0.1757  0.20667  0.27675  0.31947]; % Lift Coefficient

% Linear regression
p_takeoff = polyfit(x, y, 1) % Fit a line (1st order polynomial)
yCalc1 = polyval(p_takeoff, x); % Calculate fitted values

% Plot
figure()
scatter(x, y)
hold on
plot(x, yCalc1, 'LineWidth', 1.5)
xlabel('Angle of Attack (degrees)')
ylabel('Lift Coefficient')
title('Horizontal Stabilizer C_L Alpha at M = 0.18')
grid on
hold off

% Takeoff Chordwise Mach = 0.548
x = [0 0.3 0.7 1 1.25 1.37 1.5]; % AOA until stall
y = [0 0.03609 0.08422  0.12034 0.15047 0.16497 0.18069]; % Lift Coefficient

% Linear regression
p_cruise = polyfit(x, y, 1) % Fit a line (1st order polynomial)
yCalc2 = polyval(p_cruise, x); % Calculate fitted values

% Plot
figure()
scatter(x, y)
hold on
plot(x, yCalc2, 'LineWidth', 1.5)
xlabel('Angle of Attack (degrees)')
ylabel('Lift Coefficient')
title('Horizontal Stabilizer C_L Alpha at M = 0.548')
grid on
hold off

% Takeoff Chordwise Mach = 1
x = [0 1 2 3 5 8 11]; % AOA until stall
y = [0.1 0.15 0.25 0.31 0.52 0.92 1.1]; % Lift Coefficient

% Linear regression
p_supersonic = polyfit(x, y, 1) % Fit a line (1st order polynomial)
yCalc3 = polyval(p_supersonic, x); % Calculate fitted values

% Plot
figure()
scatter(x, y)
hold on
plot(x, yCalc3, 'LineWidth', 1.5)
xlabel('Angle of Attack (degrees)')
ylabel('Lift Coefficient')
title('Horizontal Stabilizer C_L Alpha at M = 1')
grid on
hold off


%% Draw Airfoils
chord_pannels = 26;
norm_chord = linspace(0,1,chord_pannels);
N = 10; %Change this to change airfol front roundness
del_pannel = norm_chord(2)-norm_chord(1);
r = N*del_pannel;
d_theta = pi/(2*N);
% Biconvex airfoil coordinates
T_to_C = 0.033;
% biconvex_top = zeros(0,length(norm_chord));
% for i = 1:length(norm_chord)
% 
%     if i <= N
%         theta = pi - d_theta*(i-1);
%         biconvex_top(i) = r*sin(theta);
%     else
%         biconvex_top(i) = 2 * T_to_C * (-norm_chord(i)^2 + norm_chord(i));
%     end
% 
% end
biconvex_top = 2 * T_to_C * (-norm_chord.^2 + norm_chord);
biconvex_bottom = -biconvex_top;
biconvex_bottom(1) = 0;
biconvex_bottom(end) = 0;
biconvex_export = transpose([fliplr(biconvex_top),biconvex_bottom]);
biconvex_mfoil = transpose([biconvex_top,fliplr(biconvex_bottom)]);
figure()
subplot(1,2,1)
plot(norm_chord, biconvex_top)
hold on
plot(norm_chord, biconvex_bottom)
title('Biconvex Airfoil');
xlabel('Normalized Chord');
ylabel('Thickness');
axis equal
% Hexagonal airfoil coordinates using same thickness to chord ratio as
% biconvex airfoil and flat surface staing at 0.25c and ending at 0.75c
hexagonal_top = zeros(0,length(norm_chord));
% for i = 1:length(norm_chord)
% 
%     if i <= N
%         theta = pi - d_theta*(i-1);
%         hexagonal_top(i) = r*sin(theta);
%     elseif N < i && i <= 25
%         hexagonal_top(i) = 2*T_to_C*norm_chord(i);
%     elseif i > 25 && i <= 75
%         hexagonal_top(i) = T_to_C/2;
%     else
%         hexagonal_top(i) = -2*T_to_C*norm_chord(i) + 2*T_to_C;
%     end
% 
% end
for i = 1:length(norm_chord)
    if i <= round(chord_pannels/4)
        hexagonal_top(i) = 2*T_to_C*norm_chord(i);
    elseif i > round(chord_pannels/4) && i <= 3*round(chord_pannels/4)
        hexagonal_top(i) = T_to_C/2;
    else
        hexagonal_top(i) = -2*T_to_C*norm_chord(i) + 2*T_to_C;
    end
end
hexagonal_bottom = -hexagonal_top;
hexagonal_bottom(1) = 0;
hexagonal_bottom(end) = 0;
hexagonal_export = transpose([fliplr(hexagonal_top),hexagonal_bottom]);
hexagonal_mfoil = transpose([hexagonal_top,fliplr(hexagonal_bottom)]);
subplot(1,2,2)
plot(norm_chord, hexagonal_top)
hold on
plot(norm_chord, hexagonal_bottom)
title('Hexagonal Airfoil');
xlabel('Normalized Chord');
ylabel('Thickness');
axis equal
% Export points
norm_chord_export = transpose([fliplr(norm_chord),norm_chord]);
norm_chord_mfoil = transpose([norm_chord,fliplr(norm_chord)]);
biconvex_export = [norm_chord_export, biconvex_export];
biconvex_export(27,:) = [];
hexagonal_export = [norm_chord_export, hexagonal_export];
hexagonal_export(27,:) = [];
biconvex_mfoil = [norm_chord_export, biconvex_mfoil];
biconvex_mfoil(27,:) = [];
biconvex_mfoil(26,2) = biconvex_mfoil(25,2);
hexagonal_mfoil = [norm_chord_export, hexagonal_mfoil];
hexagonal_mfoil(27,:) = [];
hexagonal_mfoil(26,2) = hexagonal_mfoil(25,2);