% Calculates the geometry of the pump impeller for the Suction Pump (SP) assembly
% Writes dimensions to part txt files
% sp_flw_rt = suction pump flowrate required to intake the total amount of
% fluid volume diplaced by the closing of the clamshells in m^3/s
% sp_head = suction pump head required for the system in m^2/s^2
% depth = operational depth of the device in meters
% D_sm = Pipe diameter connecting to pump in meters 
function Suction_Pump_Imp(sp_flw_rt, sp_head, depth, D_sm,pipe_thickness)
%% Initial Setup
    D_s = 1000*D_sm; %mm
%Set parameters
    sp_rot_spd_rpm = 3600; %rpm - pump shaft rotational speed
    sp_rot_spd = sp_rot_spd_rpm/9.5492965964254; %rad/s
    rho_w = 1028; %kg/m3, density of seawater
    %for piping
    flg_ex = 50; %Pipe flange extension from pipe inner diameter in mm
    flg_tk = 15; %Pipe flange thicknesses based on pipe size in mm
    N_flg_holes = 8; %Number of bolt holes in pipe flange
    flg_hole_dia = 15; %Diameter of bolt holes in pipe flange in mm
    gasket_thickness = 2; %mm, pipe gasket thickness
    
%Conversion of pump flow and head to imperial units (units the formulas are in)
sp_flw_rt_gpm = sp_flw_rt*15850.32; %gpm
sp_head_ft = 3.281*sp_head*rho_w/(1000*9.804139432); %ft

%Pump Safety Factor
sp_sf = 1.1; %Applied once to the flowrate when calculating specific speed

%Calculate the spcific speed required for the pump
N_s = sp_rot_spd_rpm*(sp_sf*sp_flw_rt_gpm)^0.5/(sp_head_ft^0.75);

%Initialize log entry string array
log_entry = "******** Suction Pump Design ********\n"; 
%print operational properties of the pump
log_entry = [log_entry; strcat("\n--- Pump Operational Properties ---\n")]; 
log_entry = [log_entry; strcat("Pump flowrate required: ", string(sp_flw_rt_gpm), " gpm \n")];
log_entry = [log_entry; strcat("Pump head required: ", string(sp_head_ft), " ft \n")];
log_entry = [log_entry; strcat("Pump impeller rotational speed: ", string(sp_rot_spd_rpm), " rpm \n")];
log_entry = [log_entry; strcat("Pump specific speed: ", string(N_s), " \n")];

%Calculate constants based on provide graphs in the report
%Note that equations were derived by fitting trendlines and find equation of that trendline
%Pump head constant
    K_u = 8E-05*N_s+0.9312;
%Capacity constant
    K_m2 = 0.0005*N_s^0.7382;
%Impeller radius ratio
    imp_rr = 9E-05*N_s+0.3705;
%Volute velocity constant
    K_3 = 3E-08*N_s^2-0.0002*N_s+0.6409;

log_entry = [log_entry; strcat("\n--- Graph Parameters ---\n")]; 
log_entry = [log_entry; strcat("Head Constant: ", string(K_u), " \n")];
log_entry = [log_entry; strcat("Capacity Constant: ", string(K_m2), " \n")];
log_entry = [log_entry; strcat("Impeller Radius Ratio: ", string(imp_rr), " \n")];
log_entry = [log_entry; strcat("Volute Velocity Constant: ", string(K_3), " \n")];
    
    %% Pump Impeller Dimensions
%Set some standard values for pump impeller design
Z = 6; %Number of vanes on impeller
b_u_in = 0.25; %impeller blade width in inches
b_u = b_u_in*25.4; %impeller blade width in mm

%Calculate impeller outer radius
r_2_in = (1840/2)*K_u*sp_head_ft^0.5/sp_rot_spd_rpm; %in
r_2 = r_2_in*25.4; %mm

%Calculate radial discharge velocity
V_2N_ft_s = K_m2*(2*32.1741*sp_head_ft)^0.5; %ft/s
V_2N = V_2N_ft_s/3.281; %m/s

