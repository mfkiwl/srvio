/*
* <alu_top.sv>
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
`include "regfile.svh"
`include "exception.svh"

module alu_top #(
	parameter DATA = `DataWidth,
	parameter ADDR = `AddrWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				issue_e_,
	input RegFile_t			rd,
	input wire				data1_e_,
	input wire [DATA-1:0]	data1,
	input wire				data2_e_,
	input wire [DATA-1:0]	data2,
	input OpCommand_t		command,

	input wire [ADDR-1:0]	pred_addr,
	input wire				br_pred,
	output wire [ROB-1:0]	alu_rob_id,

	input wire				wb_ack_,
	output wire				wb_req_,
	output RegFile_t		pre_wb_rd,

	output wire				wb_e_,
	output RegFile_t		wb_rd,
	output wire [DATA-1:0]	wb_data,
	output wire				wb_exp_,
	output ExpCode_t		wb_exp_code,
	output wire				wb_pred_miss_,
	output wire				wb_jump_miss_,

	output wire				busy
);

	//***** internal wires
	//*** input
	wire [DATA-1:0]			alu_data1;
	wire [DATA-1:0]			alu_data2;
	//*** reuslt
	wire [DATA-1:0]			alu_res;
	wire					exp_;
	ExpCode_t				exp_code;
	wire					pred_miss_;
	wire					jump_miss_;



	//***** assign internal
	assign alu_data1 = data1_e_ ? wb_data : data1;
	assign alu_data2 = data2_e_ ? wb_data : data2;



	//***** status and writeback control
	alu_ctrl #(
		.DATA			( DATA )
	) alu_ctrl (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.issue_e_		( issue_e_ ),
		.rd				( rd ),
		.exp_			( exp_ ),
		.exp_code		( exp_code ),
		.alu_res		( alu_res ),
		.pred_miss_		( pred_miss_ ),
		.jump_miss_		( jump_miss_ ),

		.wb_ack_		( wb_ack_ ),
		.wb_req_		( wb_req_ ),
		.pre_wb_rd		( pre_wb_rd ),

		.wb_e_			( wb_e_ ),
		.wb_rd			( wb_rd ),
		.wb_data		( wb_data ),
		.wb_exp_		( wb_exp_ ),
		.wb_exp_code	( wb_exp_code ),
		.wb_pred_miss_	( wb_pred_miss_ ),
		.wb_jump_miss_	( wb_jump_miss_ ),

		.busy			( busy )
	);



	//***** integer operations
	alu_exe #(
		.DATA		( DATA )
	) alu_exe (
		.command	( command ),
		.data1		( alu_data1 ),
		.data2		( alu_data2 ),

		.res		( alu_res ),
		.exp_		( exp_ ),
		.exp_code	( exp_code )
	);



	//***** branch result compare
	alu_br_comp	#(
		.ADDR			( ADDR )
	) alu_br_comp (
		.alu_command	( command ),
		.alu_res		( alu_res ),

		.rd				( rd ),
		.rob_id			( alu_rob_id ),

		.pred_addr		( pred_addr ),
		.br_pred		( br_pred ),

		.pred_miss_		( pred_miss_ ),
		.jump_miss_		( jump_miss_ )
	);

endmodule
