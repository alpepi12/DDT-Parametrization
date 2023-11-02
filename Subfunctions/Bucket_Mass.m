%This function calculates the mass of one full clamshell
%Parameters for this function: excavation width (m), suction hose diameter
%(mm), return hose diameter (mm)
%Returns: mass of one full clamshell in kg AND heap capacity of bucket in
%m^3, Solidworks text file string

function [bucket_mass_full, heap_capacity, dimensions] = bucket_mass(excavation_width,...
                                                d_underflow,...
                                                    d_inlet)
    bucket_height = 1;  %approximate the height based on the excavation depth specified
    bucket_base = bucket_height*1.2;
    bucket_thickness = 0.012;
    
    density_steel = 8000;   %density of stainless steel 8000 kg/m^3
   
    projected_area = bucket_height^2;   %P_B
    
    %Surface area estimate: side of the buckets as squares, right-angled
    %triangle back side multiplied by 1.6 to compensate the estimate error
    bucket_SA = 2*bucket_base^2 + sqrt(bucket_base^2 + bucket_height^2)...
                    *excavation_width*1.6;
    
    %Volume of material the bucket is made of (bucket estimated surface
    %area multiplied by its thickness)
    bucket_material_volume = bucket_SA * bucket_thickness;
    
    %Mass of bucket material (bucket material volume multiplied by the
    %density of stainless steel)
    bucket_mass = bucket_material_volume*density_steel;
    
    %capcaity of the bucket (projected side profile of bucket multiplied by
    %the width of the bucket)
    heap_capacity = projected_area*excavation_width;
    
    density_wet_sand = 1905;
    v_barrel = 0.0025;   %volume of a standard industrial barrel
    
    %mass of half a full clamshell (barrel assumed to be evenly distributed
    %throughout both clamsheels)
    bucket_mass_full = density_steel*v_barrel/2 + density_wet_sand*...
                            (heap_capacity - v_barrel/2) ...
                                + bucket_mass;
    closed_clamshell_full_mass = bucket_mass_full*2;
    
    %Log Entries
    log_entry = "******** Bucket Mass + Capacity ********\n"; %Initialize log entry string array
    log_entry = [log_entry; strcat("Single clamshell mass: ", string(bucket_mass), " kg \n")];
    log_entry = [log_entry; strcat("Closed Full Clamshell Mass: ", string(closed_clamshell_full_mass), " kg \n")];
    log_entry = [log_entry; strcat("Clamshell Heap Capacity: ", string(heap_capacity), " m^3 \n")];
    
    %Append log entry
     log_entry = [log_entry; "**************************************\n"];
     Append_to_log(log_entry);
                            
    %initialize Solidworks text file string
    dimensions = eqn_txt("bucket_lb", 1000);    %mm
    dimensions = [dimensions; eqn_txt("bucket_blade_hole_diameter", 20)];   %mm
    dimensions = [dimensions; eqn_txt("bucket_bracket_distance", 150)]; %mm
    dimensions = [dimensions; eqn_txt("suction_hose_flange_bolt_diameter", 12)]; 
    dimensions = [dimensions; eqn_txt("return_hose_flange_bolt_diameter", 6)];
    dimensions = [dimensions; eqn_txt("return_hose_diameter", d_underflow)];
    dimensions = [dimensions; eqn_txt("suction_hose_diameter", d_inlet)];
    dimensions = [dimensions; eqn_txt("bucket_width", excavation_width*1000)];
    
end

%Function to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
    txt_line = strcat("""", var_name, """ = ", string(value));
    
end
