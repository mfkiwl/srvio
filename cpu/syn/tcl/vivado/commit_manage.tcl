# name settings
set TCL_DIR		tcl/vivado
set PRJ_DIR		vivado_prj

set DESIGN		commit_manage
set TOPDIR ../..
set FILE_LIST	[list \
	${TOPDIR}/cpu/rtl/frontend/${DESIGN}.v \
	${TOPDIR}/cpu/rtl/frontend/commit_select.v \
	${TOPDIR}/cpu/rtl/frontend/exp_manage.v \
	${TOPDIR}/cpu/rtl/frontend/reorder_buffer.v \
	${TOPDIR}/cpu/rtl/frontend/rob_status.v \
	${TOPDIR}/cpu/rtl/frontend/rob_il_ctrl.v \
	${TOPDIR}/cpu/rtl/frontend/rob_buf.v \
	${TOPDIR}/cpu/rtl/frontend/ib_reg_ctrl.v \
	${TOPDIR}/cpu/rtl/frontend/flush_manage.v \
	${TOPDIR}/cpu/rtl/frontend/com_ctrl_reg.v \
	${TOPDIR}/pm/rtl/selector.v \
	${TOPDIR}/pm/rtl/cnt_bits.v \
	${TOPDIR}/pm/rtl/shifter.v \
	${TOPDIR}/pm/rtl/ring_buf_mRnW.v \
]

set VIVADO_IP [list \
]

source -verbose $TCL_DIR/common.tcl

quit
