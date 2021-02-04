/*
* <fetch_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module fetch_top #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
)(
	input wire				clk,
	input wire				reset_,

	ICacheFetchIf			fetch_ic_if
	//ICacheFetchIf #(
	//	.ADDR	( ADDR ),
	//	.INST	( INST )
	//)						fetch_ic_if

	// Fetch Instruction from I-Cache
	//input wire				ic_e_,
	//input wire [ADDR-1:0]	ic_pc,
	//input wire [INST-1:0]	ic_inst,

	//// Fetch request to I-Cache
	//output wire				fetch_e_,
	//output wire [ADDR-1:0]	fetch_pc
);

	//fetch_pc_sel #(
	//) fetch_pc_sel (
	//);

	//fetch_iag #(
	//) fetch_iag (
	//);

endmodule
