#!/bin/tcsh

switch ( $TOP_MODULE )
	case "cpu_pipeline" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/fetch_top.sv \
				${CPURTLDIR}/decode_top.sv \
				${CPURTLDIR}/decoder.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
			)
		endif
	breaksw

	case "decode_top" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/decoder.sv \
			)
		endif
	breaksw

	case "fetch_top"
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPURTLDIR}/${TOP_MODULE}.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/rename_map.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/rename.sv \
				${CPURTLDIR}/rename_map.sv \
				${CPURTLDIR}/rob_status.sv \
				${CPURTLDIR}/exp_manage.sv \
				${CPURTLDIR}/pc_buf.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/issue_select.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/inst_sched.sv \
				${CPURTLDIR}/issue_select.sv \
				${PMRTLDIR}/freelist.sv \
				${PMRTLDIR}/selector.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/regfile.sv \
			)
		endif
	breaksw

	case "alu_top" :
		set TEST_FILE = "${CPUTBDIR}/${TOP_MODULE}_test.sv"
		if ( $GATE =~ 1 ) then
			set RTL_FILE = ( \
				$RTL_FILE \
				${GATEDIR}/${TOP_MODULE}/${TOP_MODULE}.mapped.v \
			)
		else
			set RTL_FILE = ( \
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/alu_ctrl.sv \
				${CPURTLDIR}/alu_exe.sv \
				${CPURTLDIR}/alu_br_comp.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/br_status_buf.sv \
				${CPURTLDIR}/br_rob_id_buf.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${PMRTLDIR}/cnt_bits.sv \
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
				${CPURTLDIR}/${TOP_MODULE}.sv \
				${CPURTLDIR}/br_status.sv \
				${CPURTLDIR}/br_status_buf.sv \
				${CPURTLDIR}/br_rob_id_buf.sv \
				${CPURTLDIR}/btb.sv \
				${CPURTLDIR}/br_predictor.sv \
				${CPURTLDIR}/br_pred_cnt.sv \
				${CPURTLDIR}/ra_stack.sv \
				${PMRTLDIR}/cnt_bits.sv \
				${PMRTLDIR}/pri_enc.sv \
				${PMRTLDIR}/regfile.sv \
				${PMRTLDIR}/stack.sv \
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
