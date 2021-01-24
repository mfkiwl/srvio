# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		reg_map_table
set FILE_LIST	[concat \
	${DESIGN}.v \
	regfile_mRnW.v \
	wr_sel.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
