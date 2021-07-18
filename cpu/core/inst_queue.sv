/*
* <inst_queue.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "decode.svh"
`include "issue.svh"
`include "exe.svh"

module inst_queue #(
	parameter IQ_DEPTH = `IqDepth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter IQ = $clog2(IQ_DEPTH),
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				dec_e_,
	input wire				dec_invalid,
	input ImmData_t			dec_imm,
	input ExeUnit_t			dec_unit,
	input OpCommand_t		dec_command,
	input RegFile_t			ren_rd,
	input RegFile_t			ren_rs1,
	input wire				ren_rs1_ready,
	input RegFile_t			ren_rs2,
	input wire				ren_rs2_ready,

	input ExeBusy_t			exe_busy,
	input wire				wb_e_,
	input RegFile_t			wb_rd,

	input wire				commit_e_,
	input RegFile_t			commit_rd,
	input wire [ROB-1:0]	commit_rob_id,

	output wire				issue_e_,
	output RegFile_t		issue_rd,
	output RegFile_t		issue_rs1,
	output RegFile_t		issue_rs2,
	output ImmData_t		issue_imm,
	output ExeUnit_t		issue_unit,
	output OpCommand_t		issue_command,

	output wire				busy
);

	//***** internal types
	typedef struct packed {
		ImmData_t			imm;
		OpCommand_t			command;
	} InstInfo_t;

	//***** internal parameters
	localparam INST_INFO = $bits(InstInfo_t);

	//***** internal wires 
	//*** decode
	wire					add_entry_;
	wire [IQ-1:0]			dec_iq_id;
	InstInfo_t				dec_info;
	//*** issue
	wire [IQ-1:0]			issue_iq_id;
	InstInfo_t				issue_info;



	//***** assign output
	assign issue_imm = issue_info.imm;
	assign issue_command = issue_info.command;



	//***** assign internal
	assign add_entry_ = dec_e_ || dec_invalid;
	assign dec_info = 
		'{imm: dec_imm, command: dec_command};



	//***** instruction queue assign
	wire			dummy_v;
	freelist #(
		.DEPTH		( IQ_DEPTH ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.BIT_VEC	( `Disable ),
		.OUTREG		( `Disable )
	) iq_assign (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ),
		.we_		( issue_e_ ),
		.wd			( issue_iq_id ),
		.re_		( add_entry_ ),
		.rd			( dec_iq_id ),
		.v			( dummy_v ),
		.busy		( busy )
	);



	//***** instruction status manage, wakeup and select
	inst_sched #(
		.IQ_DEPTH		( IQ_DEPTH ),
		.ROB_DEPTH		( ROB_DEPTH )
	) inst_sched (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.add_entry_		( add_entry_ ),
		.ren_rd			( ren_rd ),
		.ren_rs1		( ren_rs1 ),
		.ren_rs1_ready	( ren_rs1_ready ),
		.ren_rs2		( ren_rs2 ),
		.ren_rs2_ready	( ren_rs2_ready ),
		.dec_unit		( dec_unit ),
		.dec_iq_id		( dec_iq_id ),

		.exe_busy		( exe_busy ),
		.wb_e_			( wb_e_ ),
		.wb_rd			( wb_rd ),

		.commit_e_		( commit_e_ ),
		.commit_rd		( commit_rd ),
		.commit_rob_id	( commit_rob_id ),

		.issue_e_		( issue_e_ ),
		.issue_iq_id	( issue_iq_id ),
		.issue_rd		( issue_rd ),
		.issue_rs1		( issue_rs1 ),
		.issue_rs2		( issue_rs2 ),
		.issue_unit		( issue_unit )
	);



	//***** payload ram for instruction information
	regfile #(
		.DATA		( INST_INFO ),
		.ADDR		( IQ ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Disable )
	) info_buf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( issue_iq_id ),
		.waddr		( dec_iq_id ),
		.we_		( dec_e_ ),
		.wdata		( dec_info ),
		.rdata		( issue_info )
	);

endmodule
