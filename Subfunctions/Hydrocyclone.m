%Calculates the geometry of the hydrocyclone
%Writes dimensions to part txt files
% close_time = closing time for the clamshell
% flow_rate = net flow rate required for closing clamshells GPM
% pipe_ID = Suction system pipe diameter
% pipe_t = pipe thickness
function [dc,Vin,N_hydr,d_in,du] = Hydrocyclone(close_time, Vo, pipe_ID, pipe_t,smallpipe_ID)

%If doing parametrization, arguments will be passed
%If GUI is calculating range for closing time, then no arguments passed
if(~exist('Vo','var'))
    GUI_mode = true; %flag for getting dc only (used by GUI)
    
    Vo = 1; %arbitrary values to avoid error
    d_in = 1;
    du = 1;
else
    GUI_mode = false;
end

m3s_to_GPM = 15850.32314; %conversion factor to convert m3/s to GPM
Vo = Vo*m3s_to_GPM; %convert pump flow rate to GPM

if(GUI_mode == false) %If performing check for GUI, no need to log
    log_entry = "******** HYDROCYCLONE DESIGN ********\n"; %Initialize log entry string array
    log_entry = [log_entry; strcat("\n--- Operational Properties ---\n")];
end

%material properties
    rho_w = 1028; %kg/m3, %density of water
    rho_s = 1905; %kg/m3, density of sand
    V = 0.75; %percent, %Sand content by volume
    
%Operational properties
    N_hydr = 2; %# of total hydrocyclones used 
    Vo = Vo/N_hydr; %GPM, overflow flow rate of individual hydrocyclone
    DeltaP = 65; %kPa, assumed pressure drop
    dco = 62.5; %microns, cutoff particle diameter
    SP =98.8; %probability that dCO sized particles are separated into the underflow
    tbl_SP_K = [    98.8 0.54;
                    95.0 0.73;
                    90.0 0.91
                    80.0 1.25;
                    70.0 1.67;
                    60.0 2.08;
                    50.0 2.78]; %table used to find K based on SP

if(GUI_mode == false) %If performing check for GUI, no need to log
    log_entry = [log_entry; strcat("Number of hydrocyclones: ", string(N_hydr), " \n")];
    log_entry = [log_entry; strcat("Pressure drop = ", string(DeltaP), " kPa \n")];
    log_entry = [log_entry; strcat("Cut-off particle diameter: ", string(dco), " microns \n")];    
    log_entry = [log_entry; strcat("Separation probability at cut-off diameter: ", string(SP), "% \n")];
end
%% Hydrocyclone dimensioning
    if(GUI_mode == false) %If performing check for GUI, no need to log
        log_entry = [log_entry; strcat("\n\n--- Hydrocyclone Design ---\n")];    
    end
    
    K = tbl_SP_K((tbl_SP_K(:,1)==SP),2); %retreive multiplying factor from table based on SP
    if(isempty(K)) %If nothing found, stop!
        error("SP value selected not in table! Select a valid SP value.")
    end
    
    %Find D50c
    D50c = K*dco; %microns, first d50 (diameter with 50% prob separation) approximation

    %Correction factors
    C1 = ((53-V)/53)^(-1.43); % C1 factor based on solid concentratino in water
    C2 = 3.27*DeltaP^(-0.28); % C2 factor based on pressure drop
    C3 = (1.65/(rho_s/rho_w - 1))^0.5; % C3 factor based on densities

    %Correct D50c
    D50c = D50c/(C1*C2*C3); %microns, corrected d50 (diameter with 50% prob separation) approximation
    
    %cyclone diameter
    dc = (D50c/2.84)^(1/0.66); % cm
    dc = round(dc/2.54); %in, convert to inches
    if(GUI_mode == false) %If performing check for GUI, no need to log
        log_entry = [log_entry; strcat("Cyclone diameter = ",string(dc), " inches (", string(dc*2.54), " cm)", " \n")];
    end
       
    
    %Total inlet flow rate
    A = 0.524413934550285; %constants computed from Analysis report figures
    B = 1.79484299572557;
    
    Vin = 10^(A*log10(DeltaP)+B); %GPM, inlet flow rate per hc
    Vu = Vin - Vo; %GPM, underflow flow rate per hc
    
    %For GUI, return dc and Vin values and do not proceed with remainder of
    %calculations
    if (GUI_mode == true)
        return
    end
    
    
    %Underflow diameter
    A = 2.06673678052649; %constants computed from Analysis report figures
    B = 1.15747297488195;
    du = 10^((log10(Vu)-B)/A); %in, underflow diameter
    
    if(GUI_mode == false) %If performing check for GUI, no need to log
        log_entry = [log_entry; strcat("Inlet flow rate per hydrocylone = ",string(Vin), " GPM (", string(Vin*0.06309), " L/s) \n")];
        log_entry = [log_entry; strcat("Overflow flow rate per hydrocyclone = ", string(Vo), " GPM (", string(Vo*0.06309), " L/s) \n")];
        log_entry = [log_entry; strcat("Underflow flow rate per hydrocyclone = ", string(Vu), " GPM (", string(Vu*0.06309), " L/s) \n")];
        log_entry = [log_entry; strcat("Underflow diameter = ", string(du), " in (", string(du*2.54), " cm) \n")];
    end
    
