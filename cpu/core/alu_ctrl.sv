/*
* <alu_ctrl.sv>
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

module alu_ctrl #(
	parameter DATA = `DataWidth
)(
	input wire					clk,
	input wire					reset_,

	input wire					flush_,

	input wire					issue_e_,
	input RegFile_t				rd,
	input wire					exp_,
	input ExpCode_t				exp_code,
	input wire [DATA-1:0]		alu_res,
	input wire					pred_miss_,
	input wire					jump_miss_,

	input wire					wb_ack_,
	output wire					wb_req_,
	output RegFile_t			pre_wb_rd,

	output wire					wb_e_,
	output RegFile_t			wb_rd,
	output wire [DATA-1:0]		wb_data,
	output wire					wb_exp_,
	output ExpCode_t			wb_exp_code,
	output wire					wb_pred_miss_,
	output wire					wb_jump_miss_,

	output wire					busy
);

	//***** internal register
	reg							wb_req_reg_;
	reg							wb_e_reg_;
	RegFile_t					wb_rd_reg;
	reg [DATA-1:0]				wb_data_reg;
	reg							wb_exp_reg_;
	ExpCode_t					wb_exp_code_reg;
	reg							wb_pred_miss_reg_;
	reg							wb_jump_miss_reg_;

	//***** internal wires
	wire						req_grant_;



	//***** assign output
	assign wb_req_ = issue_e_ && wb_req_reg_;
	assign pre_wb_rd = wb_req_reg_ ? rd : wb_rd_reg;
	assign wb_e_ = wb_e_reg_;
	assign wb_rd = wb_rd_reg;
	assign wb_data = wb_data_reg;
	assign wb_exp_ = wb_exp_reg_;
	assign wb_exp_code = wb_exp_code_reg;
	assign wb_pred_miss_ = wb_pred_miss_reg_;
	assign wb_jump_miss_ = wb_jump_miss_reg_;
	assign busy = !wb_req_ && wb_ack_;



	//***** assign internal
	assign req_grant_ = wb_ack_ || wb_req_;



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			wb_req_reg_ <= `Disable_;
			wb_e_reg_ <= `Disable_;
			wb_rd_reg <= 0;
			wb_data_reg <= 0;
			wb_exp_reg_ <= `Disable_;
			wb_exp_code_reg <= EXP_I_MISS_ALIGN;
			wb_pred_miss_reg_ <= `Disable_;
			wb_jump_miss_reg_ <= `Disable_;
		end else begin
			if ( flush_ == `Enable_ ) begin
				wb_req_reg_ <= `Disable_;
				wb_e_reg_ <= `Disable_;
				wb_rd_reg <= 0;
				wb_exp_reg_ <= `Disable_;
				wb_pred_miss_reg_ <= `Disable_;
				wb_jump_miss_reg_ <= `Disable_;
`ifdef DEBUG
				wb_data_reg <= 0;
				wb_exp_code_reg <= EXP_I_MISS_ALIGN;
`endif
			end else begin
				wb_req_reg_ <= !busy;
					//<= ( issue_e_ || req_grant_ ) ? issue_e_ : `Disable_;
				wb_e_reg_ <= req_grant_;

				if ( !issue_e_ || ( wb_req_reg_ == `Disable_ ) ) begin
					wb_rd_reg <= rd;
					wb_exp_reg_ <= exp_;
					wb_exp_code_reg <= exp_code;
					wb_data_reg <= alu_res;
					wb_pred_miss_reg_ <= pred_miss_;
					wb_jump_miss_reg_ <= jump_miss_;
				end
			end
		end
	end

endmodule
