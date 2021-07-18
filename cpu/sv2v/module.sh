#!/bin/tcsh

switch ( $TOP_MODULE )
	case "cpu_pipeline" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/fetch_top.sv \
			${COREDIR}/decode_top.sv \
			${COREDIR}/decoder.sv \
		)
	breaksw

	case "btb" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "decode_top" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/decoder.sv \
		)
	breaksw

	case "fetch_top"
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "decoder" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "rename" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/rename_map.sv \
		)
	breaksw

	case "rob_status" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${PMSV2VDIR}/ring_buf.sv \
			${PMSV2VDIR}/regfile.sv \
			${PMSV2VDIR}/cnt_bits.sv \
		)
	breaksw

	case "exp_manage" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
		)
	breaksw

	case "reorder_buffer" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/rename.sv \
			${COREDIR}/rename_map.sv \
			${COREDIR}/rob_status.sv \
			${COREDIR}/exp_manage.sv \
			${COREDIR}/pc_buf.sv \
			${PMSV2VDIR}/regfile.sv \
			${PMSV2VDIR}/ring_buf.sv \
			${PMSV2VDIR}/cnt_bits.sv \
		)
	breaksw

	case "inst_sched" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/issue_select.sv \
			${PMSV2VDIR}/selector.sv \
		)
	breaksw

	case "inst_queue" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/inst_sched.sv \
			${COREDIR}/issue_select.sv \
			${PMSV2VDIR}/freelist.sv \
			${PMSV2VDIR}/selector.sv \
			${PMSV2VDIR}/cnt_bits.sv \
			${PMSV2VDIR}/regfile.sv \
		)
	breaksw

	case "alu_top" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/alu_ctrl.sv \
			${COREDIR}/alu_exe.sv \
			${COREDIR}/alu_br_comp.sv \
		)
	breaksw

	case "br_status" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/br_status_buf.sv \
			${COREDIR}/br_rob_id_buf.sv \
			${PMSV2VDIR}/cnt_bits.sv \
			${PMSV2VDIR}/pri_enc.sv \
			${PMSV2VDIR}/regfile.sv \
		)
	breaksw

	case "br_status_buf" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${PMSV2VDIR}/cnt_bits.sv \
		)
	breaksw

	case "fetch_iag" :
		set RTL_FILE = ( \
			${COREDIR}/${TOP_MODULE}.sv \
			${COREDIR}/br_status.sv \
			${COREDIR}/br_status_buf.sv \
			${COREDIR}/br_rob_id_buf.sv \
			${COREDIR}/btb.sv \
			${COREDIR}/br_predictor.sv \
			${COREDIR}/br_pred_cnt.sv \
			${COREDIR}/ra_stack.sv \
			${PMSV2VDIR}/cnt_bits.sv \
			${PMSV2VDIR}/pri_enc.sv \
			${PMSV2VDIR}/regfile.sv \
			${PMSV2VDIR}/stack.sv \
		)
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw
