/*
* <decode_top_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "alu.svh"
`include "mem.svh"
`include "decode.svh"
`include "cpu_if.svh"

module decode_top_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter INST = `InstWidth; 
	parameter DATA = `DataWidth;

	//***** signal
	reg			clk;
	reg			reset_;

	//***** interface instanciation
	FetchDecIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) fetch_dec_if ();

	DecIsIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) dec_is_if ();

	//***** module instanciation
	decode_top #(
		.ADDR			( ADDR ),
		.INST			( INST ),
		.DATA			( DATA )
	) decode_top (
		.clk			( clk ),
		.reset_			( reset_ ),
		.fetch_dec_if	( fetch_dec_if.decode ),
		.dec_is_if		( dec_is_if.decode )
	);


`ifndef VERILATOR
	always #( STEP/2 ) begin
		clk <= ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_; 
		fetch_dec_if.inst_e_ = `Disable_;
		fetch_dec_if.inst_pc = 0; 
		fetch_dec_if.inst = 0;
		dec_is_if.is_full = `Disable;

		#(STEP);
		reset_ = `Disable_;

		#(STEP*5);
		$finish;
	end

	`include "waves.vh"
`endif
	

endmodule
