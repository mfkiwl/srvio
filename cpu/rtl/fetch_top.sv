/*
* <fetch_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module fetch_top #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
	parameter PRED_MAX = `PredMaxDepth,
	parameter BP_DEPTH = `PredTableDepth,
	parameter BrPredType_t PREDICTOR = `PredType,
	parameter BTB_DEPTH = `BtbDepth,
	parameter RA_DEPTH = `RaStackDepth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	// Interface between I Cache
	ICacheFetchIf.fetch		ic_fetch_if,
	FetchDecIf.fetch		fetch_dec_if,
	PcInstIf.fetch			pc_inst_if
);

	//***** internal wires
	//*** fetch request
	wire					fetch_stall_;
	wire [ADDR-1:0]			fetch_pc;
	wire [ADDR-1:0]			
	//*** fetch
	wire					inst_e_;
	wire [ADDR-1:0]			inst_pc;
	wire [ADDR-1:0]			inst;



	//***** assign output
	assign fetch_dec_if.inst_e_ = inst_e_;
	assign fetch_dec_if.inst_pc = inst_pc;
	assign fetch_dec_if.inst = inst;



	//***** assign interanl
	assign inst = ic_fetch_if.inst;



	//***** Fetch pipeline Control
	fetch_ctrl #(
	) fetch_ctrl (
	);



	//***** Instruction address generator
	fetch_iag #(
		.ADDR			( ADDR ),
		.INST			( INST ),
		.PRED_MAX		( PRED_MAX ),
		.BP_DEPTH		( BP_DEPTH ),
		.PREDICTOR		( PREDICTOR ),
		.BTB_DEPTH		( BTB_DEPTH ),
		.RA_DEPTH		( RA_DEPTH ),
		.ROB_DEPTH		( ROB_DEPTH )
	) fetch_iag (
		.clk			( clk ),
		.reset_			( reset_ ),

		.fetch_stall_	(),
		.fetch_pc		(),
		.next_fetch_pc	(),

		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),
		.inst			( inst ),

		.dec_e_			(),
		.dec_jr_		(),
		.dec_jump_		(),
		.dec_rob_id		(),

		.exe_rob_id		( pc_inst_if.exe_rob_id ),
		.exe_br_pred	( pc_inst_if.exe_br_pred ),
		.exe_target		( pc_inst_if.exe_target ),

		.wb_e_			( pc_inst_if.wb_e_ ),
		.wb_rob_id		( pc_inst_if.wb_rob_id ),
		.wb_pred_miss_	( pc_inst_if.wb_pred_miss_ ),
		.wb_jump_miss_	( pc_inst_if.wb_jump_miss_ ),
		.wb_br_result	( pc_inst_if.wb_br_result ),
		.wb_tar_addr	( pc_inst_if.wb_tar_addr ),
		.wb_flush_		(),

		.commit_e_		( pc_inst_if.commit_e_ ),
		.commit_pc		( pc_inst_if.commit_pc ),
		.com_rob_id		( pc_inst_if.com_rob_id ),

		.busy			()
	);

endmodule
