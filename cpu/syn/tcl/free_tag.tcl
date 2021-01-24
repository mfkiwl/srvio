# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		free_tag
set FILE_LIST	[concat ${DESIGN}.v pri_enc.v]

source -echo -verbose $TCL_DIR/common.tcl

quit
