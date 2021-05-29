#!/bin/tcsh

# Files and Directories Settings
set TOPDIR = "../.."
set COMMONDIR = "${TOPDIR}/common"
set CPUDIR = "${TOPDIR}/cpu"
set CPURTLDIR = "${TOPDIR}/cpu/rtl"
set CPUTESTDIR = "${CPUDIR}/test"
set CPUTESTDIR = "${CPUDIR}/test"
set CPUTBDIR = "${CPUTESTDIR}/tb"
set CPUTESTINCDIR = "${CPUTESTDIR}/include"
set CPUGATEDIR = "${CPUDIR}/syn/result"
set CPU_SV2VDIR="${CPUDIR}/sv2v"
set CPU_SV2VRTLDIR = "${CPU_SV2VDIR}/rtl"
set CPU_SV2VTESTDIR = "${CPU_SV2VDIR}/test"
set PMDIR = "${TOPDIR}/pm"
set PMRTLDIR = "${PMDIR}/rtl"
set PM_SV2VDIR = "${PMDIR}/sv2v"
set PM_SV2VRTLDIR = "${PM_SV2VDIR}/rtl"
set INCDIR = ( \
	${COMMONDIR}/ \
	${CPUDIR}/include \
	${CPUTESTINCDIR} \
)
set DEFINE_LIST = ( \
	SIMULATION \
)
set INCLUDE = ()
set DEFINES = ()
set RTL_FILE = ()
