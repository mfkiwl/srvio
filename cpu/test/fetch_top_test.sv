/*
* <fetch_top_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module fetch_top_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter INST = `InstWidth;

	reg		clk ;
	reg		reset_;

	ICacheFetchIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_ic_if();

	FetchDecIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_dec_if();
	
	fetch_top #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_top (
		.clk			( clk ),
		.reset_			( reset_ ),
		.fetch_ic_if	( fetch_ic_if.fetch ),
		.fetch_dec_if	( fetch_dec_if.fetch )
	);

`ifndef VERILATOR
	always #( STEP/2 ) begin
		clk <= ~clk;
	end

	initial begin
		clk = `Low;
		reset_ <= `Enable_;

		#(STEP*5);
		$finish;
	end

 `ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
 `endif
`endif

endmodule
