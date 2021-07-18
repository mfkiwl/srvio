/*
* <exe_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "decode.svh"
`include "exe.svh"

module exe_top #(
	parameter DATA = `DataWidth,
	parameter ROB_DEPTH = `RobDepth
)(
	input wire		clk,
	input wire		reset_,

	IsExeIf.exe		is_exe_if,
	PcInstIf.exe	pc_inst_if
);

	//***** internal parameters
	localparam ROB = $clog2(ROB_DEPTH);

	//***** internal wires
	ExeBusy_t		exe_busy;
	//*** issue
	wire			issue_miss;		// inst. issued before operands get ready
									//     due to CDB conflicts.
	wire			issue_alu_;
	wire			issue_div_;
	wire			issue_fpu_;
	wire			issue_fpu_;
	wire			issue_fdiv_;
	wire			issue_csr_;
	wire			issue_mem_;
	RegFile_t		issue_rd;
	wire			issue_data1_e_;
	wire [DATA-1:0]	issue_data1;
	wire			issue_data2_e_;
	wire [DATA-1:0]	issue_data2;
	OpCommand_t		issue_command;
	//*** forwarded data
	wire [DATA-1:0]	data1;
	wire [DATA-1:0]	data2;
	//*** write back
	wire			pre_wb_e_;
	RegFile_t		pre_wb_rd;
	wire			wb_e_;
	RegFile_t		wb_rd;
	wire [DATA-1:0]	wb_data;
	wire			wb_exp_;
	ExpCode_t		wb_exp_code;
	wire			wb_pred_miss_;
	wire			wb_jump_miss_;
	//* alu
	wire			alu_wb_req_;
	wire			alu_wb_ack_;
	RegFile_t		alu_pre_wb_rd;
	wire			alu_wb_e_;
	RegFile_t		alu_wb_rd;
	wire [DATA-1:0]	alu_wb_data;
	wire			alu_wb_exp_;
	ExpCode_t		alu_wb_exp_code;
	wire			alu_wb_pred_miss_;
	wire			alu_wb_jump_miss_;
	//* integer divider
	wire			div_wb_req_;
	wire			div_wb_ack_;
	RegFile_t		div_pre_wb_rd;
	//* fpu
	wire			fpu_wb_req_;
	wire			fpu_wb_ack_;
	RegFile_t		fpu_pre_wb_rd;
	//* floating point divider
	wire			fdiv_wb_req_;
	wire			fdiv_wb_ack_;
	RegFile_t		fdiv_pre_wb_rd;
	//* control & status register (CSR) access
	wire			csr_wb_req_;
	wire			csr_wb_ack_;
	RegFile_t		csr_pre_wb_rd;
	//* memory access unit
	wire			mem_wb_req_;
	wire			mem_wb_ack_;
	RegFile_t		mem_pre_wb_rd;
	//*** pipeline flush
	wire			flush_;



	//***** assign output
	//*** to issue
	assign is_exe_if.pre_wb_e_ = pre_wb_e_;
	assign is_exe_if.pre_wb_rd = pre_wb_rd;
	assign is_exe_if.wb_e_ = wb_e_;
	assign is_exe_if.wb_rd = wb_rd;
	assign is_exe_if.wb_data = wb_data;
	assign is_exe_if.wb_exp_ = wb_exp_;
	assign is_exe_if.wb_exp_code = wb_exp_code;
	assign is_exe_if.wb_pred_miss_ = wb_pred_miss_;
	assign is_exe_if.wb_jump_miss_ = wb_jump_miss_;
	//*** pc instruction interface
	assign pc_inst_if.wb_e_ = wb_e_;
	assign pc_inst_if.wb_rob_id = wb_rd.addr;
	assign pc_inst_if.wb_pred_miss_ = wb_pred_miss_;
	assign pc_inst_if.wb_jump_miss_ = wb_jump_miss_;
	assign pc_inst_if.wb_br_result = wb_br_result;
	assign pc_inst_if.wb_tar_addr = wb_data;
	assign pc_inst_if.wb_exp_ = wb_exp_;



	//***** assign internal
	//*** signal distribution
	assign issue_rd = is_exe_if.issue_rd;
	assign issue_data1_e_ = is_exe_if.issue_data1_e_;
	assign issue_data1 = is_exe_if.issue_data1;
	assign issue_data2_e_ = is_exe_if.issue_data2_e_;
	assign issue_data2 = is_exe_if.issue_data2;
	assign issue_command = is_exe_if.issue_command;
	assign flush_ = pc_inst_if.flush_;
	//*** forwarding
	assign issue_miss =
		( ( issue_data1_e_ == `Enable_ ) && ( issue_rs1 != wb_rd ) ) ||
		( ( issue_data2_e_ == `Enable_ ) && ( issue_rs2 != wb_rd ) );
	assign data1 = issue_data1_e_ ? wb_data : issue_data1;
	assign data2 = issue_data2_e_ ? wb_data : issue_data2;



	//***** issue unit selector
	exe_sel exe_sel (
		.issue_e_		( is_exe_if.issue_e_ ),
		.issue_unit		( is_exe_if.issue_unit ),
		.issue_miss		( issue_miss ),

		.issue_alu_		( issue_alu_ ),
		.issue_div_		( issue_div_ ),
		.issue_fpu_		( issue_fpu_ ),
		.issue_fdiv_	( issue_fdiv_ ),
		.issue_csr_		( issue_csr_ ),
		.issue_mem_		( issue_mem_ ),
		.issue_invalid_	()
	);



	//***** Integer
	alu_top #(
		.DATA			( DATA ),
		.ADDR			( ADDR ),
		.ROB			( ROB )
	) alu_top (
		.clk			( clk ),
		.reset_			( reset_ ),

		.flush_			( flush_ ),

		.issue_e_		( issue_alu_ ),
		.rd				( issue_rd ),
		.data1			( issue_data1 ),
		.data2			( issue_data2 ),
		.command		( issue_command.alu ),

		.pred_addr		( pc_inst_if.exe_target ),
		.br_pred		( pc_inst_if.exe_br_pred ),
		.alu_rob_id		( pc_inst_if.exe_rob_id ),

		.wb_ack_		( alu_wb_ack_ ),
		.wb_req_		( alu_wb_req_ ),
		.pre_wb_rd		( alu_pre_wb_rd ),

		.wb_e_			( alu_wb_e_ ),
		.wb_rd			( alu_wb_rd ),
		.wb_data		( alu_wb_data ),
		.wb_exp_		( alu_wb_exp_ ),
		.wb_exp_code	( alu_wb_exp_code ),
		.wb_br_result	( wb_br_result ),
		.wb_pred_miss_	( wb_pred_miss_ ),
		.wb_jump_miss_	( wb_jump_miss_ ),

		.busy			( is_exe_if.exe_busy.alu )
	);



	//***** Integer Divider
	div_top #(
		.DATA			( DATA )
	) div_top (
		.clk			( clk ),
		.reset_			( reset_ )
	);



	//***** FPU
	fpu_top #(
		.DATA			( DATA )
	) fpu_top (
		.clk			( clk ),
		.reset_			( reset_ )
	);



	//***** FP Divider
	fdiv_top #(
		.DATA			( DATA )
	) fdiv_top (
		.clk			( clk ),
		.reset_			( reset_ )
	);



	//***** CSR Access
	csr_access_top #(
	) csr_access_top (
	);



	//***** Memory Access
	mem_access_top #(
	) mem_access_top (
	);



	//***** Common data bus
	cdb #(
		.DATA				( DATA )
	) cdb (
		.clk				( clk ),
		.reset_				( reset_ ),

		.alu_wb_req_		( alu_wb_req_ ),
		.div_wb_req_		( div_wb_req_ ),
		.fpu_wb_req_		( fpu_wb_req_ ),
		.fdiv_wb_req_		( fdiv_wb_req_ ),
		.csr_wb_req_		( csr_wb_req_ ),
		.mem_wb_req_		( mem_wb_req_ ),

		.alu_wb_ack_		( alu_wb_ack_ ),
		.div_wb_ack_		( div_wb_ack_ ),
		.fpu_wb_ack_		( fpu_wb_ack_ ),
		.fdiv_wb_ack_		( fdiv_wb_ack_ ),
		.csr_wb_ack_		( csr_wb_ack_ ),
		.mem_wb_ack_		( mem_wb_ack_),

		.alu_pre_wb_rd		( alu_pre_wb_rd ),
		.div_pre_wb_rd		( div_pre_wb_rd ),
		.fpu_pre_wb_rd		( fpu_pre_wb_rd ),
		.fdiv_pre_wb_rd		( fdiv_pre_wb_rd ),
		.csr_pre_wb_rd		( csr_pre_wb_rd ),
		.mem_pre_wb_rd		( mem_pre_wb_rd ),
		.pre_wb_e_			( pre_wb_e_ ),
		.pre_wb_rd			( pre_wb_rd ),

		.alu_wb_e_			( alu_wb_e_ ),
		.alu_wb_rd			( alu_wb_rd ),
		.alu_wb_data		( alu_wb_data ),
		.alu_wb_exp_		( alu_wb_exp_ ),
		.alu_wb_exp_code	( alu_wb_exp_code ),

		.div_wb_e_			( div_wb_e_ ),
		.div_wb_rd			( div_wb_rd ),
		.div_wb_data		( div_wb_data ),
		.div_wb_exp_		( div_wb_exp_ ),
		.div_wb_exp_code	( div_wb_exp_code ),

		.fpu_wb_e_			( fpu_wb_e_ ),
		.fpu_wb_rd			( fpu_wb_rd ),
		.fpu_wb_data		( fpu_wb_data ),
		.fpu_wb_exp_		( fpu_wb_exp_ ),
		.fpu_wb_exp_code	( fpu_wb_exp_code ),

		.fdiv_wb_e_			( fdiv_wb_e_ ),
		.fdiv_wb_rd			( fdiv_wb_rd ),
		.fdiv_wb_data		( fdiv_wb_data ),
		.fdiv_wb_exp_		( fdiv_wb_exp_ ),
		.fdiv_wb_exp_code	( fdiv_wb_exp_code ),

		.csr_wb_e_			( csr_wb_e_ ),
		.csr_wb_rd			( csr_wb_rd ),
		.csr_wb_data		( csr_wb_data ),
		.csr_wb_exp_		( csr_wb_exp_ ),
		.csr_wb_exp_code	( csr_wb_exp_code ),

		.mem_wb_e_			( mem_wb_e_ ),
		.mem_wb_rd			( mem_wb_rd ),
		.mem_wb_data		( mem_wb_data ),
		.mem_wb_exp_		( mem_wb_exp_ ),
		.mem_wb_exp_code	( mem_wb_exp_code ),

		.wb_e_				( wb_e_ ),
		.wb_rd				( wb_rd ),
		.wb_data			( wb_data ),
		.wb_exp_			( wb_exp_ ),
		.wb_exp_code		( wb_exp_code )
	);

endmodule
