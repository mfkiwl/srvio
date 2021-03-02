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
	IsExeIf.issue			is_exe_if,
	PcInstIf.issue			pc_inst_if,
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
	wire					issue_e_;
	RegFile_t				issue_rd;
	RegFile_t				issue_rs1;
	RegFile_t				issue_rs2;
	ImmData_t				issue_imm;
	ExeUnit_t				issue_unit;
	OpCommand_t				issue_command;
	wire [ADDR-1:0]			issue_pc;
	wire [DATA-1:0]			issue_gpr_data1;
	wire [DATA-1:0]			issue_gpr_data2;
	wire [`GprAddr]			issue_gpr_addr1;
	wire [`GprAddr]			issue_gpr_addr2;
	wire [DATA-1:0]			issue_fpr_data1;
	wire [DATA-1:0]			issue_fpr_data2;
	wire [`FprAddr]			issue_fpr_addr1;
	wire [`FprAddr]			issue_fpr_addr2;
	wire [DATA-1:0]			issue_data1;
	wire					issue_data1_e_;
	wire [DATA-1:0]			issue_data2;
	wire					issue_data2_e_;
	//*** commit
	wire					commit_e_;
	wire					commit_jump_;
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
	//*** issue pipeline register
	reg						issue_e_reg_;
	RegFile_t				issue_rd_reg;
	reg						issue_data1_e_reg_;
	reg [DATA-1:0]			issue_data1_reg;
	reg						issue_data2_e_reg_;
	reg [DATA-1:0]			issue_data2_reg;
	ExeUnit_t				issue_unit_reg;
	OpCommand_t				issue_command_reg;



	//***** assign output
	assign is_exe_if.issue_e_ = issue_e_;
	assign is_exe_if.issue_rd = issue_rd;
	assign is_exe_if.issue_data1 = issue_data1;
	assign is_exe_if.issue_data1_e_ = issue_data1_e_;
	assign is_exe_if.issue_data2 = issue_data2;
	assign is_exe_if.issue_data2_e_ = issue_data2_e_;
	assign is_exe_if.issue_unit = issue_unit;
	assign is_exe_if.issue_command = issue_command;
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

		.issue_e_		( issue_e_ ),
		.issue_rd		( issue_rd ),
		.issue_rs1		( issue_rs1 ),
		.issue_rs2		( issue_rs2 ),
		.issue_imm		( issue_imm ),
		.issue_unit		( issue_unit ),
		.issue_command	( issue_command ),

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
		.issue_pc		( issue_pc ),

		.wb_e_			( is_exe_if.wb_e_ ),
		.wb_rd			( is_exe_if.wb_rd ),
		.wb_data		( is_exe_if.wb_data ),

		.commit_e_		( commit_e_ ),
		.commit_rob_id	( commit_rob_id ),
		.commit_data	( commit_data ),

		.gpr_data1		( issue_gpr_data1 ),
		.gpr_data2		( issue_gpr_data2 ),
		.gpr_addr1		( issue_gpr_addr1 ),
		.gpr_addr2		( issue_gpr_addr2 ),

		.fpr_data1		( issue_fpr_data1 ),
		.fpr_data2		( issue_fpr_data2 ),
		.fpr_addr1		( issue_fpr_addr1 ),
		.fpr_addr2		( issue_fpr_addr2 ),

		.data1			( issue_data1 ),
		.data1_e_		( issue_data1_e_ ),
		.data2			( issue_data2 ),
		.data2_e_		( issue_data2_e_ )
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
		.dec_rob_id			( pc_inst_if.dec_rob_id ),
		.ren_rd				( ren_rd ),
		.ren_rs1			( ren_rs1 ),
		.ren_rs1_ready		( ren_rs1_ready ),
		.ren_rs2			( ren_rs2 ),
		.ren_rs2_ready		( ren_rs2_ready ),

		.issue_rob_id		( issue_rd.addr[ROB-1:0] ),
		.issue_pc			( issue_pc ),

		.wb_e_				( is_exe_if.wb_e_ ),
		.wb_rd				( is_exe_if.wb_rd ),
		.wb_data			( is_exe_if.wb_data ),
		.wb_exp_			( is_exe_if.wb_exp_ ),
		.wb_exp_code		( is_exe_if.wb_exp_code ),
		.wb_pred_miss_		( is_exe_if.wb_pred_miss_ ),
		.wb_jump_miss_		( is_exe_if.wb_jump_miss_ ),

		.commit_e_			( commit_e_ ),
		.commit_jump_		( commit_jump_ ),
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
		.DATA				( DATA ),
	) cpu_regfiles (
		.clk				( clk ),
		.issue_gpr_addr1	( issue_gpr_addr1 ),
		.issue_gpr_addr2	( issue_gpr_addr2 ),
		.issue_gpr_data1	( issue_gpr_data1 ),
		.issue_gpr_data2	( issue_gpr_data2 ),

		.issue_fpr_addr1	( issue_fpr_addr1 ),
		.issue_fpr_addr2	( issue_fpr_addr2 ),
		.issue_fpr_data1	( issue_fpr_data1 ),
		.issue_fpr_data2	( issue_fpr_data2 ),

		.commit_e_			( commit_e_ ),
		.commit_jump_		( commit_jump_ ),
		.commit_rd			( commit_rd ),
		.commit_data		( commit_data ),
		.commit_pc			( commit_pc )
	);



	//*****
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			issue_e_reg_ <= `Disable_;
			issue_rd_reg <= 0;
			issue_data1_e_reg_ <= `Disable_;
			issue_data1_reg <= 0;
			issue_data2_e_reg_ <= `Disable_;
			issue_data2_reg <= 0;
			issue_unit_reg <= UNIT_NOP;
			issue_command_reg <= 0;
		end else begin
			if ( flush_ == `Enable_ ) begin
				issue_e_reg_ <= `Disable_;
				issue_rd_reg <= 0;
				issue_data1_e_reg_ <= `Disable_;
				issue_data1_reg <= 0;
				issue_data2_e_reg_ <= `Disable_;
				issue_data2_reg <= 0;
				issue_unit_reg <= UNIT_NOP;
				issue_command_reg <= 0;
			end else begin
				issue_e_reg_ <= issue_e_;
				issue_rd_reg <= issue_rd;
				issue_data1_e_reg_ <= issue_data1_e_;
				issue_data1_reg <= issue_data1;
				issue_data2_e_reg_ <= issue_data2_e_;
				issue_data2_reg <= issue_data2;
				issue_unit_reg <= issue_unit;
				issue_command_reg <= issue_command;
			end
		end
	end

endmodule
