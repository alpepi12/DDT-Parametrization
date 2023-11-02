
%This function is the main "design" function.
function Design_code(excavation_width, excavation_depth, closing_time, operation_depth) 
       
         drive = pwd; %Get working directory drive
        drive = extractBefore(drive, "\groupDDT1");
        
        
        %Check if the user tries to run this file directly
    if ~exist('operation_depth','var')      
        cd_location = strcat(drive,'\groupDDT1\MATLAB\');
        run_location = strcat(drive,'\groupDDT1\MATLAB\MAIN.m');
        cd(cd_location)
        run(run_location);  %Run Main.m instead
        return
    end 
    
    
    %Clear log file
    log_file = strcat(drive,'\groupDDT1\Log\groupDDT1_LOG.TXT');
    fid = fopen(log_file,'w+t'); %Clear log contents
    fclose(fid);
    
    log_entry = "DDT1 | DEEP-WATER DECONTAMINATION \n";
    log_entry = [log_entry; "Parameters selected from GUI:"];
    log_entry = [log_entry; strcat("\tOperational depth: ", string(operation_depth), " metres")];
    log_entry = [log_entry; strcat("\tExcavation depth into soil: ", string(excavation_depth), " metres")];
    log_entry = [log_entry; strcat("\tExcavation bucket width: ", string(excavation_width), " metres")];
    log_entry = [log_entry; strcat("\tClamshell closing time ", string(closing_time), " seconds")];
    log_entry = [log_entry; "----------------------------------------------------\n"];
    Append_to_log(log_entry);
    

    %% Call functions to size the design 
    
     
    %Design Optimization (Design subfunctinos)
    
    %Suction system components
    [pump_flow, pipe_ID, pipe_t, smallpipe_ID,T_length,corner_straight_length,corner_radius] = Suction_System(excavation_width, closing_time, operation_depth);
    [dc,Vin, N_hydr,d_inlet,d_underflow] = Hydrocyclone(closing_time, pump_flow, pipe_ID, pipe_t,smallpipe_ID); %size the hydrocyclone 
    Nanofilters(pump_flow, smallpipe_ID,T_length,corner_straight_length,corner_radius);
    
    %Bucket calculations pt. 1
    [bucket_mass_full, heap_capacity, dimensions] = Bucket_Mass(excavation_width,d_underflow, d_inlet);
    [breakout_f, dimensions] = breakout_force(heap_capacity, excavation_depth, excavation_width,  dimensions);
	
    %Hydraulics dimensioning and calculations
    [hydraulic_force,hydraulic_angle] = HydraulicSystem(breakout_f);
    
    %Bucket calculations pt. 1
    [pin_diameter, hydraulic_force_x, hydraulic_force_y, F3_x, F3_y, dimensions] = pin(bucket_mass_full, hydraulic_force, hydraulic_angle,breakout_f, dimensions);
	[weld_leg] = bracket_weld(pin_diameter,hydraulic_force_x, hydraulic_force_y, F3_x, F3_y, dimensions);
    
    %write pin_diameter to hydraulic actuator text file
    stringToWrite = strcat(" \n""buckholed"" =", string(pin_diameter));
    Write_to_txt(stringToWrite, "HA_Actuator.txt", "Hydraulic Actuator", 1); %Write dimensions to txt file
    
    
    % Electronics pressure vessel
    Pressure_vessel(operation_depth); %Size the pressure vessel
end