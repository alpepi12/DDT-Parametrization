
%Calculates the geometry of the entire pressure vessel (PV) assembly
%Writes dimensions to part txt files
% depth = operational depth of barrel recovery
function Pressure_vessel(depth)

log_entry = "******** PRESSURE VESSEL ********\n"; %Initialize log entry string array

%Safety factor
    SF = 1.6; %applied on collapse pressure instead of sigmaY
    
%Material properties
    %seawater
    rho_w = 1035; %kg/m3, density of seawater
    
    %Vessel and end-cap: 316 stainless steel
    sigma_y = 240e6; %Pa, tensile strength
    
    
%Calculate hydrostatic pressure and apply 1.6 factor as discussed in reports  
    q_ = rho_w*depth*9.81; %Pa, NDP
    q = SF*q_; %CDP >= 1.6*NDP
    log_entry = [log_entry; strcat("Nominal Depth Pressure = ", string(q_/1e6), " MPa.\n")];
    log_entry = [log_entry; strcat("Collapse Depth Pressure = ", string(q/1e6), " MPa.\n")];
    
    
    
%% Dimensions & geometric properties
    %Pressure vessel main housing
    b = 0.12; %m, inside radius of PV
    L = 1.0; %m, inside length of PV
    flange_ext = 0.04; %m, flange extension, for solidworks use
    flange_thick = 25/1000; %m, flange thickness, for solidworks use
    N_holes = 8 ; %number of holes for fastners in flange
    holes_dia = 14/1000; %m,  %diameter of those holes
    endcap_depth = 50/1000; %m, depth that end-cap protrudes into vessel
    endcap_inner_thick = 30/1000; %m,thickness of the inside revolution protruding into vessel 
    
    extra = 18/1000; %m, distance nut will stick out from its hole
    
    oring_width = 5;% mm, o-ring width
    
    %Penetrator dimensions
    pen_dia = 20; %mm
    pen_layout_dia = 100; %mm
    pen_fastners_dia = 40; %fastner layout diameter
    pen_fastner_hole_dia = 5; %mm, fastener hole diameter
    
      
%% PRESSURE VESSEL WALLS
    
    log_entry = [log_entry; strcat("\n--- Pressure Vessel Walls ---\n")];

    t_w = 0.005; %m, minimum wall thickness allowable
    inc = 0.5/1000; %m, increment to use for t_w
    
    
    cp = 0; %calculated collapse pressure
    
    while (cp < q) %while collapse pressure smaller than allowed CDP
        t_w = t_w + inc;
        
        a = t_w + b; %m, get outer diameter
        
        cp = (2/6)*((sigma_y^2)*(a^2-b^2)^2)/(a^4) ; %Von Mises and principal stresses in thick shell
        cp = sqrt(cp); %Pa, collapse pressure for given t_w      
    end
    
    log_entry = [log_entry; strcat("Inner length = ", string(L*100), " cm.\n")];
    log_entry = [log_entry; strcat("Inner radius = ", string(b*100), " cm.\n")];
    log_entry = [log_entry; strcat("Vessel wall thickness = ", string(t_w*100), " cm.\n")];
    
    %Dimensions calculations
    flange_OD = (b + t_w + flange_ext)*2; %m, flange OD
    holes_patt_dia = (flange_OD + 2*b +2*t_w)/2; %m, diameter of fastners circular pattern. Halfway between outside wall and outside of flange
    
%% END-CAP

log_entry = [log_entry; strcat("\n--- Pressure Vessel End-cap ---\n")];

