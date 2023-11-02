% Calculates the fluid flow rate and pressure losses in the suction system 
% and sets the system piping sizes
% Writes dimensions to part txt files
% cs_width = clamshell width set in the GUI
% t_c = closing time
% depth = operational depth of the device
function [Q_d, D_s,pipe_thickness,D_f,T_length,corner_straight_length,corner_radius] = Suction_System(cs_width, t_c, depth)


%% Initial Setup
%Set parameters
    global rho_w;
    rho_w = 1028; %kg/m3, density of seawater
    global grav;
    grav = 9.81; %m/s^2, gravitational acceleration
    mu_w = 0.00167; %Pa.s, dynamic visocity of sea water
    epsilon_r = 0.015; %pipe roughness considering stainless steel piping
    cs_height = 1.225; %m, height of the clamshell constant at 1 meter
    %for piping dimensions
    flg_ex = 50; %Pipe flange extension from pipe inner diameter in mm
    flg_tk = 15; %Pipe flange thicknesses based on pipe size in mm
    N_flg_holes = 8; %Number of bolt holes in pipe flange
    flg_hole_dia = 15; %Diameter of bolt holes in pipe flange in mm
    gasket_thickness = 2; %mm, pipe gasket thickness
    gasket_Ro_diff = 5; %mm, difference between flange OD and gasket OD
    
%Initialize log entry string array
log_entry = "******** Suction System Design ********\n"; 
%print operational properties of the pump
log_entry = [log_entry; strcat("\n--- Sea Water Properties ---\n")]; 
log_entry = [log_entry; strcat("Desnity: ", string(rho_w), " kg/m^3 \n")];
log_entry = [log_entry; strcat("Dynamic viscosity: ", string(mu_w), " Pa.s \n")];
log_entry = [log_entry; strcat("\n--- Other Parameters ---\n")];
log_entry = [log_entry; strcat("Pipe roughness (stainless steel): ", string(epsilon_r), " \n")];
log_entry = [log_entry; strcat("clamshell height: ", string(cs_height), " m \n")];

%Assumed parameters
    theta_3 = 10; %degrees, defines the angle between the horizontal and clamshell front face when fully open
    L_f = 2; %m, maximum length of rigid piping with smaller diameter
    L_ff = 3; %m, maximum length of flexible piping with smaller diameter
    dp_ff = 2.3; %kPa/m approximate pressure drop per meter of flexible pipe
    L_s = 4; %m, maximum length of rigid piping with larger diameter
    dz = 5; %m, maximum vertical distance between suction inlet and outlet
log_entry = [log_entry; strcat("\n--- Assumed Parameters (based on worse case scenario) ---\n")];
log_entry = [log_entry; strcat("Clamshell fully open angle: ", string(theta_3), " degress \n")];
log_entry = [log_entry; strcat("Length of rigid pipe with diamter D_f: ", string(L_f), " m \n")];
log_entry = [log_entry; strcat("Length of flexible pipe with diamter D_f: ", string(L_ff), " m \n")];
log_entry = [log_entry; strcat("Length of rigid pipe with diameter D_s: ", string(L_s), " m \n")];
log_entry = [log_entry; strcat("Vertical distance between suction inlet and outlet: ", string(dz), " m \n")];

%% Suction flowrate
%Calculate the volume of fluid displaced by one closing clamshell
    A_d = pi*cs_height^2*((90 - theta_3)/360); %m^2, swing area of closing bucket
    V_d = A_d*cs_width; %m^3, volume of fluid displaced

%Calculate flow rate based on closing time and volume displaced
    Q_d = 2*V_d/t_c; %flowrate required for both clamshell    

%% Pipe sizes
%Call fuction to find best pipe size given flowrates
%Pipe size for flowrate of 1 clamshell (smaller pipe)
D_f = PipeSizeLookup(Q_d/2); %m
%Pipe size for flowrate of both clamshells (larger pipe)
D_s = PipeSizeLookup(Q_d); %m

%Calculate Reynolds number for each pipe size
Re_f = rho_w*(Q_d/2)*D_f/mu_w;
Re_s = rho_w*Q_d*D_s/mu_w;

%Calculate friction factor for smaller pipe size
if (Re_f < 2300) %if flow is laminar
    f_f = 64/Re_f;
else %if flow is turbulent
    f_f = 0.25/((log10(epsilon_r/(3.7*D_f) + 5.74/(Re_f^0.9)))^2);
end

%Calculate friction factor for larger pipe size
if (Re_s < 2300) %if flow is laminar
    f_s = 64/Re_s;