%Calculate impeller blade width
b_i_in = 0.321*sp_flw_rt_gpm/(V_2N_ft_s*(2*r_2_in*pi-Z*b_u_in)); %in
b_i = b_i_in*25.4; %mm

%Calculate inner radius
r_1 = imp_rr*r_2; %mm

%Calculate inlet vane angle that results in purely radial flow
beta_1 = atand(sp_flw_rt/(2*pi*(r_1/1000)^2*(b_i/1000)*sp_rot_spd));

%Set initial parameters for efficiency optimization
beta_2 = 10; %degrees
T_pump = 10000; %N.m

%set for loop to vary discharge angle and find best pump efficiency
%Best efficency = angle requiring minimum amount of input torque 
for beta_2_test = 15:0.1:33 %varies diacharge angle between 15 and 33 degress (typical min/max values for centrigugal pumps)
    %Calculate required torque to spin pump
    T_pump_test = rho_w*sp_flw_rt*(sp_rot_spd*(r_2/1000)^2-sp_flw_rt/(2*pi*(b_i/1000)*tand(beta_2_test)));
    
    if (T_pump_test < T_pump)
        T_pump = T_pump_test;
        beta_2 = beta_2_test;
    end
end

%Calculate pump hydraulic power
P_hyd = sp_head*sp_flw_rt*rho_w; %W

%Calculate pump shaft power
P_shaft = T_pump*sp_rot_spd; %W

%Calculate pump efficiency
eta_hyd = (P_hyd/P_shaft)*100; %Percent

%print calculated impeller design paramters
log_entry = [log_entry; strcat("\n--- Impeller Design Properties ---\n")];
log_entry = [log_entry; strcat("Impeller blade width: ", string(b_u), " mm \n")];
log_entry = [log_entry; strcat("Number of vanes on impeller: ", string(Z), " \n")];
log_entry = [log_entry; strcat("Vane inlet angle: ", string(beta_1), " deg \n")];
log_entry = [log_entry; strcat("Vane discharge angle: ", string(beta_2), " deg \n")];
log_entry = [log_entry; strcat("Impeller outer radius: ", string(r_2), " mm \n")];
log_entry = [log_entry; strcat("Impeller inner radius: ", string(r_1), " mm \n")];
log_entry = [log_entry; strcat("Impeller width: ", string(b_i), " mm \n")];

%print calculated pump powers and efficiency
log_entry = [log_entry; strcat("\n--- Pump Power Requirements and Efficency ---\n")];
log_entry = [log_entry; strcat("Pump hydraulic power: ", string(P_hyd), " W \n")];
log_entry = [log_entry; strcat("Required torque: ", string(T_pump), " N.m \n")];
log_entry = [log_entry; strcat("Pump shaft power: ", string(P_shaft), " W \n")];
log_entry = [log_entry; strcat("Pump efficency: ", string(eta_hyd), " % \n")];

%% Pump shaft
log_entry = [log_entry; strcat("\n--- Pump Shaft Design ---\n")];
SF = 1.5; %Safety factor used for shaft

%material properties: 316 Stainless Steel
sigma_y = 240e6; %Pa, yield stress

%geometric proprties
shaft_length = 0.5; %meters
shaft_length =1000*shaft_length; %mm
d_min = 15; % mm, minimum shaft diameter allowed

%Compute required pump shaft diameter based on torque
%Formula derived in Analysis report Eqn. 3.118
%based on Von Mises and max torque shear stress
d_ps = ((768*T_pump^2*SF^2)/(sigma_y^2*pi^2))^(1/6); %meters, pump shaft diameter
d_ps = 1000*d_ps; %mm

log_entry = [log_entry; strcat("Shaft diameter calculated (SF = ", string(SF), "):", string(d_ps), " mm.")];

if (d_ps < d_min)
    d_ps = d_min; %replace minimum diameter if smaller
    log_entry = [log_entry; strcat("Shaft diameter smaller than established minimum! Replaced with d_min = ", string(d_ps), " mm.")];
end

%Slot for key, based on diameter. Equations based on Analysis Report B.6
%Appendix
w_key = d_ps/4; %mm, key width
h_key = 0.75*w_key; %mm, key height

    %% Pump Volute Dimensions
