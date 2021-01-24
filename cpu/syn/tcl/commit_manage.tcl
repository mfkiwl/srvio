# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		commit_manage
set FILE_LIST	[list \
	${DESIGN}.v \
	commit_select.v \
	exp_manage.v \
	reorder_buffer.v \
	rob_status.v \
	rob_il_ctrl.v \
	rob_buf.v \
	ib_reg_ctrl.v \
	flush_manage.v \
	com_ctrl_reg.v \
	selector.v \
	cnt_bits.v \
	shifter.v \
	ring_buf_mRnW.v \
]

set HARDMACRO	[list \
	TSMC_rob_93x8 \
	TSMC_rob_93x16 \
]

set MAX_FANOUT	8

source -echo -verbose $TCL_DIR/common.tcl

quit
