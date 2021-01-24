# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		rs_iq
set FILE_LIST	[list \
	${DESIGN}.v \
	rs_schedule.v \
	cnt_bits.v \
	pri_enc.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
