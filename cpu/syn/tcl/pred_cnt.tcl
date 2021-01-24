# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		pred_cnt
set FILE_LIST	[concat ${DESIGN}.v fifo_mRnW.v cnt_bits.v]

source -echo -verbose $TCL_DIR/common.tcl

quit