else %if flow is turbulent
    f_s = 0.25/((log10(epsilon_r/(3.7*D_s) + 5.74/(Re_s^0.9)))^2);
end

%% Fluid Velocity Through Pipes
%Larger pipe
v_f = 4*(Q_d/2)/(pi*D_f^2); %m/s
%Smaller pipe
v_s = 4*Q_d/(pi*D_s^2); %m/s

log_entry = [log_entry; strcat("\n--- Parameters of Smaller Pipe ---\n")];
log_entry = [log_entry; strcat("Diameter: ", string(D_f), " m \n")]; 
log_entry = [log_entry; strcat("Reynolds Number: ", string(Re_f), " \n")]; 
log_entry = [log_entry; strcat("Friction Factor: ", string(f_f), " \n")];
log_entry = [log_entry; strcat("Fluid Velocity: ", string(v_f), " m/s \n")];

log_entry = [log_entry; strcat("\n--- Parameters of Larger Pipe ---\n")];
log_entry = [log_entry; strcat("Diameter: ", string(D_s), " m \n")]; 
log_entry = [log_entry; strcat("Reynolds Number: ", string(Re_s), " \n")]; 
log_entry = [log_entry; strcat("Friction Factor: ", string(f_s), " \n")];
log_entry = [log_entry; strcat("Fluid Velocity: ", string(v_s), " m/s \n")];

%% Major Losses
%Major losses for smaller pipe
h_M_f = f_f*(L_f/D_f)*0.5*v_f^2; %m^2/s^2
%Major losses for larger pipe
h_M_s = f_s*(L_s/D_s)*0.5*v_s^2; %m^2/s^2
%Major losses for flexible pipe 
h_M_ff = dp_ff*1000*L_ff/rho_w; %m^2/s^2
%Total major losses of system 
h_M = h_M_f + h_M_s + h_M_ff; %m^2/s^2

log_entry = [log_entry; strcat("\n--- System Pressure Losses ---\n")];
log_entry = [log_entry; strcat("Major Losses: ", string(h_M), " m^2/s^2 \n")]; 

%% Minor Losses
%Call function to calculate minor losses
h_m = GetMinorLosses(v_s, f_s);
log_entry = [log_entry; strcat("Minor Losses: ", string(h_m), " m^2/s^2 \n")]; 

%% Pump Head Required
%Set kinetic energy coefficient (alpha) based on if system flow is primarily turbulent or laminar
if (Re_s < 2300) %if flow is laminar
    alpha = 2;
else %if flow is turbulent
    alpha = 1;
end

%Calculate required pump head based on major an minor losses  
pump_head = h_M + h_m + alpha*0.5*v_s^2 + grav*dz; %m^2/s^2
pump_head_p = pump_head*rho_w/1000; %kPa
pump_head_m = pump_head_p*0.10199773339984; %m

log_entry = [log_entry; strcat("\n--- Suction System Calculated Values ---\n")];
log_entry = [log_entry; strcat("Required maximum flow rate: ", string(Q_d), " m^3/s \n")];
log_entry = [log_entry; strcat("Required pump head: ", string(pump_head), " m^2/s^2 \n")];
log_entry = [log_entry; strcat("Required pump head: ", string(pump_head_p), " kPa \n")];
log_entry = [log_entry; strcat("Required pump head: ", string(pump_head_m), " m \n")];

%% Minimum and Maximum Pressures
%Call function to calculate maximum pressure
%Minimum pressure assumed to be at pump outlet
P_max = GetMaxPressure(D_s, v_s, f_s); %kPa
%Calculate minimum pressure based on pump head and max pressure
%Minimum pressure assumed to be at pump inlet
P_min = P_max - pump_head_p; %kPa

log_entry = [log_entry; strcat("Maximum system pressure: ", string(P_max), " kPa \n")];
log_entry = [log_entry; strcat("Minimum system pressure: ", string(P_min), " kPa \n")];

%% Pipe Thickness
pipe_thickness = GetPipeThickness(P_min, P_max, D_s); %m
pipe_thickness = pipe_thickness*1000; %mm - convert pipe thickness to mm

log_entry = [log_entry; strcat("Pipe thickness: ", string(pipe_thickness), " mm \n")];


%% Suction Pump Dimensioning
%Sends required values to suction pump code to calculate required pump size
Suction_Pump_Imp(Q_d, pump_head, depth, D_s, pipe_thickness);

%% Write Dimensions to Part File
% Full size Straight Pipe
    pipe_length = 750; %mm, pipe length
    StraightPipe("SS_StraightPipe.txt", flg_ex, flg_tk, pipe_thickness, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff,pipe_length)
