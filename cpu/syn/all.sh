#!/bin/tcsh

###########################################
########  Synthesis and Formality  ########
###########################################

# design name
#set DESIGN_NAME = decoder
#set DESIGN_NAME = pred_cnt
#set DESIGN_NAME = btb
#set DESIGN_NAME = br_pred_unit
#set DESIGN_NAME = ib_reg
#set DESIGN_NAME = inst_buffer
#set DESIGN_NAME = issue_select
#set DESIGN_NAME = free_tag
#set DESIGN_NAME = tag_il_ctrl
#set DESIGN_NAME = dist_tag 
#set DESIGN_NAME = dst_assign
#set DESIGN_NAME = reg_map_table
#set DESIGN_NAME = reg_map_manage
set DESIGN_NAME = commit_manage
#set DESIGN_NAME = rs_buf
#set DESIGN_NAME = int_sl_queue
#set DESIGN_NAME = issue_manage
#set DESIGN_NAME = rs_iq
#set DESIGN_NAME = rs_int_sl

# target flow
set TARGET = "ASIC"
#set TARGET = "FPGA_SYNP"
#set TARGET = "FPGA_VIVADO"

if ($TARGET =~ "ASIC") then
	# directory name
	set TCL_DIR	= "tcl"
	set LOG_DIR = "log"
	set REPORT_DIR = "report"
	set RESULT_DIR = "result"

	# library translation
	set LIB2DB = "true"

	# synthesis
	#set SYN_TOOL = dc_shell
	set SYN_TOOL = genus

	# formal verification
	#set FM_TOOL = fm_shell
	set FM_TOOL = conformal
	
	# directory setup
	mkdir -p ${TCL_DIR}
	mkdir -p ${LOG_DIR}
	mkdir -p ${RESULT_DIR}
	mkdir -p ${REPORT_DIR}
	mkdir -p ${RESULT_DIR}/${DESIGN_NAME}
	mkdir -p ${REPORT_DIR}/${DESIGN_NAME}

	# run
	if ( $LIB2DB =~ true ) then
		./lib2db.sh $DESIGN_NAME
	endif
	./syn.sh $DESIGN_NAME $SYN_TOOL
	./fm.sh $DESIGN_NAME $FM_TOOL
else if ($TARGET =~ "FPGA_SYNP") then
	# directory name
	set TCL_DIR	= "synp_tcl"
	set LOG_DIR = "synp_log"
	set REPORT_DIR = "synp_report"
	set RESULT_DIR = "synp_result"
	
	# directory setup
	mkdir -p ${TCL_DIR}
	mkdir -p ${LOG_DIR}
	mkdir -p ${RESULT_DIR}
	mkdir -p ${REPORT_DIR}
	mkdir -p ${RESULT_DIR}/${DESIGN_NAME}
	mkdir -p ${REPORT_DIR}/${DESIGN_NAME}

	# run
	./synp.sh $DESIGN_NAME
else if ($TARGET =~ "FPGA_VIVADO") then
	# directory name
	set TCL_DIR	= "tcl/vivado"
	set LOG_DIR = "log"
	set PRJ_DIR = "vivado_prj"
	
	# directory setup
	mkdir -p ${TCL_DIR}
	mkdir -p ${LOG_DIR}
	mkdir -p ${PRJ_DIR}

	# run
	./vivado.sh $DESIGN_NAME
endif

