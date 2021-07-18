/*
* <fetch_dec_is_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "sim.vh"

module fetch_dec_is_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter DATA = `DataWidth;
	parameter INST = `InstWidth;
	parameter L1_CACHE = `L1_ICacheSize;
	parameter PRED_MAX = `PredMaxDepth;
	parameter BP_DEPTH = `PredTableDepth;
	parameter BrPredType_t PREDICTOR = `PredType;
	parameter BTB_DEPTH = `BtbDepth;
	parameter RA_DEPTH = `RaStackDepth;
	parameter IQ_DEPTH = `IqDepth;
	parameter ROB_DEPTH = `RobDepth;

	//***** simulation signals
	reg				clk;
	reg				reset_;

	//***** simulation interfaces
	PcInstIf #(
		.ADDR		( ADDR ),
		.INST		( INST ),
		.ROB_DEPTH	( ROB_DEPTH )
	) pc_inst_if();

	IsExeIf #(
		.DATA		( DATA ),
		.ROB_DEPTH	( ROB_DEPTH )
	) is_exe_if();



	//***** DUT
	fetch_dec_is #(
		.ADDR		( ADDR ),
		.DATA		( DATA ),
		.INST		( INST ),
		.PRED_MAX	( PRED_MAX ),
		.BP_DEPTH	( BP_DEPTH ),
		.PREDICTOR	( PREDICTOR ),
		.BTB_DEPTH	( BTB_DEPTH ),
		.RA_DEPTH	( RA_DEPTH ),
		.ROB_DEPTH	( ROB_DEPTH )
	) fetch_dec_is (
		.clk		( clk ),
		.reset_		( reset_ ),
		.pc_inst_if	( pc_inst_if ),
		.is_exe_if	( is_exe_if )
	);

`ifdef VERILATOR
`else
	always #(STEP/2) begin
		clk <= ~clk;
	end

	always @( posedge clk ) begin
		if ( fetch_dec_is.decode_top.inst_e_ == `Enable_ ) begin
			`SetCharCyanBold
			$display("[Decoded Instruction]");
			`ResetCharSetting
			$display("    fetch pc: %8x", fetch_dec_is.decode_top.inst_pc);
			$display("    fetch inst: %8x", fetch_dec_is.decode_top.decoder.inst);
			$display("    inst name: %s", fetch_dec_is.decode_top.decoder.inst_name);
		end
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		pc_inst_if.initialize_fetch;
		is_exe_if.initialize_issue;

		#(STEP);
		reset_ = `Disable_;
		#(STEP*10);
		$finish;
	end

`endif
endmodule
