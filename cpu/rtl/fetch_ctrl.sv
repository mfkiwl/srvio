/*
* <fetch_ctrl.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module fetch_ctrl #(
	parameter ADDR = `AddrWidth
)(
	input wire				clk,
	input wire				reset_,

	// fetch request
	input wire				fetch_stall_,
	input wire [ADDR-1:0]	next_fetch_pc,
	output wire [ADDR-1:0]	fetch_pc,

	// fetch
	input wire				inst_e_,
	output wire [ADDR-1:0]	inst_pc,

	// decode
	input wire				dec_stall,

	// exe
	input wire				wb_flush_,

	// 
);

endmodule
