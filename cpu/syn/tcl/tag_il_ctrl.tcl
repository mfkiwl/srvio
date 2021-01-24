# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		tag_il_ctrl
set FILE_LIST	[concat \
	${DESIGN}.v \
	cnt_bits.v \
	block_shift.v \
	selector.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
