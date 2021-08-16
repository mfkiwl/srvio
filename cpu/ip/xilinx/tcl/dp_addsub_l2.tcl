# script configuration
set ip_dir		[exec pwd]
set prj_name	managed_ip_project
set ip_prj		${ip_dir}/${prj_name}
set tcl_dir		${ip_dir}/tcl
source ${tcl_dir}/config.tcl

# ip option
set ip_name floating_point
set ip_version 7.1
set module_name dp_addsub_l2

# ip property
set ip_property [list \
	CONFIG.Component_Name ${module_name} \
	CONFIG.Operation_Type {Add_Subtract} \
	CONFIG.A_Precision_Type {Double} \
	CONFIG.Flow_Control {NonBlocking} \
	CONFIG.Maximum_Latency {false} \
	CONFIG.C_Latency {2} \
	CONFIG.Has_ACLKEN {true} \
	CONFIG.Has_ARESETn {true} \
	CONFIG.C_Has_UNDERFLOW {true} \
	CONFIG.C_Has_OVERFLOW {true} \
	CONFIG.C_Has_INVALID_OP {true} \
	CONFIG.Has_A_TLAST {false} \
	CONFIG.C_A_Exponent_Width {11} \
	CONFIG.C_A_Fraction_Width {53} \
	CONFIG.Result_Precision_Type {Double} \
	CONFIG.C_Result_Exponent_Width {11} \
	CONFIG.C_Result_Fraction_Width {53} \
	CONFIG.C_Accum_Msb {32} \
	CONFIG.C_Accum_Lsb {-31} \
	CONFIG.C_Accum_Input_Msb {32} \
	CONFIG.C_Mult_Usage {Full_Usage} \
	CONFIG.Has_RESULT_TREADY {false} \
	CONFIG.C_Rate {1} \
	CONFIG.RESULT_TLAST_Behv {Null} \
]

# source ip generation template
source ${tcl_dir}/create_ip.tcl
