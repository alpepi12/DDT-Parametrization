% Add function description here, see other functions for examples

% breakout_force = excavatino breakout force (kN)
function [hydraulic_force,theta1] = HydraulicSystem(breakout_force)

%Add logging where necessary

log_entry = "******** Hydraulic System Design ********\n"; %Initialize log entry string array


%% Hydraulic Force Calculations

n = 2; %safety factor
breakout_force = breakout_force*1000; %conv to Newtons
db = 1.225; %m, vertical distance from pin to bucket blade
dh = 0.508; %m, distance from pin to pin
dx = 225/1000; %m, fixed frame position in x
dz = 1800/1000; %m, fixed frame position in z
a = sqrt(dx^2+dz^2); %m, hypotenuse between dx and dz
thetahb = deg2rad(70); %rad, angle between bucket opening and bucket top (rad)
thetaz = pi/2 - atan(dz/dx); %rad, tangent angle between dz and dx

dc_min = 600; %mm, length of hydraulic cylinder housing
t =20; % mm, thickness of housing

theta2 = pi/2; %rad, angle between cylinder and bucket top
theta1 = asin((dh/a)*sin(theta2)) - thetaz; % angle between cylinder and the z axis
theta3 = thetahb + pi/2 - theta1 - theta2; % angle between bucket tooth and seafloor


hydraulic_force = (-n*breakout_force*db)/(dh*sin(theta1)*cos(theta1+theta2) - cos(theta1)*sin(theta1+theta2));
% hydraulic force required from the actuator, Equation 3.14 in analysis report
log_entry = [log_entry; strcat("Hydraulic force: ", string(hydraulic_force/1000), " kN \n")];    
    

%% Hydraulic Actuator Calculations
log_entry = [log_entry; strcat("\n--- Hydraulic Actuator ---\n")];

% material properties
E = 193e9;

% geometric properties

drod_min = 20; %mm, minimum piston rod diameter allowable

bh = 60; %mm, geometrical dimension for flange
bw = 75; %mm, geometrical dimension for flange
A = 10000; %mm2, area of piston head
bdist = 30; %mm, bolt distance in the flange
bdia = 30; %mm, bolt diameter
oh = 80; %mm, height of the orifice
ow = 5000; %mm2, area of the orifice
phH = 100; %mm, piston head height
pind = 80; %mm, pin diameter
rodL = 1000; %mm, piston rod length
buckpinw = 75; %mm, bucket pin width/2


%compute required diamter to prevent buckling, Eqn 3.63 in Analysis report
rodd = ((64*hydraulic_force*n*(1.0*rodL/1000)^2)/(E*pi^3))^(1/4); %m, diameter of actuator rod
rodd = 1000*rodd; %conv to mm

if (rodd < drod_min) %if diameter of rod is smaller than reasonable
    rodd = drod_min;
end

log_entry = [log_entry; strcat("Actuator rod diameter: ", string(rodd/1000), " m \n")]; 


%% Write to equations file

eqn = strcat("""dc_min"" = ", string(dc_min));
eqn =[eqn; strcat("""t"" = ", string(t))];
eqn =[eqn; strcat("""bh"" = ", string(bh))];
eqn =[eqn; strcat("""bw"" = ", string(bw))];
eqn =[eqn; strcat("""A"" = ", string(A))];
eqn =[eqn; strcat("""bdist"" = ", string(bdist))];
eqn =[eqn; strcat("""bdia"" = ", string(bdia))];
eqn =[eqn; strcat("""rodd"" = ", string(rodd))];
eqn =[eqn; strcat("""oh"" = ", string(oh))];
eqn =[eqn; strcat("""ow"" = ", string(ow))];
eqn =[eqn; strcat("""phH"" = ", string(phH))];
eqn =[eqn; strcat("""pind"" = ", string(pind))];
eqn =[eqn; strcat("""rodL"" = ", string(rodL))];
eqn =[eqn; strcat("""buckpinw"" = ", string(buckpinw))];
%eqn =[eqn; strcat("""buckholed"" = ", string(buckholed))];



Write_to_txt(eqn, "HA_Actuator.txt", "Hydraulic Actuator"); %Write dimensions to txt file
   


%% Append HC log strings to log file
   log_entry = [log_entry; "**************************************\n"]
   Append_to_log(log_entry);

end


%used to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
txt_line = strcat("""", var_name, """ = ", string(value)); 
end