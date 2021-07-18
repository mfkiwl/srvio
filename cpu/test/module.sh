#!/bin/tcsh

switch ( $TOP_MODULE )
	##### Top Level module
	case "cpu_pipeline" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/fetch_top.sv \
				${CORERTLDIR}/decode_top.sv \
				${CORERTLDIR}/decoder.sv \
			)
		endif
	breaksw

	##### Semi-Top Level
	case "fetch_dec" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPUWRAPPERDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/fetch_top.sv \
				${CORERTLDIR}/fetch_ctrl.sv \
				${CORERTLDIR}/fetch_iag.sv \
				${CORERTLDIR}/br_status.sv \
				${CORERTLDIR}/br_status_buf.sv \
				${CORERTLDIR}/br_rob_id_buf.sv \
				${CORERTLDIR}/btb.sv \
				${CORERTLDIR}/br_predictor.sv \
				${CORERTLDIR}/br_pred_cnt.sv \
				${CORERTLDIR}/ra_stack.sv \
				${CORERTLDIR}/decode_top.sv \
				${CORERTLDIR}/decode_ctrl.sv \
				${CORERTLDIR}/decoder.sv \
				${CACHERTLDIR}/inst_rom.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/stack.sv \
			)
		endif
	breaksw

	case "fetch_dec_is" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPUWRAPPERDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/fetch_top.sv \
				${CORERTLDIR}/fetch_ctrl.sv \
				${CORERTLDIR}/fetch_iag.sv \
				${CORERTLDIR}/br_status.sv \
				${CORERTLDIR}/br_status_buf.sv \
				${CORERTLDIR}/br_rob_id_buf.sv \
				${CORERTLDIR}/btb.sv \
				${CORERTLDIR}/br_predictor.sv \
				${CORERTLDIR}/br_pred_cnt.sv \
				${CORERTLDIR}/ra_stack.sv \
				\
				${CORERTLDIR}/decode_top.sv \
				${CORERTLDIR}/decode_ctrl.sv \
				${CORERTLDIR}/decoder.sv \
				\
				${CORERTLDIR}/issue_top.sv \
				${CORERTLDIR}/inst_queue.sv \
				${CORERTLDIR}/inst_sched.sv \
				${CORERTLDIR}/issue_select.sv \
				${CORERTLDIR}/operand_mux.sv \
				${CORERTLDIR}/reorder_buffer.sv \
				${CORERTLDIR}/rename.sv \
				${CORERTLDIR}/rename_map.sv \
				${CORERTLDIR}/rob_status.sv \
				${CORERTLDIR}/exp_manage.sv \
				${CORERTLDIR}/pc_buf.sv \
				${CORERTLDIR}/cpu_regfiles.sv \
				${CACHERTLDIR}/inst_rom.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/stack.sv \
				${PMRTLDIR}/freelist.sv \
				${PMRTLDIR}/selector.sv \
				${PMRTLDIR}/ring_buf.sv \
			)
		endif
	breaksw

	##### Fetch Stage modules
	case "fetch_top"
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/fetch_ctrl.sv \
				${CORERTLDIR}/fetch_iag.sv \
				${CORERTLDIR}/br_status.sv \
				${CORERTLDIR}/br_status_buf.sv \
				${CORERTLDIR}/br_rob_id_buf.sv \
				${CORERTLDIR}/btb.sv \
				${CORERTLDIR}/br_predictor.sv \
				${CORERTLDIR}/br_pred_cnt.sv \
				${CORERTLDIR}/ra_stack.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/stack.sv \
			)
		endif
	breaksw

	case "fetch_ctrl"
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "fetch_iag" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/br_status.sv \
				${CORERTLDIR}/br_status_buf.sv \
				${CORERTLDIR}/br_rob_id_buf.sv \
				${CORERTLDIR}/btb.sv \
				${CORERTLDIR}/br_predictor.sv \
				${CORERTLDIR}/br_pred_cnt.sv \
				${CORERTLDIR}/ra_stack.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/stack.sv \
			)
		endif
	breaksw

	case "btb" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "br_status" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/br_status_buf.sv \
				${CORERTLDIR}/br_rob_id_buf.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
			)
		endif
	breaksw

	case "br_status_buf" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${PMRTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw



	##### Decode Stage modules
	case "decode_top" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/decoder.sv \
			)
		endif
	breaksw

	case "decoder" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw



	##### Issue/Commit Stage modules
	case "issue_top" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/inst_queue.sv \
				${CORERTLDIR}/inst_sched.sv \
				${CORERTLDIR}/issue_select.sv \
				\
				${CORERTLDIR}/operand_mux.sv \
				\
				${CORERTLDIR}/reorder_buffer.sv \
				${CORERTLDIR}/rename.sv \
				${CORERTLDIR}/rename_map.sv \
				${CORERTLDIR}/rob_status.sv \
				${CORERTLDIR}/exp_manage.sv \
				${CORERTLDIR}/pc_buf.sv \
				\
				${CORERTLDIR}/cpu_regfiles.sv \
				\
				${PMRTLDIR}/freelist.sv \
				${PMRTLDIR}/selector.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/ring_buf.sv \
			)
		endif
	breaksw

	case "rename" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/rename_map.sv \
			)
		endif
	breaksw

	case "rob_status" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${PMRTLDIR}/ring_buf.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "exp_manage" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "reorder_buffer" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/rename.sv \
				${CORERTLDIR}/rename_map.sv \
				${CORERTLDIR}/rob_status.sv \
				${CORERTLDIR}/exp_manage.sv \
				${CORERTLDIR}/pc_buf.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/ring_buf.sv \
				${PMRTLDIR}/cnt_bits.sv \
			)
		endif
	breaksw

	case "inst_sched" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/issue_select.sv \
				${PMRTLDIR}/selector.sv \
			)
		endif
	breaksw

	case "inst_queue" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/inst_sched.sv \
				${CORERTLDIR}/issue_select.sv \
				${PMRTLDIR}/freelist.sv \
				${PMRTLDIR}/selector.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/regfile.sv \
			)
		endif
	breaksw



	##### Exe Stage modules
	case "alu_top" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CORERTLDIR}/${TOP_MODULE}.sv \
				${CORERTLDIR}/alu_ctrl.sv \
				${CORERTLDIR}/alu_exe.sv \
				${CORERTLDIR}/alu_br_comp.sv \
			)
		endif
	breaksw



	##### Cache
	case "ic_ram_block" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CACHERTLDIR}/${TOP_MODULE}.sv \
				${PMRTLDIR}/ram.sv \
			)
		endif
	breaksw

	default : 
		# Error
		echo "Invalid Module"
		exit 1
	breaksw
endsw

if ( $SV2V =~ 1 ) then
	pushd $SV2VDIR
	./clean.sh
	./convert.sh $TOP_MODULE
	popd

	# Test vector
	set TEST_FILE = "${SV2VTESTDIR}/${TOP_MODULE}_test.v"

	# DUT
	set new_path = ()
	foreach file ( $RTL_FILE )
		set vfilename = `basename $file:r.v`
		set new_path = ( \
			$new_path \
			${SV2VRTLDIR}/${vfilename} \
		)
	end
	set RTL_FILE = ( $new_path )
endif
