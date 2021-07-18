/*
* <div_ctrl.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exe.svh"
`include "exception.svh"

module div_ctrl #(
	parameter DATA = `DataWidth,
	parameter LATENCY = `DivLatency
)(
	input wire					clk,
	input wire					reset_,

	input wire					flush_,

	input wire					issue_e_,
	input RegFile_t				rd,

	input wire					exp_,
	input ExpCode_t				exp_code,
	input wire [DATA-1:0]		div_res,

	input wire					wb_ack_,
	output wire					wb_req_,
	output RegFile_t			pre_wb_rd,

	output wire					wb_e_,
	output RegFile_t			wb_rd,
	output wire [DATA-1:0]		wb_data,
	output wire					wb_exp_,
	output ExpCode_t			wb_exp_code,

	output wire					busy
);

	//***** internal register
	reg						wb_e_reg_;
	reg [DATA-1:0]			wb_data_reg;
	reg						wb_exp_reg_;
	ExpCode_t				wb_exp_code_reg;
	//*** pipeline
	reg [LATENCY-1:0]		op_e;
	RegFile_t [LATENCY-1:0]	wb_rd_reg;

	//***** internal wires
	wire					req_grant_;

	//***** combinational cells
	logic					next_wb_e_;
	logic					next_wb_exp_;
	ExpCode_t				next_wb_exp_code;
	logic [DATA-1:0]		next_wb_data;
	//*** pipeline
	logic [LATENCY-1:0]		next_op_e;
	RegFile_t [LATENCY-1:0]	next_wb_rd;
	logic [LATENCY-1:0]		stall;



	//***** assign output
	// TODO: implement pipelined divider
	//		Currently disable
	assign wb_req_ = !op_e[LATENCY-2];
	assign pre_wb_rd = wb_rd_reg[LATENCY-2];
	assign wb_e_ = !op_e[LATENCY-1];
	assign wb_rd = wb_rd_reg[LATENCY-1];
	assign wb_data = wb_data_reg;
	assign wb_exp_ = wb_exp_reg_;
	assign wb_exp_code = wb_exp_code_reg;
	assign busy = op_e[0] && stall[0];



	//***** assign internal
	assign req_grant_ = wb_ack_ || wb_req_;


	//***** combinational logics
	always_comb begin
		int i;

		next_wb_e_ = req_grant_;

		//*** pipeline
		if ( !issue_e_ ) begin
			next_op_e[0] = `Enable;
			next_wb_rd[0] = rd;
		end else if ( op_e[0] && stall ) begin
			next_op_e[0] = op_e[0];
			next_wb_rd[0] = wb_rd_reg[0];
		end else begin
			next_op_e[0] = `Disable;
			next_wb_rd[0] = 0;
		end
		for ( i = 1; i < LATENCY; i = i + 1 ) begin
		end
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		int i;
		if ( reset_ == `Enable_ ) begin
			op_e <= {LATENCY{`Disable}};
			wb_e_reg_ <= `Disable_;
			wb_data_reg <= 0;
			wb_exp_reg_ <= `Disable_;
			wb_exp_code_reg <= EXP_I_MISS_ALIGN;	// == 0
			wb_rd_reg <= 0;
		end else begin
			if ( flush_ == `Enable_ ) begin
				op_e <= {LATENCY{`Disable}};
				wb_e_reg_ <= `Disable_;
				wb_exp_reg_ <= `Disable_;
`ifdef DEBUG
				wb_exp_code_reg <= EXP_I_MISS_ALIGN;	// == 0
				for ( i = 0; i < LATENCY; i = i + 1 ) begin
					wb_rd_reg[i] <= 0;
					wb_data_reg[i] <= 0;
				end
`endif
			end else begin
				op_e <= next_op_e;
				wb_e_reg_ <= next_wb_e_;
				wb_data_reg <= wb_data_reg;
				wb_exp_reg_ <= exp_;
				wb_exp_code_reg <= exp_code;
				wb_rd_reg<= next_wb_rd;
			end
		end
	end

endmodule
