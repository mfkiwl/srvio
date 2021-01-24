# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		br_pred_unit
set FILE_LIST	[concat \
	${DESIGN}.v \
	br_pred_ctrl.v \
	br_predictor.v \
	pred_cnt.v \
	ra_stack.v \
	btb.v \
	selector.v \
	deselector.v \
	expand_bits.v \
	shrink_bits.v \
	fifo_mRnW.v \
	cnt_bits.v \
	stack_mRnW.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
