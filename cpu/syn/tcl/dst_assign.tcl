# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		dst_assign
set FILE_LIST	[concat \
	${DESIGN}.v \
	reg_type_check.v \
	dist_tag.v \
	tag_il_ctrl.v \
	free_tag.v \
	pri_enc.v \
	cnt_bits.v \
	block_shift.v \
	selector.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
