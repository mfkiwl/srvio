#!/bin/tcsh

##### File, Directory and Define Settings #####
source config.sh
set INCLUDE = ()
set DEFINES = ()
set RTL_FILE = ()
set LIBS = ()



##### load configs
source sim_tool.sh
source target.sh



##### Output Wave
set Waves = 1
set WaveOpt



##### Simulation after Systemverilog to verilog (SV2V) Conversion
set SV2V = 0
if ( $SIM_TOOL =~ "iverilog" ) then
	# iverilog only supports verilog formats
	set SV2V = 1
endif



##### Defines
if ( $Waves =~ 1 ) then
	set DEFINE_LIST = ( $DEFINE_LIST WAVE_DUMP )
endif



##### Gate Level Simulation
set GATE = 0
#set GATE = 1
if ( $GATE =~ 1 ) then
	set DEFINE_LIST = ($DEFINE_LIST NETLIST)
endif



##### Process Setting
#set Process = "ASAP7"
set Process = "Xilinx"
#set Process = "None"

switch ($Process)
	case "ASAP7" :
		set CELL_LIB = "./ASAP7_PDKandLIB_v1p6/lib_release_191006"
		set CELL_RTL_DIR = "${CELL_LIB}/asap7_7p5t_library/rev25/Verilog"
		set DEFINE_LIST = (${DEFINE_LIST} ASAP7)

		set CORNERS = ( \
			TT_08302018 \
		)
		#	FF_08302018 \
		#	SS_08302018 \

		set CELL_NAME = ( \
			${CELL_RTL_DIR}/asap7sc7p5t_SIMPLE_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_SEQ_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_OA_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_INVBUF_RVT \
			${CELL_RTL_DIR}/asap7sc7p5t_AO_RVT \
		)

		# library files
		set LIB_FILE = ()
		foreach cell ( $CELL_NAME )
			foreach corner ( $CORNERS )
				set LIB_FILE = ( \
					${LIB_FILE} \
					${cell}_${corner}.v \
				)
			end
		end

		# directory containing library files
		set LIB_DIR = ()
	breaksw

	case "Xilinx" : 
		set VIVADO_TOP = `which vivado | sed "s/\/bin.*//"`
		set CELL_LIB = ${VIVADO_TOP}/data
		set XPM_DIR = ${CELL_LIB}/ip/xpm
		set CELL_RTL_DIR = ${CELL_LIB}/verilog/src


		# library files
		set LIB_FILE = ( \
			${XPM_DIR}/xpm_memory/hdl/xpm_memory.sv \
		)

		# directory containing library files
		set LIB_DIR = ( \
			${CELL_RTL_DIR}/unisims \
			${CELL_RTL_DIR}/retargets \
		)
	breaksw

	default :
		# Simulation with simple gate model (Process = "None")
		# Nothing to set
		set LIB_FILE = ()
		set LIB_DIR = ()
	breaksw
endsw

