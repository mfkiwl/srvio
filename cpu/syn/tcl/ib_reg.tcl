# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		ib_reg
set FILE_LIST	[list ${DESIGN}.v ib_reg_ctrl.v ring_buf_mRnW.v cnt_bits.v]

set HARDMACRO	[list TSMC_ib_104x32 TSMC_ib_84x32]

source -echo -verbose $TCL_DIR/common.tcl

quit
