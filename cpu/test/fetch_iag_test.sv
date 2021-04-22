/*
* <fetch_iag_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"
`include "rv_opcodes.svh"
`include "sim.vh"

module fetch_iag_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter INST = `InstWidth;
	parameter PRED_MAX = `PredMaxDepth;
	parameter BP_DEPTH = `PredTableDepth;
	parameter BrPredType_t PREDICTOR = `PredType;
	parameter BTB_DEPTH = `BtbDepth;
	parameter RA_DEPTH = `RaStackDepth;
	parameter ROB_DEPTH = `RobDepth;
	parameter ROB = $clog2(ROB_DEPTH);

	reg							clk;
	reg							reset_;
	reg   						fetch_stall_;
	reg [ADDR-1:0]				fetch_pc;
	reg							inst_e_;
	reg [ADDR-1:0]				inst_pc;
	union packed {
		RvJtype_t	jump;
		RvItype_t	jr;
		RvBtype_t	branch;
	}							inst;
	reg							dec_e_;
	reg							dec_jr_;
	reg							dec_jump_;
	reg [ROB-1:0]				dec_rob_id;
	reg [ROB-1:0]				exe_rob_id;
	reg							wb_e_;
	reg [ROB-1:0]				wb_rob_id;
	reg							wb_pred_miss_;
	reg							wb_jump_miss_;
	reg							wb_br_result;
	reg [ADDR-1:0]				wb_tar_addr;
	reg							commit_e_;
	reg [ADDR-1:0]				commit_pc;
	reg [ROB-1:0]				com_rob_id;

	// output
	wire [ADDR-1:0]				next_fetch_pc;
	wire						exe_br_pred;
	wire [ADDR-1:0]				exe_target;
	wire						wb_flush_;
	wire						busy;

	fetch_iag #(
		.ADDR		( ADDR ),
		.INST		( INST ),
		.PRED_MAX	( PRED_MAX ),
		.BP_DEPTH	( BP_DEPTH ),
		.PREDICTOR	( PREDICTOR ),
		.BTB_DEPTH	( BTB_DEPTH ),
		.RA_DEPTH	( RA_DEPTH ),
		.ROB_DEPTH	( ROB_DEPTH )
	) fetch_iag (
		.*
	);


`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		fetch_stall_ = `Disable_;
		fetch_pc = 0;
		inst_e_ = `Disable_;
		inst_pc = 0;
		inst = 0;
		dec_e_ = `Disable_;
		dec_jr_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_rob_id = 0;
		exe_rob_id = 0;
		wb_e_ = `Disable_;
		wb_rob_id = 0;
		wb_pred_miss_ = `Disable_; 
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 0;
		commit_e_ = `Disable_;
		commit_pc = 0;
		com_rob_id = 0;
		#(STEP);
		reset_ = `Disable_;
		#(STEP*5);

		$finish;
	end

	`include "waves.vh"
`endif

endmodule
