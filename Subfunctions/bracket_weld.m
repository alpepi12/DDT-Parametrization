%This function estimates the minimum weld leg to ensure the bracket does
%not fail
%Parameters: pin diameter (mm), pin 2 force (N), pin 3 force (N),
%dimensions
%Returns: Weld leg (mm)


function [weld_leg] = bracket_weld(pin_diameter,hydraulic_force_x, hydraulic_force_y, F3_x, F3_y, dimensions)

    %Approxmiate Bracket Dimensions
    %Middle of bucket bracket attachment as origin
    bracket_base = 475+1.25*pin_diameter+1.5*pin_diameter;

    if pin_diameter < 140 
        bracket_height = 3.5*pin_diameter+225;
    else
        bracket_height = 2.75*pin_diameter +225;
    end

    %Bracket Center of Geometry
    bracket_centroid_x = bracket_base/2;
    bracket_centroid_y = bracket_height/2;
    
    pin2_to_centroid_x = bracket_base - bracket_centroid_x - 1.5*pin_diameter;
    pin2_to_centroid_y = bracket_height - bracket_centroid_y - 1.5*pin_diameter;
    pin3_to_centroid_x = bracket_base - 1.25*pin_diameter - bracket_centroid_x;
    pin3_to_centroid_y = bracket_height - bracket_centroid_y - 1.25*pin_diameter;
   
    %Moments about each pin
    pin2_moment = hydraulic_force_x*pin2_to_centroid_y + hydraulic_force_y*pin2_to_centroid_x;
    pin3_moment = F3_x*pin3_to_centroid_y + F3_y*pin3_to_centroid_x;
    
    %Resolving Force-Moment at CoG of Bracket
    Fx_CoG = hydraulic_force_x + F3_x;
    Fy_CoG = hydraulic_force_y + F3_y;
    Resultant_Force_CoG = sqrt(Fx_CoG^2 + Fy_CoG^2);
    moment_CoG = pin2_moment + pin3_moment;

    %Moment from pin forces on center of weld
    pin_moment = Fx_CoG*bracket_centroid_y + (Fy_CoG*bracket_centroid_x);
    total_weld_moment = pin_moment + moment_CoG;

    %Safety Factor 
    %Safety factor of 3 chosen due to the large overall estimations
    SF_Welds = 3;

    %Shear Force
    V = Resultant_Force_CoG;

    %Weld Calculations
    sigma_yield_weld = 482;      %Weld material yield strength
    sys = sigma_yield_weld*0.58;  
    weld_area = bracket_base;
    unit_second_moment_of_area = 2*(bracket_base^3)/12;
    c = bracket_base/2;      %distance to weld from central axis

    weld_throat = SF_Welds*sqrt((V/weld_area)^2 + (total_weld_moment*c/unit_second_moment_of_area)^2)/sys;
    weld_leg = weld_throat/0.707;   %mm
    
    
    %Log Entries
    log_entry = "******** Weld Leg ********\n"; %Initialize log entry string array
    log_entry = [log_entry; strcat("Minimum Weld Leg: ", string(weld_leg), " mm \n")];
    log_entry = [log_entry; "**************************************\n"];
    Append_to_log(log_entry);
    
    dimensions = [dimensions; eqn_txt("weld_leg", weld_leg)];
    
    Write_to_txt(dimensions, "bucket_geometry.txt", "Bucket");

end


%Function to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
    txt_line = strcat("""", var_name, """ = ", string(value));
    
end