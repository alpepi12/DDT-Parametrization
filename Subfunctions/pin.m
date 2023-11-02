%This function estimates the required pin diameter to prevent failure in
%pin due to bending

%Parameters: bucket mass (kg), hydraulic force (kN), hydraulic angle
%(degrees), breakout force (kN), dimensions (for text file)
%Returns Pind diameter

function [pin_diameter, hydraulic_force_x, hydraulic_force_y, F3_x, F3_y, dimensions] = pin(bucket_mass_full, hydraulic_force, hydraulic_angle,...
        breakout_force, dimensions)

%Variables (remove when link has been set)
    bracket_thickness = 50; %mm
    
    dimensions = dimensions;

    %Safety Factor
    SF_Pins = 1.5;       %Applied on ultimate stress of pins
    
    %Material Properties
    %Pin Material
    sigma_yield_pin = 350;     %GPa, Tensile strength of pin material (steel)
    
    
    %Force Components
    hydraulic_force = abs(hydraulic_force);  %N
    hydraulic_force_x = hydraulic_force*cos(hydraulic_angle);
    hydraulic_force_y = hydraulic_force*sin(hydraulic_angle);
    
    breakout_force = abs(breakout_force*1000);    %kN to N
    breakout_force_x = abs(breakout_force*cos(pi/2));
    breakout_force_y = abs(breakout_force*sin(pi/2));
    
    bucket_weight = bucket_mass_full*9.81;    %N
    
    F3_x = hydraulic_force_x + breakout_force_x;
    F3_y = bucket_weight + hydraulic_force_y - breakout_force_y;
    F_3 = sqrt(F3_x^2+F3_y^2);
    
    %Force to middle of bracket
    c = 75;
    
    moment_2 = hydraulic_force*((bracket_thickness/2)+c);
    moment_3 = F_3*((bracket_thickness/2)+c);
    
    diameter_2 = (64*moment_2*((c+(bracket_thickness/2)))/(pi*sigma_yield_pin))^(1/4);
    diameter_3 = (64*moment_3*((c+(bracket_thickness/2)))/(pi*sigma_yield_pin))^(1/4);
    
    pin_diameter = max(diameter_2, diameter_3);
    
    %Log Entries
    log_entry = "******** Pin Diameter ********\n"; %Initialize log entry string array
    log_entry = [log_entry; strcat("Minimum Pin Diameter: ", string(pin_diameter), " mm \n")];
    log_entry = [log_entry; "**************************************\n"];
    Append_to_log(log_entry);
    
    dimensions = [dimensions; eqn_txt("bucket_bracket_pin_diameter", pin_diameter)];
    
    
    textToWrite = strcat("""bucketpindia"" =", string(pin_diameter));
    Write_to_txt(textToWrite, "BucketFrame.txt", "Bucket"); %Write dimensions to txt file

end

%Function to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
    txt_line = strcat("""", var_name, """ = ", string(value));
    
end