#!/bin/tcsh

###########################################
###            db generation            ###
###########################################

if ( $#argv == 0 ) then
	# design name
	#set DESIGN_NAME = decoder
	#set DESIGN_NAME = pred_cnt
	#set DESIGN_NAME = ib_reg
	set DESIGN_NAME = inst_buffer
else
	set DESIGN_NAME = $1
endif

# constant parameter 
# constant parameter
set TCL_DIR	= "tcl"
set LOG_DIR = "log"
set DB_DIR = "db"
set REPORT_DIR = "report"
set RESULT_DIR = "result"

# tool settings
set TOOL = lc_shell

mkdir -p ${LOG_DIR}
mkdir -p ${DB_DIR}

$TOOL -f ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.lc.log
