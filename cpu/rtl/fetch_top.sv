/*
* <fetch_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.vh"
`include "fetch.svh"

module fetch_top #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_,

	// Fetch Instruction from I-Cache
	input wire				ic_e_,
	output wire [ADDR-1:0]	ic_pc,
	output wire [DATA-1:0]	ic_inst,

	// Fetch request to I-Cache
	output wire				fetch_e_,
	output wire [ADDR-1:0]	fetch_pc
);

	fetch_pc_sel #(
	) fetch_pc_sel (
	);

	fetch_iag #(
	) fetch_iag (
	);

endmodule
