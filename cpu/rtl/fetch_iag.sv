/*
* <fetch_iag.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"

// fetch instruction address generator
module fetch_iag #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth,
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

	// fetch requet
	input wire				fetch_stall_,
	input wire [ADDR-1:0]	fetch_pc,
	output wire [ADDR-1:0]	next_fetch_pc,

	// fetch
	input wire				inst_e_,
	input wire [ADDR-1:0]	inst_pc,
	input wire [INST-1:0]	inst,

	// decode
	input wire				dec_e_,
	input wire				dec_jr_,
	input wire				dec_jump_,
	input wire [ROB-1:0]	dec_rob_id,

	// exe
	input wire [ROB-1:0]	exe_rob_id,
	output wire				exe_br_pred,
	output wire [ADDR-1:0]	exe_target,

	// writeback
	input wire				wb_e_,
	input wire [ROB-1:0]	wb_rob_id,
	input wire				wb_pred_miss_,
	input wire				wb_jump_miss_,
	input wire				wb_br_result,
	input wire [ADDR-1:0]	wb_tar_addr,
	output wire				wb_flush_,

	// commit
	input wire				commit_e_,
	input wire [ADDR-1:0]	commit_pc,
	input wire [ROB-1:0]	com_rob_id,

	output wire				busy
);

	//***** internal wires
	//*** fetch request
	wire				btb_hit;
	wire [ADDR-1:0]		btb_addr;
	BrInstType_t		btb_type;
	wire				br_pred;
	wire				ret_v;
	wire [ADDR-1:0]		ret_pc;
	//*** fetch
	wire				inst_br_;
	wire				inst_call_;
	wire				inst_return_;
	//*** decode
	wire				dec_br_;
	//*** exe
	//*** writeback
	//*** commit
	wire				br_commit_;
	wire				br_result;
	wire				br_pred_miss_;
	wire				jump_commit_;
	wire				jump_call_;
	wire				jump_return_;
	wire				jump_miss_;
	wire [ADDR-1:0]		com_tar_addr;



	//***** assign internal
	assign dec_br_ = dec_e_ || ( dec_jr_ || dec_jump_ );



	//***** Branch/Jump Instruction Status
	br_status #(
		.ADDR			( ADDR )
	) br_status (
		.clk			( clk ),
		.reset_			( reset_ ),

		.fetch_stall_	( fetch_stall_ ),
		.fetch_pc		( fetch_pc ),
		.btb_hit		( btb_hit ),
		.btb_addr		( btb_addr ),
		.btb_type		( btb_type ),
		.br_pred		( br_pred ),
		.ret_v			( ret_v ),
		.ret_pc			( ret_pc ),
		.next_fetch_pc	( next_fetch_pc ),

		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),
		.inst			( inst ),
		.inst_br_		( inst_br_ ),
		.inst_call_		( inst_call_ ),
		.inst_return_	( inst_return_ ),

		.dec_br_		( dec_br_ ),
		.dec_rob_id		( dec_rob_id ),

		.exe_rob_id		( exe_rob_id ),
		.exe_target		( exe_target ),
		.exe_br_pred	( exe_br_pred ),

		.wb_e_			( wb_e_ ),
		.wb_rob_id		( wb_rob_id ),
		.wb_pred_miss_	( wb_pred_miss_ ),
		.wb_jump_miss_	( wb_jump_miss_ ),
		.wb_br_result	( wb_br_result ),
		.wb_tar_addr	( wb_tar_addr ),
		.wb_flush_		( wb_flush_ ),

		.commit_e_		( commit_e_ ),
		.com_rob_id		( com_rob_id ),
		.br_commit_		( br_commit_ ),
		.br_result		( br_result ),
		.br_pred_miss_	( br_pred_miss_ ),
		.jump_commit_	( jump_commit_ ),
		.jump_call_		( jump_call_ ),
		.jump_return_	( jump_return_ ),
		.jump_miss_		( jump_miss_ ),
		.com_tar_addr	( com_tar_addr ),

		.pred_busy		( busy )
	);


	//***** Branch Target Buffer
	btb #(
		.ADDR			( ADDR ),
		.BTB_D			( BTB_DEPTH )
	) btb (
		.clk			( clk ),
		.reset_			( reset_ ),

		.pc				( fetch_pc ),
		.btb_hit		( btb_hit ),
		.btb_addr		( btb_addr ),
		.btb_type		( btb_type ),

		.br_commit_		( br_commit_ ),
		.br_result		( br_result ),
		.br_miss_		( br_pred_miss_ ),
		.jump_commit_	( jump_commit_ ),
		.jump_call_		( jump_call_ ),
		.jump_return_	( jump_return_ ),
		.jump_miss_		( jump_miss_ ),
		.com_pc			( commit_pc ),
		.com_tar_addr	( com_tar_addr )
	);



	//***** Branch Prediction
	br_predictor #(
		.ADDR			( ADDR ),
		.DEPTH			( BP_DEPTH ),
		.PRED_MAX		( PRED_MAX ),
		.PREDICTOR		( PREDICTOR )
	) br_predictor (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( wb_flush_ ),

		.br_			( inst_br_ ),
		.br_pc			( fetch_pc ),
		.br_pred		( br_pred ),

		.commit_pc		( commit_pc ),
		.br_commit_		( br_commit_),
		.br_result		( br_result ),
		.br_pred_miss_	( br_pred_miss_ )
	);



	//***** Return Address Stack
	ra_stack #(
		.ADDR			( ADDR ),
		.RA_DEPTH		( RA_DEPTH )
	) ra_stack (
		.clk			( clk ),
		.reset_			( reset_ ),

		.call_			( inst_call_ ),
		.call_pc		( inst_pc ),
		.ret_			( inst_return_ ),
		.ret_v			( ret_v ),
		.ret_addr		( ret_pc )
	);

endmodule
