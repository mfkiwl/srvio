/*
* <fetch_ctrl_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module fetch_ctrl_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;

	//***** signals
	logic				clk;
	logic				reset_;
	logic				ic_stall_;
	logic [ADDR-1:0]	next_fetch_pc;
	wire [ADDR-1:0]		fetch_pc;
	wire				fetch_stall_;
	wire				inst_e_;
	wire [ADDR-1:0]		inst_pc;
	logic				dec_stall;
	logic				wb_flush_;

	//***** module instance
	fetch_ctrl #(
		.ADDR	( ADDR )
	) fetch_ctrl (
		.*
	);

`ifdef VERILATOR
`else
	always #(STEP/2) begin
		clk <= ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		ic_stall_ = `Disable_;
		next_fetch_pc = 0;
		dec_stall = `Disable;
		wb_flush_ = `Disable_;

		#(STEP);
		reset_ = `Disable_;

		#(STEP*5);
	end
`endif

endmodule
