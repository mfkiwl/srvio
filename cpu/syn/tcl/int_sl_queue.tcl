# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		int_sl_queue
set FILE_LIST	[list \
	${DESIGN}.v \
	wb_reg_check.v \
	rs_inst_buf.v \
	rs_buf.v \
	cnt_bits.v \
	wr_sel.v \
	freelist_mRnW.v \
	selector.v \
]

set HARDMACRO	[list ]

source -echo -verbose $TCL_DIR/common.tcl

quit
