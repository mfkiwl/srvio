#!/bin/tcsh

# Files and Directories Settings
set TOPDIR = `pwd`"/../.."
set COMMONDIR = "${TOPDIR}/common"
set CPUDIR = "${TOPDIR}/cpu"

# CPU
set CORERTLDIR = "${TOPDIR}/cpu/core"
set CACHERTLDIR = "${TOPDIR}/cpu/cache"
set CPUTESTDIR = "${CPUDIR}/test"
set CPUTESTDIR = "${CPUDIR}/test"
set CPUTBDIR = "${CPUTESTDIR}/tb"
set CPUWRAPPERDIR = "${CPUTESTDIR}/wrapper"
set CPUTESTINCDIR = "${CPUTESTDIR}/include"
set CPUGATEDIR = "${CPUDIR}/syn/result"
set CPU_SV2VDIR="${CPUDIR}/sv2v"
set CPU_SV2VRTLDIR = "${CPU_SV2VDIR}/rtl"
set CPU_SV2VTESTDIR = "${CPU_SV2VDIR}/test"

# Parameterized Modules
set PMDIR = "${TOPDIR}/pm"
set PMRTLDIR = "${PMDIR}/rtl"
set PM_SV2VDIR = "${PMDIR}/sv2v"
set PM_SV2VRTLDIR = "${PM_SV2VDIR}/rtl"

# Include
set INCDIR = ( \
	${COMMONDIR}/ \
	${CPUDIR}/include \
	${CPUTESTINCDIR} \
)
set DEFINE_LIST = ( \
	SIMULATION \
	INIT_INST_ROM=\\\"${CPUTESTDIR}/main.prg\\\" \
)

# Caution
#	If you use vivado, current directory is ./xilinx/${design}.
#	But other tools (xmverilog or vcs) use . as current directory.
#	So, file path should be written in absolute path, instead of relative.
