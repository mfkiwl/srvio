/*
* <br_status_buf_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"
`include "sim.vh"

module br_status_buf_test;
	parameter STEP = 10;
	parameter shortint DATA = 64;
	parameter shortint DEPTH = 8;
	parameter byte ADDR = $clog2(DEPTH);

	reg				clk;
	reg				reset_;
	reg				we_;		// write enable
	reg [DATA-1:0]	wd;			// write data
	reg				re_;		// read enable
	wire [DATA-1:0]	rd;			// read data
	reg [ADDR-1:0]	exe_st_idx;
	wire [DATA-1:0]	exe_status;
	reg [ADDR-1:0]	wb_st_idx;
	reg				wb_flush_;
	wire [DATA-1:0]	wb_status;
	wire			busy;		// some entry may no be accepted

	br_status_buf #(
		.DATA	( DATA ),
		.DEPTH	( DEPTH )
	) br_status_buf (
		.*
	);

	task validate_status;
		input [DEPTH-1:0]	expected_valid;

		$display("br_status_buf Status Checking...");
`ifdef NETLIST
`else
		$display("    current status: [%8b]", br_status_buf.valid);

		assert (br_status_buf.valid == expected_valid) begin
			`SetCharGreenBold
			$display("    Branch Status is correct");
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("    Branch Status is invalid");
			`ResetCharSetting
			$fatal(1);
		end
`endif
	endtask

`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		we_ = `Disable_;
		wd = 0;
		re_ = `Disable_; 
		exe_st_idx = 0;
		wb_st_idx = 0; 
		wb_flush_ = `Disable_;

		#(STEP);
		reset_ = `Disable_;

		#(STEP);
		// Initilized state : {0, 0, 0, 0, 0, 0, 0, 0}

		// Add 6 Entries : {0, 0, 1, 1, 1, 1, 1, 1,}
		we_ = `Enable_;
		#(STEP*6);
		we_ = `Disable_;
		validate_status(8'b0011_1111);

		#(STEP);
		// Misprediction on 3rd (0-origin) Entry : {0, 0, 0, 0, 1, 1, 1, 1}
		`SetCharCyan
		`SetCharBold
		$display("Partial Flushing Check (Ordered tail and wb_idx) ");
		$display("    Miss prediction on 3rd entry");
		`ResetCharSetting
		#(STEP);
		wb_st_idx = 3;
		wb_flush_ = `Enable_;
		#(STEP);
		wb_flush_ = `Disable_;
		validate_status(8'b0000_1111);
		#(STEP);

		#(STEP);
		// Delete 3 Entries : {0, 0, 0, 0, 1, 0, 0, 0}
		re_ = `Enable_;
		#(STEP*3);
		re_ = `Disable_;
		#(STEP);
		validate_status(8'b0000_1000);
		#(STEP);

		// Add 6entries : {1, 1, 1, 1, 1, 0, 1, 1}
		we_ = `Enable_;
		#(STEP*6);
		we_ = `Disable_;
		#(STEP);
		validate_status(8'b1111_1011);
		#(STEP);

		// delete 3entries : {1, 1, 0, 0, 0, 0, 1, 1}
		re_ = `Enable_;
		#(STEP*3);
		re_ = `Disable_;
		#(STEP);
		validate_status(8'b1100_0011);
		#(STEP);

		// add 2 entries : {1, 1, 0, 0, 1, 1, 1, 1}
		we_ = `Enable_;
		#(STEP*2);
		we_ = `Disable_;
		#(STEP);
		validate_status(8'b1100_1111);
		#(STEP);

		// Mis-Prediction on 1st (0-origin) Entry: {1100_0011)
		wb_st_idx = 1;
		wb_flush_ = `Enable_;
		`SetCharCyan
		`SetCharBold
		$display("Partial Flushing Check (Inverted Tail and wb_idx) ");
		$display("    Miss prediction on 1st entry");
		`ResetCharSetting
		#(STEP);
		wb_flush_ = `Disable_;
		validate_status(8'b1100_0011);
		#(STEP);

		// add 3 entries
		we_ = `Enable_;
		#(STEP*3);
		we_ = `Disable_; 
		#(STEP);
		validate_status(8'b1101_1111);
		#(STEP);

		// Mis-Prediction on 6th (0-origin) Entry: (0100_0000);
		wb_st_idx = 1;
		wb_flush_ = `Enable_;
		`SetCharCyan
		`SetCharBold
		$display("Partial Flushing Check (wb_idx == tail) ");
		$display("    Miss prediction on 6st entry");
		`ResetCharSetting
		#(STEP);
		wb_flush_ = `Enable_;
		wb_st_idx = 'h6;
		#(STEP);
		wb_flush_ = `Disable_;
		validate_status(8'b0100_0000);
		#(STEP);

		// Add 5 More entries : (8'b1100_1111)
		we_ = `Enable_;
		#(STEP*5);
		we_ = `Disable_;
		validate_status(8'b1100_1111);
		#(STEP);

		$finish;
	end

	`include "waves.vh"
`endif

endmodule