%% Other dimensioning
    do = 0.35*dc; %in, overflow diameter
    AF = 0.05*dc^2; %in^2, rectangular inlet area
    wf = sqrt(AF)*0.66; %in, inlet width, smaller than hf
    hf = AF/wf; %in, inlet height, larger than wf
    Lv = 1.05*hf; %in, vortex length into cylinder
    Lcyl = dc; %in, cylinder length
    alpha = 15; %degrees, conical angle
    
    %circular inlet area for clamshell
    d_in = sqrt(4*AF/pi); %in2
    d_in= d_in*25.4; %mm2
    
    %add other hard dimensions here
    wall_thick = 5; %mm, thickness of walls
    flange_ext = 30; %mm, flange extension from outer wall
    flange_thick = 5; %mm, flange thickness
    overflow_lip_thickness = 15; %mm, thickness that over pipe will be fastend to
    
    N_holes = 8; %number of fastner holes
    hole_dia = 12; %mm, diameter of fastners
    
    gasket_Ro_diff =0.25*25.4; %mm, how much smaller gasket outer radius is to flange outer radius
    gasket_Ri_diff = 0.0*25.4; %mm, how much larger gasket inner radius is to cyclone inner radius
    gasket_thick = (1/16)*25.4; %mm, thickness of gasket
    
    Lv = 1.1*hf; %in, length of the vortex protruding into the cylindrical section
    
    if(GUI_mode == false)
        log_entry = [log_entry; strcat("Overflow diameter = ", string(do), " in (", string(do*2.54), " cm) \n")];
        %Add other log items
    end
    
%% Nut & Bolt dimensions
   log_entry = [log_entry; "\n--- Nuts & bolts ---\n"];
   extra = 10; %mm, amount that bolts stick out from flanges
   head_thick = 5; %mm, hex head thickness
   head_width = 3; %mm, max width on each side of nut OD
   nut_length = flange_thick*2+gasket_thick+extra; %mm, length of nut
    
   nut_dia = hole_dia; %mm, diameter of fastner
    
   bolt_thick = 5; %mm, bolt thickness
   bolt_width = 3; %mm, max width on each side of hole
    
   log_entry = [log_entry; strcat("Nuts used = ", string(nut_dia), "M.\n")];

%% Write dimensions to part file

%Cylinder section
    eqn = eqn_txt("cylinder_length", Lcyl*25.4); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("cyclone_diameter", dc*25.4)];
    eqn = [eqn; eqn_txt("wall_thickness", wall_thick)];
    eqn = [eqn; eqn_txt("flange_thickness", flange_thick)];
    eqn = [eqn; eqn_txt("flange_extension", flange_ext)];
    eqn = [eqn; eqn_txt("N_holes", N_holes)];
    eqn = [eqn; eqn_txt("hole_diameter", hole_dia)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    eqn = [eqn; eqn_txt("gasket_Ri_diff", gasket_Ri_diff)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thick)];
    
    
    Write_to_txt(eqn, "SS_HC_Cylinder.txt", "Hydrocyclone"); %Write dimensions to txt file

