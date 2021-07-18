/*
* <ic_ram_block_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "process_config.svh"
`include "cache.svh"
`include "sim.vh"

module ic_ram_block_test;
	parameter STEP = 10;
	parameter LINE = 128;
	parameter DEPTH = 1024;
	//parameter ProcessConf_t PROCESS = `DEFAULT_PROCESS;
	parameter ProcessConf_t PROCESS = XILINX_UP;
	parameter ADDR = $clog2(DEPTH);

	reg				clk;
	reg				reset_;
	reg				en_;
	reg				rw_;
	reg [ADDR-1:0]	addr;
	reg [LINE-1:0]	wdata;
	wire [LINE-1:0]	rdata;

	ic_ram_block #(
		.LINE		( LINE ),
		.DEPTH		( DEPTH ),
		.PROCESS	( PROCESS )
	) ic_ram_block (
		.*
	);

`ifdef VERILATOR
`else
	//***** clock generation
	always #(STEP/2) begin
		clk = ~clk;
	end

	//***** status monitor
	always@( posedge clk ) begin
		if ( en_ == `Enable_ ) begin
			if ( rw_ == `Read ) begin
				`SetCharCyanBold
				$display("Read from ram[%d]", addr);
				@(posedge clk);
				`ResetCharSetting
				$display("    data: %x", rdata);
			end else begin
				`SetCharCyanBold
				$display("Write to ram[%d]", addr);
				`ResetCharSetting
				$display("    data: %x", wdata);
			end
		end
	end

	//***** test util
	task read (
		input [ADDR-1:0]	addr_in
	);
		en_ = `Enable_;
		rw_ = `Read;
		addr = addr_in;
		#(STEP);
		en_ = `Disable_;
		addr = 0;
	endtask

	task write (
		input [ADDR-1:0]	addr_in,
		input [LINE-1:0]	data_in
	);
		en_ = `Enable_;
		rw_ = `Write;
		addr = addr_in;
		wdata = data_in;
		#(STEP);
		en_ = `Disable_;
		addr = 0;
		wdata = 0;
	endtask

	//***** test body
	initial begin
		//*** display ram type
		`SetCharGreenBold
		case ( PROCESS )
			XILINX_7, XILINX_U: $display("Xilinx XPM (block ram)");
			XILINX_UP: $display("Xilinx XPM (UltraRam)");
			default : $display("RTL-based ram model");
		endcase
		`ResetCharSetting

		clk = `Low;
		reset_ = `Enable_;
		en_ = `Disable_;
		rw_ = `READ;
		addr = 0;
		wdata = 0;

		#(STEP);
		reset_ = `Disable_;

		#(STEP);
		write(0, 'hdeadbeef);
		#(STEP);
		write(1, 'hcafecafe);
		#(STEP);
		read(0);
		#(STEP);
		read(1);

		#(STEP);
		$finish();
	end
`endif

endmodule
