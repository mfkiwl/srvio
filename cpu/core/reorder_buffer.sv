/*
* <reorder_buffer.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exception.svh"

module reorder_buffer #(
	parameter byte DATA = `DataWidth,
	parameter byte ADDR = `AddrWidth,
	parameter byte ROB_DEPTH = `RobDepth,
	// constant
	parameter byte ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				creg_exp_mask,
	input wire [DATA-1:0]	creg_tvec,

	input wire				dec_e_,
	input wire [ADDR-1:0]	dec_pc,
	input RegFile_t			dec_rd,
	input RegFile_t			dec_rs1,
	input RegFile_t			dec_rs2,
	input wire				dec_br_,
	//input wire			dec_br_pred,
	input wire				dec_jump_,
	input wire				dec_invalid,
	output wire				dec_rob_br_,
	output wire [ROB-1:0]	dec_rob_id,
	output RegFile_t		ren_rd,
	output RegFile_t		ren_rs1,
	output wire				ren_rs1_ready,
	output RegFile_t		ren_rs2,
	output wire				ren_rs2_ready,

	input wire [ROB-1:0]	issue_rob_id,	// For issued instructions
	output wire [ADDR-1:0]	issue_pc,		//    replace TYPE_PC operands

	input wire				wb_e_,
	input RegFile_t			wb_rd,
	input wire [DATA-1:0]	wb_data,
	input wire				wb_exp_,
	input ExpCode_t			wb_exp_code,
	input wire				wb_pred_miss_,
	input wire				wb_jump_miss_,

	output wire				commit_e_,
	output wire				commit_jump_,
	output wire				commit_miss_pred_,
	output wire				flush_,
	output wire [ADDR-1:0]	commit_pc,
	output RegFile_t		commit_rd,
	output wire				commit_exp_,
	output ExpCode_t		commit_exp_code,
	output wire [ADDR-1:0]	exp_handler_pc,
	output wire [DATA-1:0]	commit_data,
	output wire [ROB-1:0]	commit_rob_id,

	output wire				rob_busy
);

	//***** internal wires
	wire				dec_rob_br_wire_;
	wire [ROB-1:0]		dec_rob_id_wire;
	wire [ROB-1:0]		wb_rob_id;

	//***** internal registers
	reg					dec_rob_br_reg_;
	reg [ROB-1:0]		dec_rob_id_reg;


	
	//***** assign output
	assign dec_rob_br_ = dec_rob_br_reg_;
	assign dec_rob_id = dec_rob_id_reg;



	//***** intenal assign
	assign dec_rob_br_wire_ = dec_e_ || ( dec_br_ && dec_jump_ );
	assign wb_rob_id = wb_rd.addr;



	//***** rename operands
	rename #(
		.ROB_DEPTH		( ROB_DEPTH )
	) rename (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.dec_e_			( dec_e_ ),
		.dec_invalid	( dec_invalid ),
		.dec_rd			( dec_rd ),
		.dec_rs1		( dec_rs1 ),
		.dec_rs2		( dec_rs2 ),
		.dec_rob_id		( dec_rob_id_wire ),
		.ren_rs1		( ren_rs1 ),
		.ren_rs2		( ren_rs2 ),
		.ren_rd			( ren_rd ),

		.commit_e_		( commit_e_ ),
		.com_rob_id		( commit_rob_id )
	);



	//***** hold speculative operands
	regfile #(
		.DATA		( DATA ),
		.ADDR		( ROB ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Disable )
	) operand_buf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( commit_rob_id ),
		.waddr		( wb_rob_id ),
		.we_		( wb_e_ ),
		.wdata		( wb_data ),
		.rdata		( commit_data )
	);



	//***** reorder buffer status
	rob_status #(
		.DATA			( DATA ),
		.ADDR			( ADDR ),
		.ROB_DEPTH		( ROB_DEPTH )
	) rob_status (
		.clk			( clk ),
		.reset_			( reset_ ),

		.dec_e_			( dec_e_ ),
		.dec_pc			( dec_pc ),
		.dec_rd			( dec_rd ),
		.dec_br_		( dec_br_ ),
		.dec_br_pred	( 1'b0 ),	// not used ( tracked in fetch_iag )
		.dec_jump_		( dec_jump_ ),
		.dec_invalid	( dec_invalid ),
		.dec_rob_id		( dec_rob_id_wire ),

		.ren_rs1		( ren_rs1 ),
		.ren_rs2		( ren_rs2 ),
		.ren_rs1_ready	( ren_rs1_ready ),
		.ren_rs2_ready	( ren_rs2_ready ),

		.issue_rob_id	( issue_rob_id ),
		.issue_pc		( issue_pc ),

		.wb_e_			( wb_e_ ),
		.wb_rob_id		( wb_rob_id ),
		.wb_exp_		( wb_exp_ ),
		.wb_exp_code	( wb_exp_code ),
		.wb_pred_miss_	( wb_pred_miss_ ),
		.wb_jump_miss_	( wb_jump_miss_ ),

		.commit_e_		( commit_e_ ),
		.com_jump_		( commit_jump_ ),
		.com_miss_pred_	( commit_miss_pred_ ),
		.flush_			( flush_ ),
		.com_pc			( commit_pc ),
		.com_rd			( commit_rd ),
		.com_exp_		( commit_exp_ ),
		.com_exp_code	( commit_exp_code ),
		.com_rob_id		( commit_rob_id ),
		.rob_busy		( rob_busy )
	);



	//***** exception handling
	exp_manage #(
		.ADDR	( ADDR ),
		.DATA	( DATA )
	) exp_manage (
		.commit_exp_		( commit_exp_ ),
		.commit_exp_code	( commit_exp_code ),
		.creg_exp_mask		( creg_exp_mask ),
		.creg_tvec			( creg_tvec ),
		.exp_handler_pc		( exp_handler_pc )
	);



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			dec_rob_br_reg_ <= `Disable_;
			dec_rob_id_reg <= {ROB{1'b0}};
		end else begin
			dec_rob_br_reg_ <= dec_rob_br_wire_;
			dec_rob_id_reg <= dec_rob_id_wire;
		end
	end

endmodule