###### Simulation Target Selection
if ( $# =~ 0 ) then
	set TOP_MODULE = $DEFAULT_DESIGN
else
	set TOP_MODULE = $1
endif

source module.sh



##### Simulation Tool Setup
switch( $SIM_TOOL )
	case "ncverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+nc64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end
	breaksw

	case "xmverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+CADENCE
		endif

		set SIM_OPT = ( \
			+64bit \
			$WaveOpt \
			+access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilog_ext+.sv \
			+vlog_ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end

		foreach lib ( $LIB_FILE )
			set LIBS = ( \
				-v $lib \
				$LIBS \
			)
		end

		foreach lib ( $LIB_DIR )
			set LIBS = ( \
				-y $lib \
				$LIBS \
			)
		end
	breaksw

	case "vcs" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+SYNOPSYS
		endif

		set SIM_OPT = ( \
			-o ${TOP_MODULE}.sim \
			-full64 \
			$WaveOpt \
			+incdir+.include \
			-debug_access+r \
			+notimingchecks \
			-ALLOWREDEFINITION \
		)
		set SRC_EXT = ( \
			+xmc_ext+.c \
			+libext+.v.sv \
			+systemverilogext+.sv \
			+verilog2001ext+.v \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end

		foreach lib ( $LIB_FILE )
			set LIBS = ( \
				-v $lib \
				$LIBS \
			)
		end

		foreach lib ( $LIB_DIR )
			set LIBS = ( \
				-y $lib \
				$LIBS \
			)
		end
	breaksw

	case "verilator" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = +define+VCD
		endif

		set SIM_OPT = ( \
			-lint-only \
			$WaveOpt \
			+notimingchecks \
		)

		set SRC_EXT = ( \
			+libext+.v.sv \
			+systemverilogext+.sv \
		)

		set DEFINE_LIST = ( \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				+define+$def \
				$DEFINES \
			) 
		end
		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				+incdir+$dir \
				$INCLUDE \
			)
		end

		foreach lib ( $LIB_FILE )
			set LIBS = ( \
				-v $lib \
				$LIBS \
			)
		end

		foreach lib ( $LIB_DIR )
			set LIBS = ( \
				-y $lib \
				$LIBS \
			)
		end
	breaksw

	case "iverilog" :
		if ( $Waves =~ 1 ) then
			set WaveOpt = (-D VCD)
		endif

		set SIM_OPT = ( \
			$WaveOpt \
			-o ${TOP_MODULE}.sim \
		)

		set SRC_EXT = ()

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				-D $def \
				$DEFINES \
			)
		end

		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				-I $dir \
				$INCLUDE \
			)
		end

		foreach lib ( $LIB_FILE )
			set LIBS = ( \
				-l $lib \
				$LIBS \
			)
		end

		foreach lib ( $LIB_DIR )
			set LIBS = ( \
				-y $lib \
				$LIBS \
			)
		end
	breaksw

	case "xilinx_sim" :
		#if ( $Waves =~ 1 ) then
		#	set WaveOpt = (-d VCD)
		#endif
		# Output WDB instead

		set SIM_OPT = ( \
			$WaveOpt \
		)

		set SRC_EXT = ( \
		)

		foreach def ( $DEFINE_LIST )
			set DEFINES = ( \
				--define $def \
				$DEFINES \
			)
		end

		foreach dir ( $INCDIR )
			set INCLUDE = ( \
				--include $dir \
				$INCLUDE \
			)
		end

		foreach lib ( $LIB_FILE )
			set LIBS = ( \
				--sourcelibfile $lib \
				$LIBS \
			)
		end

		foreach lib ( $LIB_DIR )
			set LIBS = ( \
				--sourcelibfile $lib \
				$LIBS \
			)
		end
	breaksw

	default :
		echo "Simulation Tool is not selected"
		exit 1
	breaksw
endsw



##### run simulation
if ( ${SIM_TOOL} =~ "xilinx_sim" ) then
	mkdir -p xilinx/${TOP_MODULE}
	set FILE_TCL = "./xilinx/${TOP_MODULE}/files.tcl"
	set DEFINE_TCL = "./xilinx/${TOP_MODULE}/defines.tcl"

	### set design target
	echo "set TOP ${TOP_MODULE}" > "./xilinx/top.tcl"

	### generate tcl file to designate source flies
	# Waveform configuration
	echo "set WAVEFORM $Waves" > ${FILE_TCL}

	# Add Design RTL Files
	echo "set DESIGN_FILES [list \\" >> ${FILE_TCL}
	foreach files ( $RTL_FILE )
		echo "$files \\" >> ${FILE_TCL}
	end
	echo "]" >> ${FILE_TCL}

	# Add Test Files
	echo "set TEST_FILES [list \\" >> ${FILE_TCL}
	foreach files ( $TEST_FILE )
		echo "$files \\" >> ${FILE_TCL}
	end
	echo "]" >> ${FILE_TCL}

	# Add include directories
	echo "set INCLUDE_DIRS [list \\" >> ${FILE_TCL}
	foreach dirs ( $INCDIR )
		echo "$dirs \\" >> ${FILE_TCL}
	end
	echo "]" >> ${FILE_TCL}

	# Add define lists
	echo "set DEFINE_LISTS [list \\" > ${DEFINE_TCL}
	foreach dirs ( $DEFINE_LIST )
		echo "$dirs \\" >> ${DEFINE_TCL}
	end
	echo "]" >> ${DEFINE_TCL}

	# create vivado projects for debug
	vivado -mode batch -source ./xilinx/prj.tcl
else
	${SIM_TOOL} \
		${SIM_OPT} \
		${SRC_EXT} \
		${INCLUDE} \
		${DEFINES} \
		${TEST_FILE} \
		${RTL_FILE} \
		${LIBS}
endif
