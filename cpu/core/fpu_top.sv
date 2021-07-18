/*
* <fpu_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "decode.svh"
`include "exe.svh"

module fpu_top #(
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				issue_,
	input RegFile_t			rd,
	input wire				data1_e_,
	input wire [DATA-1:0]	data1,
	input wire				data2_e_,
	input wire [DATA-1:0]	data2,
	input DivCommand_t		command,

	input wire				wb_ack_,
	output wire				wb_req_,
	output RegFile_t		pred_wb_rd,

	output wire				wb_e_,
	output RegFile_t		wb_rd,
	output wire [DATA-1:0]	wb_data,
	output wire				wb_exp_,
	output ExpCode_t		wb_exp_code
);

	//***** internal parameters
	localparam LATENCY = `DivLatency;

	//***** internal wires
	wire					exp_;
	wire					exp_code;
	wire [DATA-1:0]			div_res;



	//***** fpu control
	fpu_ctrl #(
		.DATA		( DATA ),
		.LATENCY	( LATENCY )
	) fpu_ctrl (
	);



	//***** fpu execution unit
	//fpu_exe #(
	//) fpu_exe (
	//);

endmodule