%Half size stright pipe
    pipe_length = 200; %mm, pipe length
    StraightPipe("SS_StraightPipeSmall.txt", flg_ex, flg_tk, pipe_thickness, D_f, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff,pipe_length)
   

% Corner Pipe (full size then small)
    CornerPipe("SS_CornerPipe.txt", flg_ex, flg_tk, pipe_thickness, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);
    [corner_straight_length,corner_radius] = CornerPipe("SS_CornerPipeSmall.txt", flg_ex, flg_tk, pipe_thickness, D_f, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);

% T-Pipe (2 IN to 1 OUT)
    T_Pipe("SS_T-Pipe.txt", flg_ex, flg_tk, pipe_thickness, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);
    T_length = T_Pipe("SS_T-PipeSmall.txt", flg_ex, flg_tk, pipe_thickness, D_f, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);

    %T-Pipe Small to Big
    TSmallToBig("SS_T-PipeSmallToLarge.txt", T_length,flg_ex, flg_tk, pipe_thickness, D_f, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);

   
    
% Solenoid Valve
 SolenoidValveDimensions(flg_ex, flg_tk, pipe_thickness, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);
    
%Write to log
    Append_to_log(log_entry);

end

%Get pipe size from table based on known flow rate
%Flow_rate = pump flow rate in m^3/s
function pipe_size = PipeSizeLookup(flow_rate)
%Set standard pipe size for minimum pressure losses for different flow rates 
%Column 1 = flowrate in m^3/s
%Column 2 = pipe size in m 
std_pipe_sizes = [  0.0008833 0.0127;
                    0.001451 0.01905;
                    0.002334 0.0254;
                    0.003912 0.03175;
                    0.005110 0.0381;
                    0.008102 0.0508;
                    0.01199 0.0635;
                    0.01722 0.0762;
                    0.03038 0.1016;
                    0.04732 0.127;
                    0.06840 0.1524;
                    0.11990 0.2032 ];
                
 i = 1; %starting index
 
 while (true) %loop until value found, if not value found code will throw an error and stop
    %if flow rate is in between tabel values, take larger table value
      if((flow_rate <= std_pipe_sizes(i+1,1)) && (flow_rate> std_pipe_sizes(i,1)) ) 
        %get pipe size and brake while loop
        pipe_size = std_pipe_sizes(i+1,2); %assign pipe size
        break
      else
          i = i+1; %increment index if flow rate too small
      end  
 end
end

%Calculates minor losses based of estimate fixture quantities and equivalent loss values 
% v_s = fluid velocity in larger pipes in m/s
% f_s = fluid friction factor in larger pipes
function h_m = GetMinorLosses(v_s, f_s)
    global rho_w; 

%Sets equivalent lengths and quantities for fixtures in suction system
%Column 1 = quantity
%Column 2 = equivalent length
equ_L = [   1 60; %T-joint
            8 30; %90-Elbow
            1 80; %Wye-Joint
            2 8; %Solenoid Shutoff Valve
            2 0.2; %Exponsion Joint
            1 600 ]; %Check Valve
%finds length of array to determine number of increments in for loop
i_max = size(equ_L,1);
%initiallizes minor losses variable
h_m = 0; %m^2/s^2
%for loop to add minor losses based on equivalent lengths 
for i=1:i_max
    h_m = h_m + equ_L(i,1)*f_s*equ_L(i,2)*0.5*v_s^2; %m^2/s^2
end

%Sets loss coefficients and quantities for fixtures in suction system
%Column 1 = quantity
%Column 2 = loss coefficient
loss_coef = [   2 2.1; %Balancing valve - assumed 1/2 closed as worse case
                2 0.6]; %Pipe expansion - assumed large expansion as worse case
%finds length of array to determine number of increments in 'for' loop
j_max = size(loss_coef,1);
%for loop to add minor losses based on loss coefficients 
for j=1:j_max
    h_m = h_m + loss_coef(j,1)*loss_coef(j,2)*0.5*v_s^2;%m^2/s^2
end

%Add filter housing pressure drop to minor losses based on similarly sized nanofilters
%Add centrifugal separator pressure drop to minor losses (set to 65kPa in separator code)
h_m = h_m + 413.69*1000/rho_w + 65*1000/rho_w;
return %minor losses (h_m) (m^2/s^2) is returned to main function
end

%Calculates maximum considering it occurs immediately after pump 
% D_s = diameter of larger pipes in meters
% v_s = fluid velocity in larger pipes in m/s
% f_s = fluid friction factor in larger pipes
function P_max = GetMaxPressure(D_s, v_s, f_s)
    global rho_w;
    global grav;

