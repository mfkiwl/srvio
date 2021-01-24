# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		reg_map_manage
set FILE_LIST	[concat \
	${DESIGN}.v \
	reg_map_table.v \
	retire_map_table.v \
	front_map_reg.v \
	backend_map_reg.v \
	wr_sel.v \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
