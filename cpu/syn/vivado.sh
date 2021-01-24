#!/bin/tcsh

############################################
#####              Vivado              #####
############################################

# design name
set DESIGN_NAME = commit_manage

# constant parameter
if ( $#argv == 0 ) then
else
	set DESIGN_NAME = $1
endif

# directory name
set TCL_DIR	= "tcl/vivado"
set LOG_DIR = "log"
set PRJ_DIR = "vivado_prj"

vivado -mode batch -source ${TCL_DIR}/${DESIGN_NAME}.tcl | tee ${LOG_DIR}/${DESIGN_NAME}.log