%Set assumed values based on worse case senarios
    L_out = 1; %m, length of pipe after pump
    dz_out = 0.5; %m, height difference between pump outlet and system outlet
    
%% Major losses after pump outlet
h_M_out = f_s*(L_out/D_s)*0.5*v_s^2; %m^2/s^2

%% Minor losses after pump outlet
%Sets equivalent lengths and quantities for fixtures in suction system
%Column 1 = quantity
%Column 2 = equivalent length
equ_L_out = [   2 30; %90-Elbow
                1 8; %Solenoid Shutoff Valve
                1 0.2; %Exponsion Joint
                1 600 ]; %Check Valve
%finds length of array to determine number of increments in for loop
i_max = size(equ_L_out,1);
%initiallizes minor losses variable
h_m_out = 0; %m^2/s^2
%for loop to add minor losses based on equivalent lengths 
for i=1:i_max
    h_m_out = h_m_out + equ_L_out(i,1)*f_s*equ_L_out(i,2)*0.5*v_s^2; %m^2/s^2
end

%Sets loss coefficients and quantities for fixtures in suction system
%Column 1 = quantity
%Column 2 = loss coefficient
loss_coef_out = [2 0.6]; %Pipe expansion - assumed large expansion as worse case
%add minor losses based on loss coefficients to total minor losses
    h_m_out = h_m_out + loss_coef_out(1,1)*loss_coef_out(1,2)*0.5*v_s^2;%m^2/s^2

%% System maximum pressure
P_max = rho_w*(h_M_out + h_m_out + grav*dz_out)/1000; %kPa

return %maximum pressure (P_max) (kPa) is returned to main function
end

%Optimizes the pipe thickness based on the max and min pressure observeed
% P_min  = minimum relative pressure in pipe system
% P_max = maximum relative pressure in pipe system
% pipe_ID = inner diameter  of the pipes
function pipe_thickness = GetPipeThickness(P_min, P_max, pipe_ID)
%% Safety factor
SF = 1.5;
%% minimum pipe thickness allowable
t_min = 5/1000; %m
%% material properties of pipes: Stainless Steel 316
sigma_y = 240e6; %Pa, tensile yield stress
E = 193e9; %Pa, elasticity modulus
%% Pipe collapse (P_min)
P_min = abs(P_min); %Pa, use positive value
pipe_Ri = pipe_ID/2; %m, get pipe inner radius
t_inc = 0.01/1000; %m, 0.01mm increment to use
t_collapse = t_min; %m, initialize thickness

while(true) %do while loop 
    
%From analysis report, Eq. 3.90 and 3.91    
sigmaY_fail = (P_min*pipe_Ri/t_collapse)/(1-4*P_min*(pipe_Ri^3)/(E*t_collapse^3)); %calculate sigma_Y needed for failure
SF_calc = sigma_y/sigmaY_fail; %calculate resulting cafety factor for current thickness
if(SF_calc < SF) %if safety factor not adequate
    t_collapse = t_collapse + t_inc; %increase thickness to test
else %if safety factor good, stop loop and keep curent t_collapse
    break
end
%t_collapse is in meters
end
%% Pipe burst
%From Analysis report, Eq. 3.96
t_burst = P_max*pipe_ID/(2*(sigma_y/SF - P_max)); %m, pipe thickness required for burst
%% Return largest thickness
if (t_collapse >= t_burst) %assign largest value to pipe thickness
    pipe_thickness = t_collapse;
else
    pipe_thickness = t_burst;
end
return %pipe_thickness (meters) is returned to main function
end