%Cone section
    eqn = eqn_txt("cone_angle", alpha); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("cyclone_diameter", dc*25.4)];
    eqn = [eqn; eqn_txt("underflow_diameter", du*25.4)];
    eqn = [eqn; eqn_txt("wall_thickness", wall_thick)];
    eqn = [eqn; eqn_txt("flange_thickness", flange_thick)];
    eqn = [eqn; eqn_txt("flange_extension", flange_ext)];
    eqn = [eqn; eqn_txt("N_holes", N_holes)];
    eqn = [eqn; eqn_txt("hole_diameter", hole_dia)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    eqn = [eqn; eqn_txt("gasket_Ri_diff", gasket_Ri_diff)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thick)];
    
    Write_to_txt(eqn, "SS_HC_Cone.txt", "Hydrocyclone"); %Write dimensions to txt file

%Feed Cylinder
    eqn = eqn_txt("overflow_diameter", do*25.4); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("cyclone_diameter", dc*25.4)];
    eqn = [eqn; eqn_txt("feed_width", wf*25.4)];
    eqn = [eqn; eqn_txt("feed_height", hf*25.4)];
    
    eqn = [eqn; eqn_txt("wall_thickness", wall_thick)];
    eqn = [eqn; eqn_txt("flange_extension", flange_ext)];
    eqn = [eqn; eqn_txt("flange_thickness", flange_thick)];
    eqn = [eqn; eqn_txt("N_holes", N_holes)];
    eqn = [eqn; eqn_txt("hole_diameter", hole_dia)];
    eqn = [eqn; eqn_txt("overflow_lip_thickness", overflow_lip_thickness)];
    
    
    inlet_pipe_length	= 200; %mm, length of circle to square inlet pipe	
    inlet_circle_ID	= d_in; %mm, ID of circle of inlet pipe
    corner_radius	= 75; %mm, corner pipe radius (along centerline of pipe)
    corner_straight_length	= 50; %mm, corner pipe straight part radius (include flange)
    
    eqn = [eqn; eqn_txt("inlet_pipe_length", inlet_pipe_length)];
    eqn = [eqn; eqn_txt("inlet_circle_ID", inlet_circle_ID)];
    eqn = [eqn; eqn_txt("corner_radius", corner_radius)];
    eqn = [eqn; eqn_txt("corner_straight_length", corner_straight_length)];
    
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    eqn = [eqn; eqn_txt("gasket_Ri_diff", gasket_Ri_diff)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thick)];
    
    eqn = [eqn; eqn_txt("pipe_ID", smallpipe_ID*1000)];
    eqn = [eqn; eqn_txt("pipe_t", pipe_t)];
       
    Write_to_txt(eqn, "SS_HC_FeedChamber.txt", "Hydrocyclone"); %Write dimensions to txt file

% Overflow Pipe
    eqn = eqn_txt("overflow_diameter", do*25.4); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("length_vortex", Lv*25.4)];
    eqn = [eqn; eqn_txt("wall_thickness", wall_thick)];
    
    eqn = [eqn; eqn_txt("overflow_lip_thickness", overflow_lip_thickness)];
    eqn = [eqn; eqn_txt("flange_extension", flange_ext)];
    eqn = [eqn; eqn_txt("flange_thickness", flange_thick)];
    eqn = [eqn; eqn_txt("N_holes", N_holes)];
    eqn = [eqn; eqn_txt("hole_diameter", hole_dia)];
    eqn = [eqn; eqn_txt("gasket_Ro_diff", gasket_Ro_diff)];
    eqn = [eqn; eqn_txt("gasket_Ri_diff", gasket_Ri_diff)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thick)];
    
    
    
    Write_to_txt(eqn, "SS_HC_OverflowPipe.txt", "Hydrocyclone"); %Write dimensions to txt file


 %Nuts & bolts
   eqn = strcat("""nut_length"" = ", string(nut_length));
   eqn =[eqn; strcat("""nut_diameter"" = ", string(nut_dia))];
   eqn =[eqn; strcat("""head_thickness"" = ", string(head_thick))];
   eqn =[eqn; strcat("""head_width"" = ", string(head_width))];
   
   Write_to_txt(eqn, "SS_HC_Nut.txt", "Hydrocyclone"); %Write dimensions to txt file
   
   eqn = strcat("""bolt_thickness"" = ", string(bolt_thick));
   eqn =[eqn; strcat("""bolt_width"" = ", string(bolt_width))];
   eqn =[eqn; strcat("""hole_diameter"" = ", string(nut_dia))];
   
   Write_to_txt(eqn, "SS_HC_Bolt.txt", "Hydrocyclone"); %Write dimensions to txt file
   
   
   du = du*25.4; %convert to millimeters for use by other functions
    
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