% Max stresses in a flat circular plate, ends fixed
% re-used variables same as last section
    %max bending
    t_bend = (3*q*b^2)/(4*sigma_y); 
    t_bend = sqrt(t_bend); %thickness to resist bending (1.6 SF included in q)
    
    %max shear
    t_shear = (3*q*b)/(4*0.577*sigma_y);
    
    if(t_bend>t_shear)
        t_end = t_bend;
        msg = "End-cap thickness is driven by bending stress.\n";
    else
        t_end = t_shear;
        msg = "End-cap thickness is driven by shear stress.\n";
    end
    log_entry = [log_entry; msg];
    log_entry = [log_entry; strcat("End-cap wall thickness = ", string(t_end*100), " cm.\n")];
    
    pen_fastner_length = 1000*t_end/2; %mm, depth of holes for penetrator fastners
    
   %% O-ring calcs
        log_entry = [log_entry; strcat("\n--- O-rings ---\n")];
        
 %Set of points from o-ring pressure vs. clearance selectio chart
 pc_chart = [   0.003 10000;
                0.004 6000;
                0.007 4000;
                0.01 3000;
                0.016 2100;
                0.024 1100;
                0.028 600;
                0.03 400];% inches and psi
            
 CR = 0.3; %typical compressino ratio of O-ring
            
 p =  q_*0.000145038; %pressure in psi
 clearance = pc_interpolate(p, pc_chart); %interpolate clearance value to use (mm)
 
 log_entry = [log_entry; strcat("O-ring clearance for operational pressure = ", string(clearance), " mm.\n")];
 log_entry = [log_entry; strcat("O-ring cross-section diameter = ", string(oring_width), " mm.\n")];
 
 
 %calcualte important dimensions for CAD
 groove_depth = (oring_width)*(1-CR) - clearance; %mm, groove depth that O-ring sits in, based on literature in Analysis report
 %groove_depth = oring_width - clearance %mm, groove depth that O-ring sits in
 groove_width = (0.25*pi*oring_width^2)/(0.75*groove_depth); %mm, width of groove based on literature in Analysis report
 groove_depth = groove_depth/1000; %meter
 groove_width = groove_width/1000; %meter
 mid_grooveOUT = 0.5*((holes_patt_dia - holes_dia)+(2*b))/2; %m, midpoint radius of groove is in middle of wall,
        %halfway between fastners and inner diameter
        
 endcap_smallOD = 2*b-2*clearance/1000; %m, inner diamater of end-cap
 oringIN_ID = endcap_smallOD-2*groove_depth; %inner diameter of o-ring
 
 
    %DO LOG FOR O RINGS?
    
    %% Nuts & bolts 
   %Add code to size nuts and blots here
   log_entry = [log_entry; strcat("\n--- Nuts & bolts ---\n")];
   
   nut_length = round((t_end + flange_thick + extra)*1000)/1000;
   nut_dia = holes_dia; %m, nut diameter
   head_thick = 7/1000; %m, hex head thickness
   head_width = 5/1000; %m, max width on each side of nut OD
   
   bolt_thick = 7/1000; %m, bolt thickness
   bolt_width = 5/1000; %m, max width on each side of hole
   
   log_entry = [log_entry; strcat("Nuts used = ", string(nut_dia*1000), "M.\n")];
   
   %% Part equation files
   
   %Pressure vessel
   eqn = strcat("""inner_length"" = ", string(L*1000));
   eqn = [eqn; strcat("""inner_radius"" = ", string(b*1000))];
   eqn =[eqn; strcat("""wall_thickness"" = ", string(t_w*1000))];
   eqn =[eqn; strcat("""flange_OD"" = ", string(flange_OD*1000))];
   eqn =[eqn; strcat("""flange_thickness"" = ", string(flange_thick*1000))];
   eqn =[eqn; strcat("""N_holes"" = ", string(N_holes))];
   eqn =[eqn; strcat("""hole_diameter"" = ", string(holes_dia*1000))];
   eqn =[eqn; strcat("""holes_pattern_diameter"" = ", string(holes_patt_dia*1000))];
   eqn =[eqn; strcat("""bottom_thickness"" = ", string(t_end*1000))];
   % O RING RELATED DIMENSIONS
   eqn =[eqn; strcat("""groove_midpoint"" = ", string(mid_grooveOUT*1000))];
   eqn =[eqn; strcat("""groove_width"" = ", string(groove_width*1000))];
   eqn =[eqn; strcat("""groove_depth"" = ", string(groove_depth*1000))];
   
   pv_housing_file = "PV_Housing.txt"; %name of txt file
   Write_to_txt(eqn, pv_housing_file, "Pressure_Vessel"); %Write dimensions to txt file
   
   
   %End-cap
   eqn = strcat("""endcap_thickness"" = ", string(t_end*1000));
   eqn =[eqn; strcat("""endcap_depth"" = ", string(endcap_depth*1000))];
   eqn =[eqn; strcat("""endcap_inner_thickness"" = ", string(endcap_inner_thick*1000))];
   eqn =[eqn; strcat("""flange_OD"" = ", string(flange_OD*1000))];
   eqn =[eqn; strcat("""N_holes"" = ", string(N_holes))];
   eqn =[eqn; strcat("""hole_diameter"" = ", string(holes_dia*1000))];
   eqn =[eqn; strcat("""holes_pattern_diameter"" = ", string(holes_patt_dia*1000))];
   eqn =[eqn; strcat("""endcap_smallOD"" = ", string(endcap_smallOD*1000))];
   eqn =[eqn; strcat("""groove_depth"" = ", string(groove_depth*1000))];
   eqn =[eqn; strcat("""groove_width"" = ", string(groove_width*1000))];
   eqn =[eqn; strcat("""penetrators_layout_diameter"" = ", string(pen_layout_dia))];
   eqn =[eqn; strcat("""penetrator_diameter"" = ", string(pen_dia))];
   eqn =[eqn; strcat("""penetrator_fastners_diameter"" = ", string(pen_fastners_dia))];
   eqn =[eqn; strcat("""penetrator_fastner_hole_diameter"" = ", string(pen_fastner_hole_dia))];
   
   
   Write_to_txt(eqn, "PV_Endcap.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   
   
   
   
   %% penetrator dimensions
   eqn = strcat("""penetrator_diameter"" = ", string(pen_dia));
   eqn =[eqn; strcat("""penetrator_fastners_diameter"" = ", string(pen_fastners_dia))];
   eqn =[eqn; strcat("""penetrator_fastner_hole_diameter"" = ", string(pen_fastner_hole_dia))];
   eqn =[eqn; strcat("""penetrator_fastner_length"" = ", string(pen_fastner_length))];
   
   Write_to_txt(eqn, "PV_PenetratorFastener.txt", "Pressure_Vessel"); %Write dimensions to txt file
   Write_to_txt(eqn, "PV_Penetrator.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   
   
   
   
   %Nuts & bolts
   eqn = strcat("""nut_length"" = ", string(nut_length*1000));
   eqn =[eqn; strcat("""nut_diameter"" = ", string(nut_dia*1000))];
   eqn =[eqn; strcat("""head_thickness"" = ", string(head_thick*1000))];
   eqn =[eqn; strcat("""head_width"" = ", string(head_width*1000))];
   
   Write_to_txt(eqn, "PV_Nut.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   eqn = strcat("""bolt_thickness"" = ", string(bolt_thick*1000));
   eqn =[eqn; strcat("""bolt_width"" = ", string(bolt_width*1000))];
   eqn =[eqn; strcat("""hole_diameter"" = ", string(nut_dia*1000))];
   
   Write_to_txt(eqn, "PV_Bolt.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   %O-rings
   eqn = strcat("""oring_midpoint"" = ", string(mid_grooveOUT*1000));
   eqn =[eqn; strcat("""oringOUT_w"" = ", string(oring_width))];
   Write_to_txt(eqn, "PV_OringOUT.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   
   eqn = strcat("""oringIN_ID"" = ", string(oringIN_ID*1000));
   eqn =[eqn; strcat("""oringIN_w"" = ", string(oring_width))];
   Write_to_txt(eqn, "PV_OringIN.txt", "Pressure_Vessel"); %Write dimensions to txt file
   
   %% Append PV log strings to log file
   log_entry = [log_entry; "**************************************\n"]
   Append_to_log(log_entry);
    
end

function clearance = pc_interpolate(p, pc_chart)

[n,~] = size(pc_chart);
 
for i = 1:(n-1)
    
    if( pc_chart(i,2)>p && pc_chart(i+1,2)<p ) %situate point to interpolate
       x1 =  pc_chart(i,2); %pressure 1
       y1 =  pc_chart(i,1); %clearance 1
       x2 = pc_chart(i+1,2); %pressure 2
       y2 =  pc_chart(i+1,1); %clearance 
       x = p;
       break;
    end
end

%linear interpolation

clearance = y1 + (x-x1)*(y2-y1)/(x2-x1); %inches

clearance = clearance*25.4; %to mm

end