%Write dimensions to solenoid valve equation txt file
function SolenoidValveDimensions(flg_ex, flg_tk, pipe_thickness, D_s, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff)
    
    %constant dimensions
    valve_length = 300; %mm, length of solenoid valve pipe (flange to flange)
    top_height=80; %mm, length of top solenoid pipe (excludes flange)
    valve_pipe_thickness = 7; %mm, solenoid top pipe thickness 
    wall_thickness = 7; %mm, thickness of inside divider wall
    plunger_OD = 90; %mm, OD of solenoid plunger and of the hole that it plugs
    flange_w = 190; %mm, square width of solenoid flange
    flange_l = flange_w; %mm, square length
    solenoid_wall_thickness	= 10; %mm, wall thickness around solenoid dummy	
    plunger_seal_thickness	= 5; %mm, extension and thickness and offeset of plunger lip
    square_pattern_w	= 160; %mm, width and length of square pattern for square flange fasteners	
    
    eqn = eqn_txt("flange_extension", flg_ex); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("pipe_ID", D_s*1000)];
    eqn = [eqn; eqn_txt("fastener_diameter", flg_hole_dia)];
    eqn = [eqn; eqn_txt("N_fasteners", N_flg_holes)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    
    
    eqn = [eqn; eqn_txt("valve_length", valve_length)];
    eqn = [eqn; eqn_txt("top_height", top_height)];
    eqn = [eqn; eqn_txt("valve_pipe_thickness", valve_pipe_thickness)];
    eqn = [eqn; eqn_txt("wall_thickness", wall_thickness)];
    eqn = [eqn; eqn_txt("plunger_OD", plunger_OD)];
    eqn = [eqn; eqn_txt("flange_w", flange_w)];
    eqn = [eqn; eqn_txt("flange_l", flange_l)];
    eqn = [eqn; eqn_txt("solenoid_wall_thickness", solenoid_wall_thickness)];
    eqn = [eqn; eqn_txt("plunger_seal_thickness", plunger_seal_thickness)];
    eqn = [eqn; eqn_txt("square_pattern_w", square_pattern_w)];

    Write_to_txt(eqn, "SS_SolenoidValve.txt", "Piping"); %Write dimensions to txt file
end

function StraightPipe(file_name, flg_ex, flg_tk, pipe_thickness, pipe_ID, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff, pipe_length)

    eqn = eqn_txt("flange_extension", flg_ex); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("pipe_length", pipe_length)];
    eqn = [eqn; eqn_txt("pipe_ID", pipe_ID*1000)];
    eqn = [eqn; eqn_txt("hole_diameter", flg_hole_dia)];
    eqn = [eqn; eqn_txt("N_holes", N_flg_holes)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    
    
    Write_to_txt(eqn, file_name, "Piping"); %Write dimensions to txt file

end

function [corner_straight_length,corner_radius] = CornerPipe(file_name,flg_ex, flg_tk, pipe_thickness, pipe_ID, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff)
    eqn = eqn_txt("flange_extension", flg_ex); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("pipe_ID", pipe_ID*1000)];
    eqn = [eqn; eqn_txt("hole_diameter", flg_hole_dia)];
    eqn = [eqn; eqn_txt("N_holes", N_flg_holes)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    
    corner_straight_length=75; %mm, straight length before corner (includes flange)
    corner_radius=150; %mm, corner radius (at middle of pipe)
    eqn = [eqn; eqn_txt("corner_straight_length", corner_straight_length)];
    eqn = [eqn; eqn_txt("corner_radius", corner_radius)];
    

    Write_to_txt(eqn, file_name, "Piping"); %Write dimensions to txt file
end

function T_length = T_Pipe(file_name, flg_ex, flg_tk, pipe_thickness, pipe_ID, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);

    T_length = 300; %mm, length of long side T-pipe flange to flange 
                        %short side is half
    INpipes_ID = pipe_ID; %mm, inner diameter of inputs
    OUTpipe_ID = pipe_ID; %mm, inner diameter of output
    
    eqn = eqn_txt("flange_extension", flg_ex); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("INpipes_ID", INpipes_ID*1000)];
    eqn = [eqn; eqn_txt("OUTpipe_ID", OUTpipe_ID*1000)];
    eqn = [eqn; eqn_txt("T_length", T_length)];
    eqn = [eqn; eqn_txt("hole_diameter", flg_hole_dia)];
    eqn = [eqn; eqn_txt("N_holes", N_flg_holes)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];

    Write_to_txt(eqn, file_name, "Piping"); %Write dimensions to txt file
end

function TSmallToBig(file_name, T_length,flg_ex, flg_tk, pipe_thickness, pipe_IDsmall, pipe_IDlarge, flg_hole_dia, N_flg_holes,gasket_thickness,gasket_Ro_diff);


    INpipes_ID = pipe_IDsmall; %mm, inner diameter of inputs
    OUTpipe_ID = pipe_IDlarge; %mm, inner diameter of output
    
    eqn = eqn_txt("flange_extension", flg_ex); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("INpipes_ID", INpipes_ID*1000)];
    eqn = [eqn; eqn_txt("OUTpipe_ID", OUTpipe_ID*1000)];
    eqn = [eqn; eqn_txt("T_length", T_length)];
    eqn = [eqn; eqn_txt("hole_diameter", flg_hole_dia)];
    eqn = [eqn; eqn_txt("N_holes", N_flg_holes)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];

    Write_to_txt(eqn, file_name, "Piping"); %Write dimensions to txt file
end

%used to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
txt_line = strcat("""", var_name, """ = ", string(value)); 
end