/*
* <rename_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module rename_test;
	parameter STEP = 10;
	parameter ROB_DEPTH = `RobDepth;
	parameter ROB = $clog2(ROB_DEPTH);

	reg				clk;
	reg				reset_;

	reg				dec_e_;
	reg				dec_invalid;
	RegFile_t		dec_rd;
	RegFile_t		dec_rs1;
	RegFile_t		dec_rs2;
	reg [ROB-1:0]	dec_rob_id;
	RegFile_t		ren_rs1;
	RegFile_t		ren_rs2;
	RegFile_t		ren_rd;

	reg				commit_e_;
	reg [ROB-1:0]	com_rob_id;

	rename #(
		.ROB_DEPTH	( ROB_DEPTH )
	) rob_depth (
		.*
	);

`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;

		dec_e_ = `Disable_;
		dec_invalid = `Disable;
		dec_rd = 0;
		dec_rs1 = 0;
		dec_rs2 = 0;
		dec_rob_id = 0;
		commit_e_ = `Disable_;
		com_rob_id = 0;

		#(STEP);
		reset_ = `Disable_;
		dec_e_ = `Enable_;
		dec_rd.regtype = TYPE_GPR;
		dec_rd.addr = 1;
		dec_rob_id = 4;
		#(STEP);
		dec_e_ = `Disable_;
		#(STEP);
		dec_e_ = `Enable_;
		dec_rs1.regtype = TYPE_GPR;
		dec_rs1.addr = 1;
		dec_rs2.regtype = TYPE_GPR;
		dec_rs2.addr = 2;
		#(STEP);
		dec_e_ = `Disable_;

		#(STEP);
		reset_ = `Disable_;
		dec_e_ = `Enable_;
		dec_rd.regtype = TYPE_GPR;
		dec_rd.addr = 1;
		dec_rob_id = 5;
		#(STEP);
		dec_e_ = `Disable_;
		#(STEP);
		dec_e_ = `Enable_;
		dec_rs1.regtype = TYPE_GPR;
		dec_rs1.addr = 1;
		dec_rs2.regtype = TYPE_GPR;
		dec_rs2.addr = 2;
		#(STEP);
		dec_e_ = `Disable_;


		#(STEP*5);

		$finish;
	end

	`include "waves.vh"
`endif

endmodule
