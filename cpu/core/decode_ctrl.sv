/*
* <decode_ctrl.sv>
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

module decode_ctrl #(
	parameter ADDR = `AddrWidth
)(
	input wire				clk,
	input wire				reset_,

	// decoder input
	input wire				inst_e_,
	input wire [ADDR-1:0]	inst_pc,

	// status
	input wire				dec_flush_,
	input wire				dec_stop,
	input wire				is_full,

	// simple decoder
	input RegFile_t			rs1_s,
	input RegFile_t			rs2_s,
	input RegFile_t			rd_s,
	input wire				br_s_,
	input wire				jump_s_,
	input wire				invalid_s,
	input ImmData_t			imm_data_s,
	input ExeUnit_t			unit_s,
	input OpCommand_t		command_s,

	// complex decoder
	input RegFile_t			rs1_c,
	input RegFile_t			rs2_c,
	input RegFile_t			rd_c,
	input wire				invalid_c,
	input ImmData_t			imm_data_c,
	input ExeUnit_t			unit_c,
	input OpCommand_t		command_c,

	// output
	output wire				stall,
	output wire				dec_e_,
	output wire [ADDR-1:0]	dec_pc,
	output RegFile_t		rs1,
	output RegFile_t		rs2,
	output RegFile_t		rd,
	output wire				br_,
	output wire				br_pred,
	output wire				jump_,
	output wire				invalid,
	output ImmData_t		imm_data,
	output ExeUnit_t		unit,
	output OpCommand_t		command
);

	//***** internal parameter
	localparam bit SIMPLE_DEC = 1'b0;
	localparam bit COMPLEX_DEC = 1'b1;

	//***** internal wire
	wire				s_c_sel;	// select simple/complex decoder
	RegFile_t			rs1_wire;
	RegFile_t			rs2_wire;
	RegFile_t			rd_wire;
	wire				br_wire_;
	wire				br_pred_wire;
	wire				jump_wire_;
	wire				invalid_wire;
	ImmData_t			imm_data_wire;
	ExeUnit_t			unit_wire;
	OpCommand_t			command_wire;

	//***** pipeline register
	reg					inst_e_p_;
	reg [ADDR-1:0]		inst_pc_p;
	RegFile_t			rs1_p;
	RegFile_t			rs2_p;
	RegFile_t			rd_p;
	reg					br_p_;
	reg					br_pred_p;
	reg					jump_p_;
	reg					invalid_p;
	ImmData_t			imm_data_p;
	ExeUnit_t			unit_p;
	OpCommand_t			command_p;



	//***** assign output
	assign stall = ( is_full || dec_stop ) && !inst_e_p_;
	// TODO: implement complex
	assign dec_e_ = dec_stop || inst_e_p_;
	assign dec_pc = inst_pc_p;
	assign rs1 = rs1_p;
	assign rs2 = rs2_p;
	assign rd = rd_p;
	assign br_ = br_p_;
	assign br_pred = br_pred_p;
	assign jump_ = jump_p_;
	assign invalid = invalid_p;
	assign imm_data = imm_data_p;
	assign unit = unit_p;
	assign command = command_p;



	//***** assign internal
	assign s_c_sel = SIMPLE_DEC;	// TODO :Implement Complex Decoder
	assign rs1_wire = ( s_c_sel == SIMPLE_DEC ) ? rs1_s : rs1_c;
	assign rs2_wire = ( s_c_sel == SIMPLE_DEC ) ? rs2_s : rs2_c;
	assign rd_wire = ( s_c_sel == SIMPLE_DEC ) ? rd_s : rd_c;
	assign br_wire_ = ( s_c_sel == SIMPLE_DEC ) ? br_s_ : `Disable_;
	assign br_pred_wire = `Disable;
	assign jump_wire_ = ( s_c_sel == SIMPLE_DEC ) ? jump_s_ : `Disable_;
	assign invalid_wire = ( s_c_sel == SIMPLE_DEC ) ? invalid_s : invalid_c;
	assign imm_data_wire = ( s_c_sel == SIMPLE_DEC ) ? imm_data_s : imm_data_c;
	assign unit_wire = ( s_c_sel == SIMPLE_DEC ) ? unit_s : unit_c;
	assign command_wire = ( s_c_sel == SIMPLE_DEC ) ? command_s : command_c;


	
	//***** pipeline
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			inst_e_p_ <= `Disable_;
			inst_pc_p <= 0;
			rs1_p <= 0;
			rs2_p <= 0;
			rd_p <= 0;
			br_p_ <= `Disable_;
			br_pred_p <= `Disable;
			jump_p_ <= `Disable_;
			invalid_p <= `Disable;
			imm_data_p <= 0;
			unit_p <= UNIT_NOP;
			command_p <= 0;
		end else begin
			if ( dec_flush_ == `Enable_ ) begin
				inst_e_p_ <= `Disable_;
				inst_pc_p <= 0;
				rs1_p <= 0;
				rs2_p <= 0;
				rd_p <= 0;
				br_p_ <= `Disable_;
				br_pred_p <= `Disable;
				jump_p_ <= `Disable_;
				invalid_p <= `Disable;
				imm_data_p <= 0;
				unit_p <= UNIT_NOP;
				command_p <= 0;
			end else if ( stall == `Disable ) begin
				inst_e_p_ <= inst_e_;
				inst_pc_p <= inst_pc;
				rs1_p <= rs1_wire;
				rs2_p <= rs2_wire;
				rd_p <= rd_wire;
				br_p_ <= br_wire_;
				br_pred_p <= br_pred_wire;
				jump_p_ <= jump_wire_;
				invalid_p <= invalid_wire;
				imm_data_p <= imm_data_wire;
				unit_p <= unit_wire;
				command_p <= command_wire;
			end
		end
	end

endmodule
