/*
* <alu_br_comp.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exe.svh"
`include "branch.svh"

module alu_br_comp #(
	parameter ADDR = `AddrWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input AluCommand_t			alu_command,
	input wire [ADDR-1:0]		alu_res,

	input RegFile_t				rd,

	input wire [ADDR-1:0]		pred_addr,
	input wire					br_pred,
	output wire [ROB-1:0]		rob_id,

	output logic				pred_miss_,
	output logic				jump_miss_
);

	//***** internal wires
	wire						br_res;

	//***** combinational cells
	logic						branch;
	logic						jump;



	//***** assign output
	assign rob_id = 
		( branch || jump ) ? rd.addr[ROB-1:0] : {ROB{1'b0}};



	//***** assign internal
	assign br_res = ( alu_res[0] == `Enable ) ? `BrTakne : `BrNTaken;


	//***** combinational logics
	always_comb begin
		case ( alu_command.op )
			//*** jump result check
			ALU_ADD : begin
				branch = `Disable;
				pred_miss_ = `Disable_;
				if ( alu_command.sub_op[`AluJump] ) begin
					jump = `Enable; 
					jump_miss_ =
						( alu_res == pred_addr ) ? `Disable_ : `Enable_;
				end
			end

			//*** branch result check
			ALU_COMP : begin
				jump = `Disable;
				jump_miss_ = `Disable_;
				if ( alu_command.sub_op[`AluBranch] ) begin
					branch = `Enable;
					pred_miss_ =
						( br_pred == br_res ) ? `Disable_ : `Enable_;
				end
			end

			//*** no branch/jump insts
			default : begin
				branch = `Disable;
				pred_miss_ = `Disable_;
				jump = `Disable;
				jump_miss_ = `Disable_;
			end
		endcase
	end

endmodule
