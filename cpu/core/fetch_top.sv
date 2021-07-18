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
	parameter INST = `InstWidth,
	parameter PRED_MAX = `PredMaxDepth,
	parameter BP_DEPTH = `PredTableDepth,
	parameter BrPredType_t PREDICTOR = `PredType,
	parameter BTB_DEPTH = `BtbDepth,
	parameter RA_DEPTH = `RaStackDepth,
	parameter ROB_DEPTH = `RobDepth
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
	wire					fetch_stall;
	wire					fetch_e_;
	wire [ADDR-1:0]			fetch_pc;
	wire [ADDR-1:0]			next_fetch_pc;
	//*** fetch
	wire					inst_e_;
	wire [ADDR-1:0]			inst_pc;
	wire [INST-1:0]			inst;
	wire					ic_stall;
	wire					inst_invalid;	// Invalidate instructions that
											// follow untracked branch/jumps
	//*** iag
	wire					iag_busy;
	//*** writeback
	wire					wb_flush_;
	wire					wb_exp_;
	//*** commit
	wire					flush_;
	wire					commit_exp_;
	wire					exp_flush_;



	//***** assign output
	assign ic_fetch_if.fetch_e_ = fetch_e_;
	assign ic_fetch_if.fetch_pc = fetch_pc;
	assign fetch_dec_if.inst_e_ = inst_e_;
	assign fetch_dec_if.inst_pc = inst_pc;
	assign fetch_dec_if.inst = inst;
	assign fetch_dec_if.dec_flush_ = wb_flush_ && exp_flush_;
	assign fetch_dec_if.dec_stop = dec_stop;



	//***** assign interanl
	assign inst = ic_fetch_if.ic_inst;
	assign ic_stall = ic_fetch_if.ic_stall;
	assign dec_stall = fetch_dec_if.dec_stall;
	assign wb_exp_ = pc_inst_if.wb_exp_;
	assign flush_ = pc_inst_if.flush_;
	assign commit_exp_ = pc_inst_if.commit_exp_;



	//***** Fetch pipeline Control
	fetch_ctrl #(
		.ADDR			( ADDR )
	) fetch_ctrl (
		.clk			( clk ),
		.reset_			( reset_ ),

		.ic_stall		( ic_stall ),
		.next_fetch_pc	( next_fetch_pc ),
		.iag_busy		( iag_busy ),
		.fetch_e_		( fetch_e_ ),
		.fetch_pc		( fetch_pc ),
		.fetch_stall	( fetch_stall ),

		.inst_invalid	( inst_invalid ),
		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),

		.dec_stall		( dec_stall ),
		.dec_stop		( dec_stop ),

		.wb_flush_		( wb_flush_ ),
		.wb_exp_		( wb_exp_ ),

		.flush_			( flush_ ),
		.commit_exp_	( commit_exp_ ),
		.exp_flush_		( exp_flush_ )
	);



	//***** TODO: Implement fetch buffer (implementation is electable)
	//fetch_buffer #(
	//) fetch_buffer (
	//);



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

		.fetch_stall_	( !fetch_stall ), // TODO: change polarity
		.fetch_pc		( fetch_pc ),
		.next_fetch_pc	( next_fetch_pc ),

		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),
		.inst			( inst ),
		.inst_invalid	( inst_invalid ),

		//.dec_e_		( pc_inst_if.dec_e_ ),
		.dec_rob_br_	( pc_inst_if.dec_rob_br_ ),
		//.dec_jr_		( pc_inst_if.dec_jr_ ),
		//.dec_jump_	( pc_inst_if.dec_jump_ ),
		.dec_rob_id		( pc_inst_if.dec_rob_id ),

		.exe_rob_id		( pc_inst_if.exe_rob_id ),
		.exe_br_pred	( pc_inst_if.exe_br_pred ),
		.exe_target		( pc_inst_if.exe_target ),

		.wb_e_			( pc_inst_if.wb_e_ ),
		.wb_rob_id		( pc_inst_if.wb_rob_id ),
		.wb_pred_miss_	( pc_inst_if.wb_pred_miss_ ),
		.wb_jump_miss_	( pc_inst_if.wb_jump_miss_ ),
		.wb_br_result	( pc_inst_if.wb_br_result ),
		.wb_tar_addr	( pc_inst_if.wb_tar_addr ),
		.wb_flush_		( wb_flush_ ),

		.commit_e_		( pc_inst_if.commit_e_ ),
		.commit_pc		( pc_inst_if.commit_pc ),
		.commit_rob_id	( pc_inst_if.commit_rob_id ),

		.busy			( iag_busy )
	);

endmodule
