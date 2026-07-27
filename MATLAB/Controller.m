clc;
clear;
close all force; 
%% ========================================================================
% CONSTANT TEMPERATURE PLATE - UNIFIED CONTINUOUS THERMAL MODEL
% Implementation of Churchill-Usagi Blending for Smooth Regime Transition
% (Strictly Internal Duct Flow Physics)
%% ========================================================================
%% ------------------------------------------------------------------------
% 1. ANSYS CFD Optimization Data
% ------------------------------------------------------------------------
Q = [22.9863 24.9650 27.6313 33.3963 34.1154 ...
     39.0826 39.6947 41.5721 44.9096 46.9277 ...
     48.7734 53.0000 55.3386 65.0000 66.0999 ...
     68.1984 71.0000 72.7150 75.9029 80.5306 ...
     88.6993 92.5281 94.3570 97.1575 103.829 ...
     109.828 116.565];
     
h = [12.2380 12.9926 13.8999 16.4074 16.7773 ...
     18.5596 18.8301 19.6631 22.3953 23.9156 ...
     24.6487 27.6820 28.1673 33.5355 32.9860 ...
     33.9404 36.9856 36.6967 38.8744 41.5708 ...
     45.1392 47.0584 48.2047 49.7070 53.6536 ...
     56.5230 59.8423];
%% ------------------------------------------------------------------------
% 2. Data Interpolation & Baseline Conditions
% ------------------------------------------------------------------------
Qfit = 0:1:120;                                     
hfit = interp1(Q, h, Qfit, 'pchip', 'extrap');      
hnatural = 8;                                       
hfit(Qfit <= 15) = hnatural;                        
heater_arr = max(15 - Qfit, 0);
%% ------------------------------------------------------------------------
% 3. Thermophysical Properties & Heat Sink Geometry
% ------------------------------------------------------------------------
Pr  = 0.71;                                         % Prandtl Number
k   = 0.0263;                                       % Thermal Conductivity (W/m-K)
rho = 1.16;                                         % Density (kg/m^3)
mu  = 1.85e-5;                                      % Dynamic Viscosity (Pa.s)
% Internal Duct (Heat Sink) Geometry
FinHeight  = 0.025;                                 % m
FinSpacing = 0.0193;                                % m
NoChannels = 13;
L = 0.300;                                          % Length of the heat sink channel (m)
Dh = 0.0218;                                        % Hydraulic Diameter (m)
FlowArea = NoChannels * FinHeight * FinSpacing;     % Cross-sectional area (m^2)
% Note: L/D = 13.8 (Valid for Hausen / internal developing flow correlations)
RPM_ref = 5500;                                     % Rated Fan Speed (RPM)
CFM_ref = 252.85;                                   % Rated Airflow (CFM)

%% ------------------------------------------------------------------------
% 4. Unified Internal Duct Correlations
%% ------------------------------------------------------------------------

%-------------------------------
% Laminar : Hausen Correlation
%-------------------------------
Nu_lam = @(Re) ...
3.66 + (0.0668*(Dh/L).*Re.*Pr)./ ...
(1 + 0.04*((Dh/L).*Re.*Pr).^(2/3));

%-------------------------------
% Turbulent : Gnielinski
% Valid for Re >= 3000
%-------------------------------

f = @(Re) (0.79*log(Re)-1.64).^(-2);

Nu_turb = @(Re) ...
((f(Re)/8).*(Re-1000).*Pr)./ ...
(1 + 12.7*sqrt(f(Re)/8).*(Pr^(2/3)-1));

%-------------------------------
% Unified Correlation
%-------------------------------

Nu_model = @(Re) localNu(Re,Nu_lam,Nu_turb);

%% ========================================================================
% PART II: SYSTEM ANALYSIS & CALCULATION
%% ========================================================================
%% ------------------------------------------------------------------------
% 5. User Input & Operational Point Calculation
% ------------------------------------------------------------------------
fprintf('\n');
Quser = input('Enter Exterior Heat Load (W) = ');
if Quser <= 15
    Heater = 15 - Quser;
    hreq = hnatural;
else
    Heater = 0;
    hreq = interp1(Q, h, Quser, 'pchip');
end

% Target Nusselt Number
Nu_target = hreq*Dh/k;

% Numeric Solver (Physics Engine)
% Search interval constrained to [100, 100000] to prevent multiple roots at low Nu
Nu_low  = Nu_model(100);
Nu_high = Nu_model(100000);
fprintf('Nu_low = %.3f\n',Nu_low);
fprintf('Nu_high = %.3f\n',Nu_high);
fprintf('Nu_target = %.3f\n',Nu_target);
Re = fzero(@(R) Nu_model(R)-Nu_target,[100 100000]);

if Re < 2300
    FlowRegime = 'Laminar';
elseif Re < 3000
    FlowRegime = 'Transition';
else
    FlowRegime = 'Turbulent';
end

