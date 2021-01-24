# name settings
set REPORT_DIR	report
set RESULT_DIR	result
set DB_DIR		db
set TCL_DIR		tcl

set DESIGN		issue_manage
set FILE_LIST	[list \
	${DESIGN}.v \
	inst_buffer.v \
	ib_il_ctrl.v \
	ib_reg.v \
	ib_reg_ctrl.v \
	ib2ren_pipe.v \
	rename_manage.v \
	dst_assign.v \
	dist_tag.v \
	reg_type_check.v \
	tag_il_ctrl.v \
	free_tag.v \
	retire_free_tag.v \
	src_assign.v \
	reg_dep_check.v \
	ren_pipe.v \
	reg_map_manage.v \
	reg_map_table.v \
	front_map_reg.v \
	retire_map_table.v \
	backend_map_reg.v \
	issue_select.v \
	cnt_bits.v \
	shifter.v \
	selector.v \
	ring_buf_mRnW.v \
	pri_enc.v \
	wr_sel.v
]

set HARDMACRO	[list \
	TSMC_ib_107x32 \
	TSMC_ib_107x16 \
	TSMC_ib_107x8 \
	TSMC_ib_86x32 \
	TSMC_ib_86x16 \
	TSMC_ib_86x8 \
]

source -echo -verbose $TCL_DIR/common.tcl

quit
