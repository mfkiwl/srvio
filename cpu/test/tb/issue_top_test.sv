/*
* <issue_top_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exe.svh"
`include "decode.svh"
`include "exception.svh"
`include "regfile.svh"
`include "cpu_if.svh"

module issue_top_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter DATA = `DataWidth;
	parameter IQ_DEPTH = `IqDepth;
	parameter ROB_DEPTH = `RobDepth;
	localparam ROB = $clog2(ROB_DEPTH); 

	//***** signal generation
	logic				clk;
	logic				reset_;

	//***** interface instance
	DecIsIf				dec_is_if ();
	IsExeIf				is_exe_if ();
	PcInstIf			pc_inst_if ();

	//***** module instance
	issue_top #(
		.ADDR		( ADDR ),
		.DATA		( DATA ),
		.IQ_DEPTH	( IQ_DEPTH ),
		.ROB_DEPTH	( ROB_DEPTH )
	) issue_top (
		.*
	);



`ifdef VERILATOR
`else
	always #(STEP/2) begin
		clk = ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Disable_;
		dec_is_if.initialize_issue();
		is_exe_if.initialize_issue();
		pc_inst_if.initialize_issue();

		#(STEP);
		reset_ = `Enable_;

		#(STEP*5);
	end
`endif

endmodule
