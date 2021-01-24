# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		rs_buf
set FILE_LIST	[list \
	${DESIGN}.v \
	freelist_mRnW.v \
	wr_sel.v \
	selector.v \
	cnt_bits.v \
]

set HARDMACRO	[list ]

source -echo -verbose $TCL_DIR/common.tcl

quit
