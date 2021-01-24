# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		dist_tag
set FILE_LIST	[concat \
	${DESIGN}.v \
	pri_enc.v \
	free_tag.v \
	retire_free_tag.v \
	tag_il_ctrl.v \
	cnt_bits.v \
	block_shift.v \
	selector.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
