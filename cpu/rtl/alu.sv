/*
* <alu_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "exe.svh"
`include "alu.svh"
`include "exception.svh"

module alu_top #(
	parameter DATA = `DataWidth,
)(
	input wire				clk,
	input wire				reset_,

	input wire				issue_e_,
	input RegFile_t			rd,
	input wire				data1_e_,
	input [DATA-1:0]		data1,
	input wire				data2_e_,
	input [DATA-1:0]		data2,
	input OpCommand_t		command,

	input wire				wb_ack_,
	output wire				wb_req_,

	output wire				wb_e_,
	output RegFile_t		wb_rd,
	output [DATA-1:0]		wb_data,
	output wire				wb_exp_,
	output ExpCode_t		wb_exp_code,

	output wire				busy
);

	//***** status and writeback control
	alu_ctrl #(
	) alu_ctrl (
	);



	//***** integer operations
	alu #(
	) alu (
	);

endmodule
