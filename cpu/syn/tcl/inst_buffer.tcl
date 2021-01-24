# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		inst_buffer
set FILE_LIST	[list \
	${DESIGN}.v \
	ib_il_ctrl.v \
	ib_reg_ctrl.v \
	ib_reg.v \
	ring_buf_mRnW.v \
	shifter.v \
	cnt_bits.v \
	selector.v \
]

set HARDMACRO [list \
	TSMC_ib_104x32 \
	TSMC_ib_84x32 \
	TSMC_ib_104x16 \
	TSMC_ib_84x16 \
	TSMC_ib_104x8 \
	TSMC_ib_82x8 \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
