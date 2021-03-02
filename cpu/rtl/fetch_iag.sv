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
	parameter BTB_DEPTH = `BtbDepth,
	parameter BTB_CNT = `BtbCntWidth,
	parameter RA_DEPTH = `RaStackDepth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	// fetch requet
	input wire [ADDR-1:0]	fetch_pc,
	output wire				btb_hit,
	output wire [ADDR-1:0]	btb_addr,

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
	output wire [ADDR-1:0]	exe_pred_addr,
	output wire				exe_br_pred,

	// writeback
	input wire [ROB-1:0]	wb_rob_id,
	input wire [ADDR-1:0]	wb_tar_pc,
	input wire				wb_pred_miss_,
	input wire				wb_jump_miss_,

	// commit
	input wire				commit_,
	input wire [ROB-1:0]	com_rob_id
);

	//***** internal wires
	BrInstType_t		btb_type;
	//*** branch predictor
	wire				br_pred;
	//TODO: decodeで初めてエントリを見つけたときのために、
	//			別口でエントリ挿入を可能にしたい



	//***** Branch/Jump Instruction Status
	br_status #(
	) br_status (
	);


	//***** Branch Target Buffer
	btb #(
		.ADDR			( ADDR ),
		.BTB_D			( BTB_DEPTH ),
		.CNT			( BTB_CNT )
	) btb (
		.clk			( clk ),
		.reset_			( reset_ ),

		.pc				( fetch_pc ),
		.btb_hit		( btb_hit ),
		.btb_addr		( btb_addr ),
		.btb_type		( btb_type ),

		.br_commit_		(),
		.br_taken_		(),
		.br_miss_		(),
		.jump_commit_	(),
		.jump_call_		(),
		.jump_return_	(),
		.jump_miss_		(),
		.com_addr		(),
		.com_tar_addr	()
	);



	//***** Branch Prediction
	br_predictor #(
		.ADDR			( ADDR ),
		.PRED_D			
	) br_predictor (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.br_			(),
		.br_pc			( fetch_pc ),
		.br_pred		( br_pred ),

		.br_commit_		(),
		.br_taken_		(),
		.br_pred_miss_	()
	);



	//***** Return Address Stack
	ra_stack #(
		.ADDR			( ADDR ),
		.RA_DEPTH		( RA_DEPTH )
	) ra_stack (
		.clk			( clk ),
		.reset_			( reset_ ),

		.call_			(),
		.call_pc		( fetch_pc ),
		.ret_			(),
		.ret_v			(),
		.ret_addr		()
	);

endmodule
