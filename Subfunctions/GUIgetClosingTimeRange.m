% Function is used by GUI to update the clamshell closing time range
% that is possible based on clamshell bucket width

%Function is called when excavation width slider is changed in GUI
function [min_time,max_time] = GUIgetClosingTimeRange(bucket_width)
%Calculate overflow flow rate required
db = 1.225; %m, as defined in geometrical optimization
angleRange = 80; %degrees, rotation range of the clamshell as assumed in Analysis Report

Ad = pi*(db^2)*angleRange/360; %m^2, Compute swept aread of single clamshell, Eqn. 3.65

[dc,Vin, N_hydr,~,~] = Hydrocyclone(); %compute cyclone diameter value, no arguments sent to indicate we onyl want dc (as defined in Hydrocyclone.m)
% dc is cyclone diameter, inches
% Vin is inlet flowrate to single hydrocyclone, GPM
% N_hydr is number of hydrocyclones

%get underflow diameters range based on dc (0.1dc to 0.35dc)
du_max = 0.35*dc; %in
du_min = 0.1*dc; %in

%Vu is underflow flow rate (back to clamshell) per hydrocyclone, GPM
A = 2.06673678052649; %constants computed from Analysis report log charts (Fig B.6)
B = 1.15747297488195;
Vu_min = 10^(A*log10(du_min)+B); %min flow rate back to clamshell, GPM
Vu_max = 10^(A*log10(du_max)+B); %max flow rate back to clamshell, GPM

%Get net flow rate being removed from individual clamshell
Vo_max = Vin - Vu_min; %max net flow rate to pump, GPM
Vo_min = Vin - Vu_max; %max net flow rate to pump, GPM

%convert to m3/s, and add contributions of all hydrocyclones together
conv = 15850.32314; %conversion factor
Vo_max = N_hydr*(Vo_max/conv);
Vo_min = N_hydr*(Vo_min/conv);

%use equations 3.66 and 3.67 from Analysis report to get closing time range
min_time = ceil(2*Ad*bucket_width/Vo_max); %seconds 
max_time = floor(2*Ad*bucket_width/Vo_min); %seconds

%return closing time range
end