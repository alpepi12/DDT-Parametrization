%Function adjusts the length of each filter to accomodate different flow
%rates
%flow_rate = current flow rate based on GUI parameters
function Nanofilters(flow_rate,D_f,T_length,corner_straight_length,corner_radius)

log_entry = "******** NANOFILTERS DESIGN ********\n"; %Initialize log entry string array
log_entry = [log_entry; strcat("\n--- Filter + Housing Dimensioning ---\n")];

m3s_to_GPM = 15850.32314; %conversion factor to convert m3/s to GPM
flow_rate = flow_rate*m3s_to_GPM;

max_flow_rate = 1.084502042184655e+03; %GPM, maximum possible flow rate that could result from parametrization
SF = flow_rate/max_flow_rate; %scaling factor to scale length of filters


%Constant values
N_F = 2; %number of female filters
N_M = 1; %number of male filters

%Constant dimensions

filter_ID = 28.6; %mm, inner diameter of filters
filter_diameter = 200.6; %mm, OD of filters
filter_ext_length = 25.4; %mm, length of male filter extension
tube_thickness = 2;  %mm, thickness of extension tube
housing_thickness = 10; %mm, thickness of main housing tube
flange_thickness = 15; %mm, thickness of flanges
flange_extension = 50; %mm, extension of flanges from tube OD

endcap_diameter = filter_diameter + 2*(housing_thickness+flange_extension); %mm, end cap diameter


input_ID = D_f*1000; %mm, inner diameter of input tube	
input_thickness = 5;	%mm, input tube thickness	
input_offset	= 100; %mm, distance from near-side of the housing flange to center of input tube 
input_height	= 200; %mm, how far input tube sticks out (from center of filters (top plane))

output_ID= D_f*1000; %mm, inner diameter of output tube			
output_thickness = 5; %mm, thickness of output tube
output_height	= 200; %mm, how much output tube sticks out (flange to flange)

gasket_thickness  = 2; %mm, thickness of gasket

fastener_hole_diameter = 14; %mm, diameter of fastner holes
fastener_pattern_diameter = 285; %mm, diameter of circular pattern
N_fasteners = 8; %number of fasteners on flanges

%Scalable dimensions (given dimensions are for max flow rate, so scale if lower)
filter_length_F = 965.2; %mm, length of female filter
filter_length_M = 965.2; %mm, length of male filter (inner tube extensions excluded!)
N_tube_holes = 50; %number of holes in inner tube at max length

%scale the appropriate dimensions based on flow rate required
filter_length_F = SF*filter_length_F;
filter_length_M = SF*filter_length_M; 
N_tube_holes = floor(SF*N_tube_holes);

housing_total_length = 2*(gasket_thickness) +N_F*(filter_length_F) +N_M*(filter_length_M);  
%mm, end to end length (including flanges) of main housing 

% Log entries
log_entry = [log_entry; strcat("Filter length scaling factor: ", string(SF), " \n")];
log_entry = [log_entry; strcat("Total housing length (w/o endcap): ", string(housing_total_length), " mm \n")];
log_entry = [log_entry; strcat(string(N_F), " female filters, ", string(N_M), " male filters. \n")];
log_entry = [log_entry; strcat("Individual filter length: ", string(filter_length_F), " mm \n")];
log_entry = [log_entry; strcat("Input tube offset from flange: ", string(input_offset), " mm \n")];
log_entry = [log_entry; strcat("Input tube ID: ", string(input_ID), " mm \n")];
log_entry = [log_entry; strcat("Input tube thickness: ", string(input_thickness), " mm \n")];
log_entry = [log_entry; strcat("Output tube ID: ", string(output_ID), " mm \n")];
log_entry = [log_entry; strcat("Output tube thickness: ", string(output_thickness), " mm \n")];

%Write dimensions to text file

    eqn = eqn_txt("filter_ID", filter_ID); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("filter_diameter", filter_diameter)];
    eqn = [eqn; eqn_txt("filter_ext_length", filter_ext_length)];
    eqn = [eqn; eqn_txt("tube_thickness", tube_thickness)];
    eqn = [eqn; eqn_txt("housing_thickness", housing_thickness)];
    eqn = [eqn; eqn_txt("flange_thickness", flange_thickness)];
    eqn = [eqn; eqn_txt("flange_extension", flange_extension)];
    eqn = [eqn; eqn_txt("endcap_diameter", endcap_diameter)];
    eqn = [eqn; eqn_txt("filter_length_F", filter_length_F)];
    eqn = [eqn; eqn_txt("filter_length_M", filter_length_M)];
    
    eqn = [eqn; eqn_txt("input_ID", input_ID)];
    eqn = [eqn; eqn_txt("input_thickness", input_thickness)];
    eqn = [eqn; eqn_txt("input_offset", input_offset)];
    eqn = [eqn; eqn_txt("input_height", input_height)];
    eqn = [eqn; eqn_txt("output_ID", output_ID)];
    eqn = [eqn; eqn_txt("output_thickness", output_thickness)];
    eqn = [eqn; eqn_txt("output_height", output_height)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("N_tube_holes", N_tube_holes)];
    eqn = [eqn; eqn_txt("fastener_hole_diameter", fastener_hole_diameter)];
    eqn = [eqn; eqn_txt("fastener_pattern_diameter", fastener_pattern_diameter)];
    eqn = [eqn; eqn_txt("N_fasteners", N_fasteners)];
    eqn = [eqn; eqn_txt("housing_total_length", housing_total_length)];
    
    eqn = [eqn; eqn_txt("T_length", T_length)]; %T-pipe length (flange to flange)
    eqn = [eqn; eqn_txt("corner_straight_length", corner_straight_length)]; %Corner Pipe length (flange to radius begin)
    eqn = [eqn; eqn_txt("corner_radius", corner_radius)]; %Corner pipe radius (along middle of pipe)
    
    Write_to_txt(eqn, "SS_NF_FilterHousing.txt", "Nanofilters"); %Write dimensions to txt file
    
    
   %Append log entry
   log_entry = [log_entry; "**************************************\n"]
   Append_to_log(log_entry);

end


%used to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
txt_line = strcat("""", var_name, """ = ", string(value)); 
end