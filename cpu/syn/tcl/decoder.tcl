# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		decoder
set FILE_LIST	[concat ${DESIGN}.v dec_validate.v rv_dec.v]

source -echo -verbose $TCL_DIR/common.tcl

quit
