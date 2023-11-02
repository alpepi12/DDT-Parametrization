%This function estimates the breakout force required of the clamshell
%Parameters: heap capacity (m^3), excavation depth (m), excavation
%width(m), dimensions (for text file)
%Returns: breakout force (kN), dimensions (for text file)

function [breakout_force, dimensions] = sediment_force(heap_capacity,...
                                excavation_depth, excavation_width, ...
                                    dimensions)

    %Dimensionless factors are assumed to remain constant, stated in the
    %report, based on previous research.
    
    N_gamma = 2.02756;
    N_c = 2.13365;
    N_q = 4.05511;
    
    gamma = 1905;    %kg/m^3 (density for wet sand)
    c = 654.5;        %Pa (soil cohesion assumed consant)
    g = 9.81;         %m/s^2 (acceleration due to gravity)
    d = excavation_depth;   %m
    w = excavation_width; %m 
    V_h = heap_capacity;
    q = 0;              %surcharge pressure is neglected

    F_s = (gamma*g*d^2*N_gamma + c*d*N_c + q*d*N_q)*w;  %Shear Force
    F_r = V_h*gamma*g*d;    %Remolding Force
    
    breakout_force = (F_s + F_r)/1000;       %kN
    
    %Log Entries
    log_entry = "******** Bucket Breakout Force ********\n"; %Initialize log entry string array
    log_entry = [log_entry; strcat("Breakout Force: ", string(breakout_force), " kN \n")];
    log_entry = [log_entry; "**************************************\n"];
    Append_to_log(log_entry);
    
    dimensions = dimensions;
    
end


%Function to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
    txt_line = strcat("""", var_name, """ = ", string(value));
    
end