clc
clear
close all

%% -----------------------------
% Optimization Data from ANSYS
%% -----------------------------
Q = [22.9863 24.9650 27.6313 33.3963 34.1154 ...
    39.0826 39.6947 41.5721 44.9096 46.9277 ...
    48.7734 53.0000 55.3386 65.0000 66.0999 ...
    68.1984 71.0000 72.7150 75.9029 80.5306 ...
    88.6993 92.5281 94.3570 97.1575 103.829 ...
    109.828 116.565];
h = [12.238 12.9926 13.8999 16.4074 16.7773 ...
    18.5596 18.8301 19.6631 22.3953 23.9156 ...
    24.6487 27.6820 28.1673 33.5355 32.9860 ...
    33.9404 36.9856 36.6967 38.8744 41.5708 ...
    45.1392 47.0584 48.2047 49.7070 53.6536 ...
    56.5230 59.8423];

%% -----------------------------
% Interpolation
%% -----------------------------
Qfit = 0:1:120;
hfit = interp1(Q,h,Qfit,'pchip','extrap');

%% Natural convection
hfit(Qfit<=15)=8;

%% Heater
heater=max(15-Qfit,0);

%% Fan RPM
hnatural=8;
RPM=zeros(size(Qfit));
RPM_ref=5000;
h_ref=60;
hforced_ref=h_ref-hnatural;
n=0.6;
for i=1:length(Qfit)
    if hfit(i)<=8
        RPM(i)=0;
    else
        hforced=hfit(i)-hnatural;
        RPM(i)=RPM_ref*(hforced/hforced_ref)^(1/n);
    end
end

%% -----------------------------
% User Input
%% -----------------------------
Quser=input('Enter Exterior Heat (W) = ');
if Quser<=15
    Heater=15-Quser;
    hreq=8;
    FanRPM=0;
else
    Heater=0;
    hreq=interp1(Q,h,Quser,'pchip');
    hforced=hreq-8;
    FanRPM=RPM_ref*(hforced/hforced_ref)^(1/n);
end
fprintf('\n');
fprintf('=====================================\n');
fprintf('Exterior Heat      : %.2f W\n',Quser);
fprintf('Internal Heater    : %.2f W\n',Heater);
fprintf('Required h         : %.2f W/m^2K\n',hreq);
fprintf('Natural h          : 8.00 W/m^2K\n');
fprintf('Forced h           : %.2f W/m^2K\n',hreq-8);
fprintf('Required Fan Speed : %.0f RPM\n',FanRPM);
fprintf('=====================================\n');

%% -----------------------------
% Graph 1
%% -----------------------------
figure
plot(Q,h,'ro','MarkerFaceColor','r')
hold on
plot(Qfit,hfit,'b','LineWidth',2)
grid on
xlabel('Exterior Heat Load (W)')
ylabel('Required Convection Coefficient h (W/m^2K)')
title('Required Convection Coefficient vs Exterior Heat')
legend('ANSYS Optimization Data','PCHIP Best Fit','Location','northwest')

%% -----------------------------
% Graph 2
%% -----------------------------
figure
yyaxis left
plot(Qfit,heater,'LineWidth',2)
ylabel('Heater Power (W)')
yyaxis right
plot(Qfit,RPM,'LineWidth',2)
ylabel('Fan Speed (RPM)')
xlabel('Exterior Heat Load (W)')
title('Adaptive Heating and Cooling Strategy')
grid on
legend('Heater','Fan RPM','Location','northwest')