%Set parameters
pump_wall_tk = 5; %Sets pump wall thickness in mm
base_hole_dia = 20; %Sets hole diameter for base of pump to fasten to frame

%Calculate volute inner width
%Ratio between volute width and impeller width changes based on specific speed
    if (N_s < 1000)
        b_vi = 2.0*b_i; %mm
    elseif(1000 <= N_s <= 3000)
        b_vi = 1.75*b_i; %mm
    else
        b_vi = 1.6*b_i; %mm
    end

%Calculate cutwater radius
%Ratio between cutwater radius and impeller outer radius changes based on specific speed
    if(N_s < 1000)
        r_3 = 1.05*r_2; %mm
    elseif(1000 <= N_s < 1500)
        r_3 = 1.06*r_2; %mm
    elseif(1500 <= N_s < 2500)
        r_3 = 1.07*r_2; %mm
    else
        r_3 = 1.09*r_2; %mm
    end
    
%Calculate volute exit area (i.e. largest volute cross-sectional area)
A_v_in = 0.04*sp_flw_rt_gpm/(K_3*sp_head_ft^0.5); %in^2
A_v = A_v_in*645.16; %Coneversion to mm^2
%Calculate volute exit diameter
d_ve = sqrt(4*A_v/pi); %mm
    
%Calculate volute spiral pitch
vol_s_r = r_3 + b_vi/2; %volute spiral start radius in mm
vol_f_r = r_3 + (d_ve/2); %volute spiral end radius in mm
vol_rev = 7/8; %chosen volute spiral revolution 
vol_pitch = (vol_f_r-vol_s_r)/vol_rev; %volute spriral pitch

%Calculate volute outer width (i.e. inner volute + casing thickness)
b_vo = d_ve+2*pump_wall_tk; %mm

%Calculate hole depth for volute back plate to screw into
hd_vbp = 0.8*b_vi; %mm

%Stuffing box size to seal pump - based off of shaft and impeller size
stf_rad = 1.5*(d_ps/2 + h_key*2); %mm
stf_h_dia = 8; %mm -> set to a constant value

%Calculate distance from center of shaft to pump base
d_bs = vol_pitch*(5/8) + vol_s_r + b_vo/2; %mm

%Calculate volute base width
vol_bw = vol_f_r + vol_pitch*(3/8) + vol_s_r + b_vo + flg_ex*2; %mm

%Calculate shaft horizontal offset from center of pump
sft_os = (vol_f_r + vol_pitch*(3/8) + vol_s_r)/2 - (vol_pitch*(3/8) + vol_s_r); %mm

%print calculated volute design paramters
log_entry = [log_entry; strcat("\n--- Volute Design Properties ---\n")];
log_entry = [log_entry; strcat("Volute inner width: ", string(b_vi), " mm \n")];
log_entry = [log_entry; strcat("Volute outer width: ", string(b_vo), " mm \n")];
log_entry = [log_entry; strcat("Cutwater radius: ", string(r_3), " mm \n")];
log_entry = [log_entry; strcat("Volute exit area: ", string(A_v), " mm^2 \n")];
log_entry = [log_entry; strcat("Volute exit diameter: ", string(d_ve), " mm \n")];
log_entry = [log_entry; strcat("Volute revolution: ", string(vol_rev), "  \n")];
log_entry = [log_entry; strcat("Volute spiral pitch: ", string(vol_pitch), " mm \n")];
log_entry = [log_entry; strcat("Pump minimum wall thickness: ", string(pump_wall_tk), " mm \n")];

%% Bearing O-Rings
oring_width = 5;% mm, set a value for o-ring width
oringIN_ID = (d_ps/2+2*h_key)*2*0.97; %mm, o-ring inner diameter based on shaft diameter with typical 3% stretch factor 

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
            
CR = 0.3; %typical compression ratio of O-ring
            
p_depth = rho_w*depth*9.81*0.000145038; %pressure in psi
clearance = pc_interpolate(p_depth, pc_chart); %interpolate clearance value to use (mm)