Velocity = Re * mu / (rho * Dh);                    % m/s
FlowRate = Velocity * FlowArea;                     % m^3/s
CFM = FlowRate * 2118.88;                           % Convert to CFM
RPM = RPM_ref * (CFM / CFM_ref);                    % Apply Fan Affinity Law
%% ------------------------------------------------------------------------
% 6. Array Generation for Full Range Performance Mapping
% ------------------------------------------------------------------------
Re_arr = zeros(size(Qfit));
RPM_arr = zeros(size(Qfit));
for i = 1:length(Qfit)
    Nu_i = hfit(i) * Dh / k;
    Re_arr(i)=fzero(@(R)Nu_model(R)-Nu_i,[100 100000]);
    Vel_i = Re_arr(i) * mu / (rho * Dh);
    CFM_i = Vel_i * FlowArea * 2118.88;
    RPM_arr(i) = RPM_ref * (CFM_i / CFM_ref);
end
%% ========================================================================
% PART III: DATA VISUALIZATION & OUTPUT
%% ========================================================================
%% ------------------------------------------------------------------------
% 7. Command Window Console Report
% ------------------------------------------------------------------------
fprintf('\n====================================================\n');
fprintf(' CONSTANT TEMPERATURE PLATE - THERMAL MODEL REPORT\n');
fprintf('====================================================\n');
fprintf('Exterior Heat Load        : %.2f W\n', Quser);
fprintf('Adaptive Heater Power     : %.2f W\n', Heater);
fprintf('\n');
fprintf('Target Convection Coeff   : %.2f W/m^2-K\n', hreq);
fprintf('Hydraulic Diameter        : %.5f m\n', Dh);
fprintf('Target Nusselt Number     : %.2f\n', Nu_target);
fprintf('\n');
fprintf('Reported Flow Regime      : %s\n', FlowRegime);
fprintf('Calculated Reynolds No.   : %.0f\n', Re);
fprintf('\n');
fprintf('Average Air Velocity      : %.3f m/s\n', Velocity);
fprintf('Required Volumetric Flow  : %.2f CFM\n', CFM);
fprintf('Command Fan Speed         : %.0f RPM\n', RPM);
fprintf('====================================================\n');
%% ------------------------------------------------------------------------
% 8. Figure Generation
% ------------------------------------------------------------------------
figure(1);
plot(Qfit, hfit, 'LineWidth', 2, 'Color', 'b'); hold on;
plot(Q, h, 'ro', 'MarkerFaceColor', 'r');
xline(15, '--k', 'Natural Convection Threshold');
xlabel('Exterior Heat Load Q (W)');
ylabel('Convection Coefficient h (W/m^2-K)');
title('Target Convection Coefficient vs. External Heat Load');
grid on; legend('Interpolated Model', 'ANSYS CFD Data', 'Location', 'Best');
drawnow;

figure(2);
plot(Qfit, Re_arr, 'LineWidth', 2, 'Color', 'k'); hold on;
yline(2300, '--r', 'Laminar Upper Bound (Re=2300)');
yline(3000, '--g', 'Turbulent Lower Bound (Re=3000)');
xlabel('Exterior Heat Load Q (W)');
ylabel('Reynolds Number (Re)');
title('Reynolds Number Progression (Internal Duct Transition)');
grid on;
drawnow;

figure(3);
plot(Qfit, RPM_arr, 'LineWidth', 2.5, 'Color', 'm'); hold on;
plot(Quser, RPM, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 12);
xlabel('Exterior Heat Load Q (W)');
ylabel('Required Fan Speed (RPM)');
title('Fan Operational Curve vs. Heat Load');
grid on; legend('Continuous RPM Profile', 'Specified Operational Point', 'Location', 'Best');
drawnow;

figure(4);
plot(Re_arr, RPM_arr, 'LineWidth', 2, 'Color', 'c'); hold on;
xline(2300, '--r'); xline(3000, '--g');
xlabel('Reynolds Number (Re)');
ylabel('Required Fan Speed (RPM)');
title('Fan RPM vs. System Reynolds Number');
grid on;
drawnow;

figure(5);
set(gcf, 'Name', 'Adaptive Control Strategy', 'Color', 'w');
yyaxis left;
plot(Qfit, heater_arr, '-', 'LineWidth', 2.5);
ylabel('Internal Heater Power Actuation (W)', 'FontWeight', 'bold');
ylim([0, 16]);
yyaxis right;
plot(Qfit, RPM_arr, '-', 'LineWidth', 2.5);
ylabel('Fan Speed Command (RPM)', 'FontWeight', 'bold');
ylim([0, max(RPM_arr) + 200]); 
xlabel('Exterior Heat Load (W)', 'FontWeight', 'bold');
xlim([0, 120]);
title('Adaptive Thermal Management Strategy', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
legend('Heater Response', 'Fan RPM Response', 'Location', 'northwest');
drawnow;


% function
function Nu = localNu(Re,Nu_lam,Nu_turb)

if Re <= 2300

    Nu = Nu_lam(Re);

elseif Re >= 3000

    Nu = Nu_turb(Re);

else

    % Smooth interpolation

    phi = (Re-2300)/(3000-2300);

    NuL = Nu_lam(2300);

    NuT = Nu_turb(3000);

    Nu = (1-phi)*NuL + phi*NuT;

end

end
