#!/bin/tcsh

###########################################
########  Synthesis and Formality  ########
###########################################

# design name
set DESIGN_NAME = reorder_buffer


# constant parameter
set TCL_DIR	= "tcl"
set LOG_DIR = "log"
set REPORT_DIR = "report"
set RESULT_DIR = "result"

# tool settings
#set SYN_TOOL = dc_shell
set SYN_TOOL = genus

#set FM_TOOL = fm_shell
#set FM_TOOL = conformal (Not Implemented)

mkdir -p ${LOG_DIR}
mkdir -p ${RESULT_DIR}
mkdir -p ${REPORT_DIR}
mkdir -p ${RESULT_DIR}/${DESIGN_NAME}

mkdir -p ${REPORT_DIR}/${DESIGN_NAME}

./syn.sh $DESIGN_NAME $SYN_TOOL
#./fm.sh $DESIGN_NAME $FM_TOOL
