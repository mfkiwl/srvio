# tool settings
set MAX_CORE	8

# search path settings
set TOPDIR ../..
set search_path [concat \
	. \
	${TOPDIR}/common/ \
	${TOPDIR}/pm/rtl \
	${TOPDIR}/cpu/rtl/top \
	${TOPDIR}/cpu/rtl/frontend \
	${TOPDIR}/cpu/rtl/backend \
	${TOPDIR}/cpu/rtl/cache \
	${TOPDIR}/cpu/rtl/regs \
	${TOPDIR}/cpu/include \
	${TOPDIR}/cpu/syn/db \
]

### set Process for synthesis
set PROCESS "TSMC130"
#set PROCESS "TSMC65"
#set PROCESS "NANGATE45"
#set PROCESS "ASAP7"

# tool chain
set synopsys_tools [info exist synopsys_program_name]

if { $PROCESS == "TSMC130" } {
	# Use low-vt memory macro
	set LVT 0

	if { $LVT == 1 } {
		# low vt
		# filesttings settings ( for TSMC130 )
		set search_path [concat \
			$search_path \
			${TOPDIR}/cpu/lib/tsmc130.lvt/syn_lib \
		]
		set CELLDIR "/cad/TSMC/digital/Front_End/timing_power"
		set target_cell [list \
			$CELLDIR/tcb013lvhp_211a/tcb013lvhptc \
			$CELLDIR/tcb013lvhphvt_211a/tcb013lvhphvttc \
		]
	} else {
		# typical
		# filesttings settings ( for TSMC130 )
		set search_path [concat \
			$search_path \
			${TOPDIR}/cpu/lib/tsmc130/syn_lib \
		]
		set CELLDIR "/cad/TSMC/digital/Front_End/timing_power"
		set target_cell [list \
			$CELLDIR/tcb013lvhp_211a/tcb013lvhptc \
			$CELLDIR/tcb013lvhphvt_211a/tcb013lvhphvttc \
		]
	}

	# memory macro settings
	set target_library [list]
	if {[info exists HARDMACRO]} {
		if { $synopsys_tools } {
			foreach macro $HARDMACRO {
				set target_library [concat \
					$target_library \
					${DB_DIR}/${macro}_typical_syn.db \
					${DB_DIR}/${macro}_fast@0C_syn.db \
					${DB_DIR}/${macro}_fast@-40C_syn.db \
					${DB_DIR}/${macro}_slow_syn.db \
				]
			}
		} else {
			foreach macro $HARDMACRO {
				set target_library [concat \
					$target_library \
					${macro}_typical_syn.lib \
					${macro}_fast@0C_syn.lib \
					${macro}_fast@-40C_syn.lib \
					${macro}_slow_syn.lib \
				]
			}
		}
	}

} elseif { $PROCESS == "TSMC65" } {
	# library settings ( for TSMC65 ) 
	set search_path [concat \
	   $search_path \
	   ${TOPDIR}/cpu/lib/tsmc65/syn_lib \
	]
	
	set CELLDIR "/usr/users/ide/hard/tsmc65_lib/TSMCHOME/digital/Front_End/timing_power"
	set target_cell [list \
		${CELLDIR}/tcbn65lplvt_100a/tcbn65lplvttc \
		${CELLDIR}/tcbn65lp_120a/tcbn65lptc \
		${CELLDIR}/tcbn65lphvt_100a/tcbn65lphvttc \
	]

	# memory macro settings
	set target_library [list]
	if {[info exists HARDMACRO]} {
		if { $synopsys_tools } {
			foreach macro $HARDMACRO {
				set target_library [concat \
					$target_library \
					${DB_DIR}/${macro}_nldm_ff_1p10v_1p10v_0c_syn.db \
					${DB_DIR}/${macro}_nldm_ff_1p10v_1p10v_125c_syn.db \
					${DB_DIR}/${macro}_nldm_ff_1p10v_1p10v_m40c_syn.db \
					${DB_DIR}/${macro}_nldm_ss_0p90v_0p90v_125c_syn.db \
					${DB_DIR}/${macro}_nldm_ss_0p90v_0p90v_m40c_syn.db \
					${DB_DIR}/${macro}_nldm_tt_1p00v_1p00v_25c_syn.db \
				]
			}
		} else {
			foreach macro $HARDMACRO {
				set target_library [concat \
					$target_library \
					${macro}_nldm_ff_1p10v_1p10v_0c_syn.lib \
					${macro}_nldm_ff_1p10v_1p10v_125c_syn.lib \
					${macro}_nldm_ss_0p90v_0p90v_125c_syn.lib \
					${macro}_nldm_ff_1p10v_1p10v_m40c_syn.lib \
					${macro}_nldm_ss_0p90v_0p90v_m40c_syn.lib \
					${macro}_nldm_tt_1p00v_1p00v_25c_syn.lib \
				]
			}
		}
	}
} elseif { $PROCESS == "NANGATE45" } {
	# library setting ( for NANGATE45" )
	# Caution : Design must be standard-cell only
	set search_path [concat \
	   $search_path \
	]

	# no memory macro is allowed
	set target_library [list]

	if { $synopsys_tools } {
		set CELLDIR "/cad/NANGATE45/lib/db"
		set target_cell [list \
			${CELLDIR}/NangateOpenCellLibrary_typical_conditional \
		]
	} else {
		set CELLDIR "/cad/NANGATE45/lib/liberty"
		set target_cell [list \
			${CELLDIR}/NangateOpenCellLibrary__typical_conditional_nldm \
		]
		#${CELLDIR}/NangateOpenCellLibrary__typical_conditional_ecsm
		#${CELLDIR}/NangateOpenCellLibrary__typical_conditional_ccs
	}
} elseif { $PROCESS == "ASAP7" } {
	# library setting ( for ASAP 7nm Open PDK )
	# Caution : Design must be standard-cell only
	set search_path [concat \
	   $search_path \
	]

	# not memory macro is allowed
	set target_library [list]

	if { $synopsys_tools } {
		set CELLDIR "/usr/users/ide/hard/asap7_lib/lib/DB"
		set target_cell [list \
			${CELLDIR}/hogehoge \
		]
		echo "DB must be created before synthesis"
		exit 1
	} else {
		set CELLDIR "/usr/users/ide/hard/asap7_lib/lib/LIB/NLDM"

		# use only typical corner
		set target_cell [list \
			${CELLDIR}/asap7sc7p5t_SIMPLE_SRAM_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SIMPLE_SLVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SIMPLE_RVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SIMPLE_LVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SEQ_SRAM_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SEQ_SLVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SEQ_RVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_SEQ_LVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_OA_SRAM_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_OA_SLVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_OA_RVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_OA_LVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_INVBUF_SRAM_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_INVBUF_SLVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_INVBUF_RVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_INVBUF_LVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_AO_SRAM_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_AO_SLVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_AO_RVT_TT_08302018 \
			${CELLDIR}/asap7sc7p5t_AO_LVT_TT_08302018 \
		]
	}
}