%Calculate o-ring groove depth based on compression ratio and clearance
groove_depth = oring_width*(1-CR)- clearance; %mm
%Calculate o-ring width required given groove depth and typical 75% groove cross-sectional area fill 
groove_width = (0.25*pi*oring_width^2)/(0.75*groove_depth); %mm

log_entry = [log_entry; strcat("O-ring clearance for operational pressure: ", string(clearance), " mm\n")];
log_entry = [log_entry; strcat("O-ring cross-section diameter: ", string(oring_width), " mm \n")];
log_entry = [log_entry; strcat("O-ring inner diameter: ", string(oringIN_ID), " mm \n")];
log_entry = [log_entry; strcat("O-ring groove depth: ", string(groove_depth), " mm \n")];
log_entry = [log_entry; strcat("O-ring groove width: ", string(groove_width), " mm \n")];

%% Write Dimensions to Part File
% Suction Pump all parts
    eqn = eqn_txt("imp_outer_rad", r_2); %set strings for SolidWorks
    eqn = [eqn; eqn_txt("imp_inner_rad", r_1)];
    eqn = [eqn; eqn_txt("sp_shaft_dia", d_ps)];
    eqn = [eqn; eqn_txt("cutwater_rad", r_3)];
    eqn = [eqn; eqn_txt("volute_width", b_vi)];
    eqn = [eqn; eqn_txt("volute_pitch", vol_pitch)];
    eqn = [eqn; eqn_txt("volute_rev", vol_rev)];
    eqn = [eqn; eqn_txt("vol_outer_width", b_vo)];
    eqn = [eqn; eqn_txt("pipe_dia", D_s)];
    eqn = [eqn; eqn_txt("flange_extension", flg_ex)];
    eqn = [eqn; eqn_txt("flange_thickness", flg_tk)];
    eqn = [eqn; eqn_txt("N_holes", N_flg_holes)];
    eqn = [eqn; eqn_txt("hole_dia", flg_hole_dia)];
    eqn = [eqn; eqn_txt("hole_depth", hd_vbp)];
    eqn = [eqn; eqn_txt("base_hole_dia", base_hole_dia)];
    eqn = [eqn; eqn_txt("imp_width", b_i)];
    eqn = [eqn; eqn_txt("stuff_box_rad", stf_rad)];
    eqn = [eqn; eqn_txt("stuff_hole_dia", stf_h_dia)];
    eqn = [eqn; eqn_txt("sft_key_ht", h_key)];
    eqn = [eqn; eqn_txt("sft_key_wth", w_key)];
    eqn = [eqn; eqn_txt("o_ring_ID", oringIN_ID)];
    eqn = [eqn; eqn_txt("o_ring_dia", oring_width)];
    eqn = [eqn; eqn_txt("num_vanes", Z)];
    eqn = [eqn; eqn_txt("imp_dis_angle", beta_2)];
    eqn = [eqn; eqn_txt("vane_thick", b_u)];
    eqn = [eqn; eqn_txt("imp_inlet_angle", beta_1)];
    eqn = [eqn; eqn_txt("groove_depth", groove_depth)];
    eqn = [eqn; eqn_txt("groove_width", groove_width)];
    eqn = [eqn; eqn_txt("gasket_thickness", gasket_thickness)];
    eqn = [eqn; eqn_txt("d_sft_base", d_bs)];
    eqn = [eqn; eqn_txt("vol_base_width", vol_bw)];
    eqn = [eqn; eqn_txt("sft_offset", sft_os)];
    eqn = [eqn; eqn_txt("pipe_thickness", pipe_thickness)];
    
    
    Write_to_txt(eqn, "SP_Suction Pump_All.txt", "Suction Pump"); %Write dimensions to txt file

%Write to log
    Append_to_log(log_entry);
end

%used to create string for given variable name and value
function txt_line = eqn_txt(var_name, value)
%var_name is a string
%value is a number
txt_line = strcat("""", var_name, """ = ", string(value)); 
end

%Use to interpolate clearance required for the o-ring on the shaft
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