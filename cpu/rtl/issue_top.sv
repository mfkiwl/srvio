/*
* <issue_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module issue_top #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter IQ_DEPTH = `IqDepth,
	parameter ROB_DEPTH = `RobDepth
)(
	input wire				clk,
	input wire				reset_,

	DecIsIf.issue			dec_is_if,
	IsExeIf.issue			is_exe_if
);

	//***** internal parameters
	localparam ROB = $clog2(ROB_DEPTH);

	//***** internal wires
	//*** rename
	RegFile_t				ren_rd;
	RegFile_t				ren_rs1;
	wire					ren_rs1_ready;
	RegFile_t				ren_rs2;
	wire					ren_rs2_ready;
	//*** issue
	RegFile_t				issue_rs1;
	RegFile_t				issue_rs2;
	ImmData_t				issue_imm;
	//*** commit
	wire					commit_e_;
	wire					flush_;
	wire [ADDR-1:0]			commit_pc;
	RegFile_t				commit_rd;
	wire					commit_exp_;
	ExpCode_t				commit_exp_code;
	wire [ADDR-1:0]			exp_handler_pc;
	wire [DATA-1:0]			commit_data;
	wire [ROB-1:0]			commit_rob_id;
	//*** busy signal
	wire					is_busy;
	wire					rob_busy;

	//***** internal registers



	//***** assign output
	assign dec_is_if.is_full = is_busy || rob_busy;




	//***** instruction queue
	inst_queue #(
		.IQ_DEPTH		( IQ_DEPTH )
	) inst_queue (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.dec_e_			( dec_is_if.dec_e_ ),
		.dec_invalid	( dec_is_if.dec_invalid ),
		.dec_imm		( dec_is_if.dec_imm ),
		.dec_unit		( dec_is_if.dec_unit ),
		.dec_command	( dec_is_if.dec_command ),
		.ren_rd			( ren_rd ),
		.ren_rs1		( ren_rs1 ),
		.ren_rs1_ready	( ren_rs1_ready ),
		.ren_rs2		( ren_rs2 ),
		.ren_rs2_ready	( ren_rs2_ready ),

		.exe_busy		( is_exe_if.exe_busy ),
//		.wb_e_			( is_exe_if.wb_e_ ),
//		.wb_rd			( is_exe_if.wb_rd ),
		.wb_e_			( is_exe_if.pre_wb_e_ ),
		.wb_rd			( is_exe_if.pre_wb_rd ),

		.commit_e_		( commit_e_ ),
		.commit_rd		( commit_rd ),
		.commit_rob_id	( commit_rob_id ),

		.issue_e_		( is_exe_if.issue_e_ ),
		.issue_rd		( is_exe_if.rd ),
		.issue_rs1		( issue_rs1 ),
		.issue_rs2		( issue_rs2 ),
		.issue_imm		( issue_imm ),
		.issue_unit		( is_exe_if.unit ),
		.issue_command	( is_exe_if.command ),

		.busy			( is_busy )
	);



	//***** operand select
	operand_mux #(
		.DATA			( DATA ),
		.ROB_DEPTH		( ROB_DEPTH )
	) operand_mux (
		.issue_rs1		( issue_rs1 ),
		.issue_rs2		( issue_rs2 ),
		.issue_imm		( issue_imm ),

		.wb_e_			( is_exe_if.wb_e_ ),
		.wb_rd			( is_exe_if.wb_rd ),
		.wb_data		( is_exe_if.wb_data ),

		.commit_e_		( commit_e_ ),
		.commit_rob_id	( commit_rob_id ),
		.commit_data	( commit_data ),

		.rs1_data		( rs1_data ),
		.rs2_data		( rs2_data ),
		.rs1_addr		( rs1_addr ),
		.rs2_addr		( rs2_addr )
	);



	//***** Reorder buffer
	reorder_buffer #(
		.DATA				( DATA ),
		.ADDR				( ADDR ),
		.ROB_DEPTH			( ROB_DEPTH ),
		.ROB				( ROB )
	) reorder_buffer (
		.clk				( clk ),
		.reset_				( reset_ )

		.creg_exp_mask		( 0 ),	// TODO: implement this
		.creg_tvec			( 0 ),	// TODO: implement this

		.dec_e_				( dec_is_if.dec_e_ ),
		.dec_pc				( dec_is_if.dec_pc ),
		.dec_rd				( dec_is_if.dec_rd ),
		.dec_rs1			( dec_is_if.dec_rs1 ),
		.dec_rs2			( dec_is_if.dec_rs2 ),
		.dec_br_			( dec_is_if.dec_br_ ),
		//.dec_br_pred_tabke_	(),
		.dec_br_pred_taken_	( `Disable_ ),	// not used
		.dec_jump_			( dec_is_if.dec_jump_ ),
		.dec_invalid		( dec_is_if.dec_invalid ),
		.dec_rob_id			(),	// TODO: implement PcInstIf
		.ren_rd				( ren_rd ),
		.ren_rs1			( ren_rs1 ),
		.ren_rs1_ready		( ren_rs1_ready ),
		.ren_rs2			( ren_rs2 ),
		.ren_rs2_ready		( ren_rs2_ready ),

		.wb_e_				( is_exe_if.wb_e_ ),
		.wb_rd				( is_exe_if.wb_rd ),
		.wb_data			( is_exe_if.wb_data ),
		.wb_exp_			( is_exe_if.wb_exp_ ),
		.wb_exp_code		( is_exe_if.wb_exp_code ),
		.wb_pred_miss_		( is_exe_if.wb_pred_miss_ ),
		.wb_jump_miss_		( is_exe_if.wb_jump_miss_ ),

		.commit_e_			( commit_e_ ),
		.flush_				( flush_ ),
		.commit_pc			( commit_pc ),
		.commit_rd			( commit_rd ),
		.commit_exp_		( commit_exp_ ),
		.commit_exp_code	( commit_exp_code ),
		.exp_handler_pc		( exp_handler_pc ),
		.commit_data		( commit_data ),
		.commit_rob_id		( commit_rob_id ),

		.rob_busy			( rob_busy )
	);



	//***** register files
	cpu_regfiles #(
		.DATA		( DATA ),
	) cpu_regfiles (
	);

endmodule