if { $synopsys_tools } {
	##### Synopsys Tool chain #####
	# processor count
	set_host_option -max_cores ${MAX_CORE}

	# Set search path as application variable
	set search_path [concat \
		$search_path \
	]
	set_app_var search_path $search_path

	# add library extention
	foreach lib_each $target_cell {
		lappend target_library  ${lib_each}.db
	}

	if { $synopsys_program_name == "dc_shell" } {
		# verification file setting
		set_svf ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.svf


		# library for synthesis
		set DW_LIB ${synopsys_root}/libraries/syn/dw_foundation.sldb
		set_app_var synthetic_library ${DW_LIB}
		set_app_var link_library [concat $target_library $DW_LIB]


		# read verilog file
		analyze -format verilog ${FILE_LIST}
		elaborate ${DESIGN}


		# synthesis option and compile
		source -echo -verbose ${TCL_DIR}/clk_const.tcl
		check_design > ${REPORT_DIR}/${DESIGN}/check_design.rpt
		compile_ultra


		# reports
		report_area -nosplit > ${REPORT_DIR}/${DESIGN}/report_area.rpt
		report_power -nosplit > ${REPORT_DIR}/${DESIGN}/report_power.rpt
		report_timing -max_paths 10 -nosplit > ${REPORT_DIR}/${DESIGN}/report_timing.rpt
		report_constraint > ${REPORT_DIR}/${DESIGN}/report_constraint.rpt


		# output result
		write -hierarchy -format ddc -output ${RESULT_DIR}/${DESIGN}/${DESIGN}.ddc
		write -hierarchy -format verilog -output ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.v

	} elseif { $synopsys_program_name == "fm_shell" } {
		# verification file setting
		set_svf ${RESULT_DIR}/${DESIGN}/${DESIGN}.mapped.svf

		# library for formal verification
		#set_app_var hdlin_dwroot /cad/synopsys/syn/O-2018.06-SP3
		set dc_shell_path [exec which dc_shell | cut -d "/" -f 1-5]
		set_app_var hdlin_dwroot $dc_shell_path
		read_db -technology_library ${target_library}


		# load reference
		read_verilog -r ${FILE_LIST} -work_library WORK
		set_top r:/WORK/${DESIGN}


		# load implementation
		read_ddc -i ${RESULT_DIR}/${DESIGN}/${DESIGN}.ddc
		set_top i:/WORK/${DESIGN}


		# matching reference and implementation
		match


		# output result
		if { ![verify] } {  
			report_unmatched_points > ${REPORT_DIR}/${DESIGN}/fmv_unmatched_points.rpt
			report_failing_points > ${REPORT_DIR}/${DESIGN}/fmv_failing_points.rpt
			report_aborted > ${REPORT_DIR}/${DESIGN}/${DESIGN}fmv_aborted_points.rpt
			analyze_points -failing > ${REPORT_DIR}/${DESIGN}/fmv_failing_analysis.rpt
			report_svf_operation [find_svf_operation -status rejected]
		} 
	} elseif { $synopsys_program_name == "lc_shell" } {
		if {[info exists HARDMACRO]} {
			set LIBNAME "USERLIB"
			if { $PROCESS == "TSMC130" } {
				foreach macro $HARDMACRO {
					# library of each corner
					set lib_typ			${macro}_typical_syn
					set lib_fast0C		${macro}_fast@0C_syn
					set lib_fast-40C	${macro}_fast@-40C_syn
					set lib_slow		${macro}_slow_syn

					# db generation
					if { ![ file exists ${DB_DIR}/${lib_typ}.db ] } {
						# typical corner
						read_lib ${lib_typ}.lib
						write_lib ${LIBNAME} -output ${DB_DIR}/${lib_typ}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_fast0C}.db ] } {
						# fast @ 0 degree corner
						read_lib ${lib_fast0C}.lib
						write_lib ${LIBNAME} -output ${DB_DIR}/${lib_fast0C}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_fast-40C}.db ] } {
						# fast @ -40 degree corner
						read_lib ${lib_fast-40C}.lib
						write_lib ${LIBNAME} -output ${DB_DIR}/${lib_fast-40C}.db
						remove_lib ${LIBNAME}
					}


					if { ![ file exists ${DB_DIR}/${lib_slow}.db ] } {
						# slow corner
						read_lib ${lib_slow}.lib
						write_lib ${LIBNAME} -output ${DB_DIR}/${lib_slow}.db
						remove_lib ${LIBNAME}
					}
				}
			} elseif { $PROCESS == "TSMC65" } {
				foreach macro $HARDMACRO {
					# library of each corner
					set lib_1p10v_0c	${macro}_nldm_ff_1p10v_1p10v_0c_syn
					set lib_1p10v_125c	${macro}_nldm_ff_1p10v_1p10v_125c_syn
					set lib_1p10v_m40c	${macro}_nldm_ff_1p10v_1p10v_m40c_syn
					set lib_0p90v_125c	${macro}_nldm_ss_0p90v_0p90v_125c_syn
					set lib_0p90v_m40c	${macro}_nldm_ss_0p90v_0p90v_m40c_syn
					set lib_1p00v_25c	${macro}_nldm_tt_1p00v_1p00v_25c_syn

					# db generation
					if { ![ file exists ${DB_DIR}/${lib_1p10v_0c}.db ] } {
						read_lib ${lib_1p10v_0c}.lib
						write_lib ${LIBNAME}_nldm_ff_1p10v_1p10v_0c \
							-output ${DB_DIR}/${lib_1p10v_0c}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_1p10v_125c}.db ] } {
						read_lib ${lib_1p10v_125c}.lib
						write_lib ${LIBNAME}_nldm_ff_1p10v_1p10v_125c \
							-output ${DB_DIR}/${lib_1p10v_125c}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_1p10v_m40c}.db ] } {
						read_lib ${lib_1p10v_m40c}.lib
						write_lib ${LIBNAME}_nldm_ff_1p10v_1p10v_m40c \
							-output ${DB_DIR}/${lib_1p10v_m40c}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_0p90v_125c}.db ] } {
						read_lib ${lib_0p90v_125c}.lib
						write_lib ${LIBNAME}_nldm_ss_0p90v_0p90v_125c \
							-output ${DB_DIR}/${lib_0p90v_125c}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_0p90v_m40c}.db ] } {
						read_lib ${lib_0p90v_m40c}.lib
						write_lib ${LIBNAME}_nldm_ss_0p90v_0p90v_m40c \
							-output ${DB_DIR}/${lib_0p90v_m40c}.db
						remove_lib ${LIBNAME}
					}

					if { ![ file exists ${DB_DIR}/${lib_1p00v_25c}.db ] } {
						read_lib ${lib_1p00v_25c}.lib
						write_lib ${LIBNAME}_nldm_tt_1p00v_1p00v_25c \
							-output ${DB_DIR}/${lib_1p00v_25c}.db
						remove_lib ${LIBNAME}
					}
				}
			}
		}
	}
} else {
	##### Cadence Tool chain #####

	# target design
	set design ${DESIGN}

	# add library extention
	set stdcell_lib	[list]
	foreach lib_each $target_cell {
		lappend stdcell_lib ${lib_each}.lib
	}
	set target_library [concat $target_library $stdcell_lib]

	# path/library settings
	set_db / .lib_search_path $search_path
	set_db / .library $target_library

	# read hdl
	set_db / .init_hdl_search_path $search_path
	read_hdl ${FILE_LIST}
	elaborate

	# timing constraints
	source -echo -verbose ${TCL_DIR}/clk_const.tcl

	# timing optimization
	# did not work well
	#set_db retime_async_reset true
	#set_db retime_optimize_reset true
	#retime -prepare
	#retime -min_delay

	# synthesis
	check_design > ${REPORT_DIR}/${DESIGN}/check_design.rpt
	syn_generic
	syn_map
	syn_opt

	# output result
	write_hdl -generic ${DESIGN} > ${RESULT_DIR}/${DESIGN}.generic_gate.v
	write_hdl -lec ${DESIGN} > ${RESULT_DIR}/${DESIGN}.mapped.v

	# report
	report_area > ${REPORT_DIR}/${DESIGN}/report_area.rpt
	report_power > ${REPORT_DIR}/${DESIGN}/report_power.rpt
	report_timing > ${REPORT_DIR}/${DESIGN}/report_timing.rpt
}
