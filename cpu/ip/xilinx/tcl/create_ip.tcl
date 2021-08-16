# basic files
set ip_xpr ${ip_prj}/${prj_name}.xpr
set ip_xci ${ip_dir}/${module_name}/${module_name}.xci

# setup project
if { [file exists ${ip_prj}] } {
	# If ip project already exists, open existing one
	puts ${ip_xpr}
	open_project ${ip_xpr}
} else {
	# If ip project does not exists, newly create one
	create_project managed_ip_project ${ip_prj} -part ${part_id} -ip
}
set_property simulator_language Verilog [current_project]
set_property target_simulator XSim [current_project]

# setup ip generation
create_ip \
	-vendor xilinx.com \
	-name ${ip_name} \
	-version ${ip_version} \
	-module_name ${module_name} \
	-library ip \
	-dir ${ip_dir}

# setup ip property
set_property -dict ${ip_property} [get_ips ${module_name}]

# generate ip
generate_target {instantiation_template} [get_files ${ip_xci}]
generate_target all [get_files ${ip_xci}]
catch { config_ip_cache -export [get_ips -all ${module_name}] }
export_ip_user_files -of_objects [get_files ${ip_xci}] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_xci}]

# synthesis ip and generate simulation netlist (verilog)
launch_runs ${module_name}_synth_1 -jobs ${num_cpu}

# wait synthesis to complete
wait_on_run ${module_name}_synth_1
