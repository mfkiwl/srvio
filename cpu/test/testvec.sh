#!/bin/tcsh

#######################################
##### File and Directory Settings #####
#######################################
set TOPDIR = "../.."
set COMMONDIR = "${TOPDIR}/common"
set CPUDIR = "${TOPDIR}/cpu"
set CPURTLDIR = "${TOPDIR}/cpu/rtl"
set CPUTESTDIR = "${CPUDIR}/test"
set CPUGATEDIR = "${CPUDIR}/syn/result"
set PMDIR = "${TOPDIR}/pm"
set PMRTLDIR = "${PMDIR}/rtl"
set INCLUDE = ( \
	+incdir+${COMMONDIR}/ \
	+incdir+${CPUDIR}/include \
)

#############################################
# Output Wave
#############################################
set Waves = 1
set WaveOpt

#############################################
# Defines
#############################################
set DEFINES = ()

#############################################
#           Gate Level Simulation           #
#############################################
#set GATE = 1
set GATE = 0
if ( $GATE =~ 1 ) then
	set DEFINES = ($DEFINES +define+NETLIST)
endif

#############################################
#              Process Setting              #
#############################################
set Process = "ASAP7"
#set Process = "None"

switch ($Process)
	case "ASAP7" :
		set CELL_LIB = "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
		set CELL_RTL_DIR = "${CELL_LIB}/asap7_7p5t_library/rev25/Verilog"
		set DEFINES = (${DEFINES} +define+ASAP7)

		set RTL_FILE = ( \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_AO_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_INVBUF_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_OA_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SEQ_SRAM_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_RVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_LVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_SLVT_TT_08302018.v \
			-v $CELL_RTL_DIR/asap7sc7p5t_SIMPLE_SRAM_TT_08302018.v \
		)
	breaksw
	default :
		# Simulation with simple gate model (Process = "None")
		# Nothing to set
		set RTL_FILE = ()
	breaksw
endsw

########################################
#     Simulation Target Selection      #
########################################
set DEFAULT_DESIGN = "btb"
#set DEFAULT_DESIGN = "br_pred_cnt"

if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

switch ( $TOP_MODULE )
	case "btb" :
		set TEST_FILE = "${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPURTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw


########################################
#        Simulation Tool Setup         #
########################################
#set SIM_TOOL = "ncverilog"
set SIM_TOOL = "xmverilog"
#set SIM_TOOL = "vcs"
#set SIM_TOOL = "iverilog"

switch( $SIM_TOOL )
	case "ncverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+SimVision
		else
		endif

		set SIM_OPT = ( \
			+nc64bit \
			$WaveOpt \
			+access+r \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)
	breaksw

	case "xmverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+SimVision
		endif

		set SIM_OPT = ( \
			+64bit \
			$WaveOpt \
			+access+r \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)
	breaksw

	case "vcs" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+VCS
		endif

		set SIM_OPT = ( \
			-o ${TOP_MODULE}.sim \
			-full64 \
			$WaveOpt \
			+incdir+.include \
			-debug_access+r \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilogext+.sv \
			+verilog2001ext+.v \
		)
	breaksw

	case "iverilog" :
		set SIM_OPT = ()
		set SRC_EXT = ()
	breaksw

	default :
		echo "Simulation Tool is not selected"
		exit 1
	breaksw
endsw


##############################
#       run simulation       #
##############################
${SIM_TOOL} \
	${SIM_OPT} \
	${SRC_EXT} \
	+notimingchecks \
	-ALLOWREDEFINITION \
	${INCLUDE} \
	${DEFINES} \
	${TEST_FILE} \
	${RTL_FILE}
