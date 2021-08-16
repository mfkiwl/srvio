# script configuration
set ip_dir		[exec pwd]
set prj_name	managed_ip_project
set ip_prj		${ip_dir}/${prj_name}
set tcl_dir		${ip_dir}/tcl
source ${tcl_dir}/config.tcl

# ip option
set ip_name		div_gen
set ip_version	5.1
set div_width	64
set div_latency	8
set module_name div${div_width}_l${div_latency}

# ip property
# See cpu/core/div_xilinx.sv for detail
#	dividened_tuser_width	: 1 bit (= sign bit)
# 	divisor_tuser_width		: 4 bit (= sign bit + DivOp_t)
set ip_property [list \
	CONFIG.Component_Name ${module_name} \
	CONFIG.algorithm_type {Radix2} \
	CONFIG.dividend_and_quotient_width ${div_width} \
	CONFIG.divisor_width ${div_width} \
	CONFIG.dividend_has_tuser {true} \
	CONFIG.dividend_tuser_width {1} \
	CONFIG.divisor_has_tuser {true} \
	CONFIG.divisor_tuser_width {4} \
	CONFIG.operand_sign {Unsigned} \
	CONFIG.clocks_per_division {1} \
	CONFIG.divide_by_zero_detect {true} \
	CONFIG.latency_configuration {Manual} \
	CONFIG.ACLKEN {true} \
	CONFIG.ARESETN {true} \
	CONFIG.remainder_type {Remainder} \
	CONFIG.fractional_width ${div_width} \
	CONFIG.latency ${div_latency}\
]

# source ip generation template
source ${tcl_dir}/create_ip.tcl
