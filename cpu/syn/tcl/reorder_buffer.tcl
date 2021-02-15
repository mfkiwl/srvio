# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set TCL_DIR		tcl

set DESIGN		reorder_buffer
#set FILE_LIST	[concat \
#]
set SV_FILE_LIST [concat \
	${DESIGN}.sv \
	rename.sv \
	rename_map.sv \
	rob_status.sv \
	exp_manage.sv \
	regfile.sv \
	ring_buf.sv \
	cnt_bits.sv \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
