# script configuration
set ip_dir		[exec pwd]
set prj_name	managed_ip_project
set ip_prj		${ip_dir}/${prj_name}
set tcl_dir		${ip_dir}/tcl
source ${tcl_dir}/config.tcl

# ip option
set ip_name		"some ip name"
set ip_version	"ip_version"
set module_name "module name"

# ip property
set ip_property [list \
	CONFIG.Component_Name ${module_name} \
	#... (followed by list of ip configurations)
]

# source ip generation template
source ${tcl_dir}/create_ip.tcl
