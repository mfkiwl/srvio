set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		issue_select
set FILE_LIST	[concat ${DESIGN}.v]

set DESIGN_NO_CLK 1
source -echo -verbose $TCL_DIR/common.tcl

quit
