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

	// Interface between I Cache
	ICacheFetchIf.fetch		ic_fetch_if,
	FetchDecIf.fetch		fetch_dec_if
);

	//***** assign output
	assign fetch_dec_if.inst_e_ = ic_fetch_if.ic_e_;
	assign fetch_dec_if.inst_pc = ic_fetch_if.ic_pc;
	assign fetch_dec_if.inst = ic_fetch_if.ic_inst;

	//fetch_pc_sel #(
	//) fetch_pc_sel (
	//);

	//fetch_iag #(
	//) fetch_iag (
	//);

endmodule
