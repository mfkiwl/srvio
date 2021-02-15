/*
* <scheduler.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module scheduler #(
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				dec_e_,
	input wire				dec_invalid,
	input ImmData_t			imm_data,
	input ExeUnit_t			dec_unit,
	input OpCommand_t		dec_command,
	input wire [ROB-1:0]	dec_rob_id,
	input RegFile_t			ren_rd,
	input RegFile_t			ren_rs1,
	input RegFile_t			ren_rs2,

	input wire				commit_e_,
	input wire [ROB-1:0]	commit_rob_id,

	output wire				issue_e_,
	output wire				issue_rob_id,
	output RegFile_t		issue_rd,
	output RegFile_t		issue_rs1,
	output RegFile_t		issue_rs2,

	output wire				busy
);



endmodule
