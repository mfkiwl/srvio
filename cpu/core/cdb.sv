/*
* <cdb.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exe.svh"
`include "exception.svh"


module cdb #(
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_,

	input wire				alu_wb_req_,
	input wire				div_wb_req_,
	input wire				fpu_wb_req_,
	input wire				fdiv_wb_req_,
	input wire				csr_wb_req_,
	input wire				mem_wb_req_,

	output wire				alu_wb_ack_,
	output wire				div_wb_ack_,
	output wire				fpu_wb_ack_,
	output wire				fdiv_wb_ack_,
	output wire				csr_wb_ack_,
	output wire				mem_wb_ack_,

	input RegFile_t			alu_pre_wb_rd,
	input RegFile_t			div_pre_wb_rd,
	input RegFile_t			fpu_pre_wb_rd,
	input RegFile_t			fdiv_pre_wb_rd,
	input RegFile_t			csr_pre_wb_rd,
	input RegFile_t			mem_pre_wb_rd,
	output logic			pre_wb_e_,
	output RegFile_t		pre_wb_rd,

	input wire				alu_wb_e_,
	input RegFile_t			alu_wb_rd,
	input wire [DATA-1:0]	alu_wb_data,
	input wire				alu_wb_exp_,
	input ExpCode_t			alu_wb_exp_code,

	input wire				div_wb_e_,
	input RegFile_t			div_wb_rd,
	input wire [DATA-1:0]	div_wb_data,
	input wire				div_wb_exp_,
	input ExpCode_t			div_wb_exp_code,

	input wire				fpu_wb_e_,
	input RegFile_t			fpu_wb_rd,
	input wire [DATA-1:0]	fpu_wb_data,
	input wire				fpu_wb_exp_,
	input ExpCode_t			fpu_wb_exp_code,

	input wire				fdiv_wb_e_,
	input RegFile_t			fdiv_wb_rd,
	input wire [DATA-1:0]	fdiv_wb_data,
	input wire				fdiv_wb_exp_,
	input ExpCode_t			fdiv_wb_exp_code,

	input wire				csr_wb_e_,
	input RegFile_t			csr_wb_rd,
	input wire [DATA-1:0]	csr_wb_data,
	input wire				csr_wb_exp_,
	input ExpCode_t			csr_wb_exp_code,

	input wire				mem_wb_e_,
	input RegFile_t			mem_wb_rd,
	input wire [DATA-1:0]	mem_wb_data,
	input wire				mem_wb_exp_,
	input ExpCode_t			mem_wb_exp_code,

	output logic			wb_e_,
	output RegFile_t		wb_rd,
	output logic [DATA-1:0]	wb_data,
	output logic			wb_exp_,
	output ExpCode_t		wb_exp_code
);

	//***** internal parameters
	localparam UNIT_NUM = 6;
	localparam ALU_IDX = 0;
	localparam CSR_IDX = 1;
	localparam FPU_IDX = 2;
	localparam MEM_IDX = 3;
	localparam DIV_IDX = 4;
	localparam FDIV_IDX = 5;
	localparam EXE_PRIOR = `ExePriorWidth + 1;

	//***** internal registers
	reg [`ExePrior]			alu_wb_cnt;
	reg [`ExePrior]			div_wb_cnt;
	reg [`ExePrior]			fpu_wb_cnt;
	reg [`ExePrior]			fdiv_wb_cnt;
	reg [`ExePrior]			csr_wb_cnt;
	reg [`ExePrior]			mem_wb_cnt;

	//***** internal register
	wire [UNIT_NUM-1:0][EXE_PRIOR-1:0]	sel_in;
	wire [UNIT_NUM-1:0]		sel_vec_;
	wire [EXE_PRIOR-1:0]	sel_prior;
	wire					sel_wb_req_;
	wire [EXE_PRIOR-1:0]	alu_wb_prior;
	wire [EXE_PRIOR-1:0]	div_wb_prior;
	wire [EXE_PRIOR-1:0]	fpu_wb_prior;
	wire [EXE_PRIOR-1:0]	fdiv_wb_prior;
	wire [EXE_PRIOR-1:0]	csr_wb_prior;
	wire [EXE_PRIOR-1:0]	mem_wb_prior;
	wire					alu_wb_sel_;
	wire					div_wb_sel_;
	wire					fpu_wb_sel_;
	wire					fdiv_wb_sel_;
	wire					csr_wb_sel_;
	wire					mem_wb_sel_;



	//***** assign output
	assign sel_wb_req_ = sel_prior[EXE_PRIOR-1];
	assign alu_wb_ack_ = sel_wb_req_ || alu_wb_sel_;
	assign div_wb_ack_ = sel_wb_req_ || div_wb_sel_;
	assign fpu_wb_ack_ = sel_wb_req_ || fpu_wb_sel_;
	assign fdiv_wb_ack_ = sel_wb_req_ || fdiv_wb_sel_;
	assign csr_wb_ack_ = sel_wb_req_ || csr_wb_sel_;
	assign mem_wb_ack_ = sel_wb_req_ || mem_wb_sel_;



	//***** internal assign
	assign alu_wb_prior = {alu_wb_req_, alu_wb_cnt};
	assign div_wb_prior = {div_wb_req_, div_wb_cnt};
	assign fpu_wb_prior = {fpu_wb_req_, fpu_wb_cnt};
	assign fdiv_wb_prior = {fdiv_wb_req_, fdiv_wb_cnt};
	assign csr_wb_prior = {csr_wb_req_, csr_wb_cnt};
	assign mem_wb_prior = {mem_wb_req_, mem_wb_cnt};
	assign sel_in[ALU_IDX] = alu_wb_prior;
	assign sel_in[DIV_IDX] = div_wb_prior;
	assign sel_in[FPU_IDX] = fpu_wb_prior;
	assign sel_in[FDIV_IDX] = fdiv_wb_prior;
	assign sel_in[CSR_IDX] = csr_wb_prior;
	assign sel_in[MEM_IDX] = mem_wb_prior;
	assign alu_wb_sel_ = sel_vec_[ALU_IDX];
	assign div_wb_sel_ = sel_vec_[DIV_IDX];
	assign fpu_wb_sel_ = sel_vec_[FPU_IDX];
	assign fdiv_wb_sel_ = sel_vec_[FDIV_IDX];
	assign csr_wb_sel_ = sel_vec_[CSR_IDX];
	assign mem_wb_sel_ = sel_vec_[MEM_IDX];

	//*** select highest priority unit
	sel_minmax #(
		.MINMAX_	( 1 ),	// minimum
		.IN			( UNIT_NUM ),
		.DATA		( EXE_PRIOR ),
		.ACT		( `Low )
	) sel_minmax (
		.in			( sel_in ),
		.out_vec	( sel_vec_ ),
		.out_idx	(),
		.out		( sel_prior )
	);



	//***** combinational logics
	always_comb begin
		//*** Pre write back select
		unique if ( alu_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = alu_wb_ack_;
			pre_wb_rd = alu_pre_wb_rd;
		end else if ( div_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = div_wb_ack_;
			pre_wb_rd = div_pre_wb_rd;
		end else if ( fpu_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = fpu_wb_ack_;
			pre_wb_rd = fpu_pre_wb_rd;
		end else if ( fdiv_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = fdiv_wb_ack_;
			pre_wb_rd = fdiv_pre_wb_rd;
		end else if ( csr_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = csr_wb_ack_;
			pre_wb_rd = csr_pre_wb_rd;
		end else if ( mem_wb_ack_ == `Enable_ ) begin
			pre_wb_e_ = mem_wb_ack_;
			pre_wb_rd = mem_pre_wb_rd;
		end else begin
			pre_wb_e_ = `Disable_;
			pre_wb_rd = 0;
		end

		//*** write back select
		unique if ( alu_wb_e_ == `Enable_ ) begin
			wb_e_ = alu_wb_e_;
			wb_rd = alu_wb_rd;
			wb_data = alu_wb_data;
			wb_exp_ = alu_wb_exp_;
			wb_exp_code = alu_wb_exp_code;
		end else if ( div_wb_e_ == `Enable_ ) begin
			wb_e_ = div_wb_e_;
			wb_rd = div_wb_rd;
			wb_data = div_wb_data;
			wb_exp_ = div_wb_exp_;
			wb_exp_code = div_wb_exp_code;
		end else if ( fpu_wb_e_ == `Enable_ ) begin
			wb_e_ = fpu_wb_e_;
			wb_rd = fpu_wb_rd;
			wb_data = fpu_wb_data;
			wb_exp_ = fpu_wb_exp_;
			wb_exp_code = fpu_wb_exp_code;
		end else if ( fdiv_wb_e_ == `Enable_ ) begin
			wb_e_ = fdiv_wb_e_;
			wb_rd = fdiv_wb_rd;
			wb_data = fdiv_wb_data;
			wb_exp_ = fdiv_wb_exp_;
			wb_exp_code = fdiv_wb_exp_code;
		end else if ( csr_wb_e_ == `Enable_ ) begin
			wb_e_ = csr_wb_e_;
			wb_rd = csr_wb_rd;
			wb_data = csr_wb_data;
			wb_exp_ = csr_wb_exp_;
			wb_exp_code = csr_wb_exp_code;
		end else if ( mem_wb_e_ == `Enable_ ) begin
			wb_e_ = mem_wb_e_;
			wb_rd = mem_wb_rd;
			wb_data = mem_wb_data;
			wb_exp_ = mem_wb_exp_;
			wb_exp_code = mem_wb_exp_code;
		end else begin
			wb_e_ = `Disable_;
			wb_rd = 0;
			wb_data = 0;
			wb_exp_ = `Disable_;
			wb_exp_code = EXP_I_MISS_ALIGN;
		end
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			alu_wb_cnt <= `AluPrior;
			div_wb_cnt <= `DivPrior;
			fpu_wb_cnt <= `FpuPrior;
			fdiv_wb_cnt <= `FdivPrior;
			csr_wb_cnt <= `CsrPrior;
			mem_wb_cnt <= `MemPrior;
		end else begin
			if ( !alu_wb_req_ && alu_wb_ack_ ) begin
				// writeback blocked
				alu_wb_cnt <= ( alu_wb_cnt == 0 ) ? 0 : alu_wb_cnt - 1;
			end else if ( !alu_wb_ack_ ) begin
				alu_wb_cnt <= `AluPrior;
			end

			if ( !div_wb_req_ && div_wb_ack_ ) begin
				// writeback blocked
				div_wb_cnt <= ( div_wb_cnt == 0 ) ? 0 : div_wb_cnt - 1;
			end else if ( !div_wb_ack_ ) begin
				div_wb_cnt <= `DivPrior;
			end

			if ( !fpu_wb_req_ && fpu_wb_ack_ ) begin
				// writeback blocked
				fpu_wb_cnt <= ( fpu_wb_cnt == 0 ) ? 0 : fpu_wb_cnt - 1;
			end else if ( !fpu_wb_ack_ ) begin
				fpu_wb_cnt <= `FpuPrior;
			end

			if ( !fdiv_wb_req_ && fdiv_wb_ack_ ) begin
				// writeback blocked
				fdiv_wb_cnt <= ( fdiv_wb_cnt == 0 ) ? 0 : fdiv_wb_cnt - 1;
			end else if ( !fdiv_wb_ack_ ) begin
				fdiv_wb_cnt <= `FdivPrior;
			end

			if ( !csr_wb_req_ && csr_wb_ack_ ) begin
				// writeback blocked
				csr_wb_cnt <= ( csr_wb_cnt == 0 ) ? 0 : csr_wb_cnt - 1;
			end else if ( !csr_wb_ack_ ) begin
				csr_wb_cnt <= `CsrPrior;
			end

			if ( !mem_wb_req_ && mem_wb_ack_ ) begin
				// writeback blocked
				mem_wb_cnt <= ( mem_wb_cnt == 0 ) ? 0 : mem_wb_cnt - 1;
			end else if ( !mem_wb_ack_ ) begin
				mem_wb_cnt <= `MemPrior;
			end
		end
	end

endmodule
