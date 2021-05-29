/*
* <inst_sched_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "decode.svh"
`include "issue.svh"
`include "exe.svh"
`include "sim.vh"

//`define DEBUG

module inst_sched_test;
	parameter STEP = 10;
	parameter IQ_DEPTH = `IqDepth;
	parameter ROB_DEPTH = `RobDepth;
	parameter IQ = $clog2(IQ_DEPTH);
	parameter ROB = $clog2(ROB_DEPTH);

	//*****
	reg				clk;
	reg				reset_;

	reg				flush_;

	reg				add_entry_;
	RegFile_t		ren_rd;
	RegFile_t		ren_rs1;
	reg				ren_rs1_ready;
	RegFile_t		ren_rs2;
	reg				ren_rs2_ready;
	ExeUnit_t		dec_unit;
	reg [IQ-1:0]	dec_iq_id;

	ExeBusy_t		exe_busy;
	reg				wb_e_;
	RegFile_t		wb_rd;

	reg				commit_e_;
	RegFile_t		commit_rd;
	reg [ROB-1:0]	commit_rob_id;

	wire			issue_e_;
	wire [IQ-1:0]	issue_iq_id;
	RegFile_t		issue_rd;
	RegFile_t		issue_rs1;
	RegFile_t		issue_rs2;
	ExeUnit_t		issue_unit;

	inst_sched #(
		.IQ_DEPTH	( IQ_DEPTH ),
		.ROB_DEPTH	( ROB_DEPTH )
	) inst_sched (
		.*
	);

`ifndef VERILATOR
	always #( STEP/2 ) begin
		clk = ~clk;
	end

	always @( posedge clk ) begin
		if ( add_entry_ == `Enable_ ) begin
			`SetCharMagenta
			$display("Dispatched");
			`ResetCharSetting
			$display("    dec_iq_id: 0x%x", dec_iq_id);
			$display("    ren_rd: %s, 0x%x",
				ren_rd.regtype.name(), ren_rd.addr);
			$display("    dec_unit: %s", dec_unit.name());
		end

		if ( issue_e_ == `Enable_ ) begin
			`SetCharYellow
			$display("Issued");
			`ResetCharSetting
			$display("    issue_iq_id: 0x%x", issue_iq_id);
			$display("    issue_rd: %s, 0x%x", 
				issue_rd.regtype.name(), issue_rd.addr);
			$display("    issue_unit: %s", issue_unit.name());
		end
	end

	task dec_clear;
		add_entry_ = `Disable_;
		ren_rd = 0;
		ren_rs1 = 0;
		ren_rs1_ready = `Disable;
		ren_rs2 = 0;
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_NOP;
		dec_iq_id = 0;
	endtask

	task wb_clear;
		exe_busy = 0;
		wb_e_ = `Disable_;
		wb_rd = 0;
	endtask

	task commit_clear;
		commit_e_ = `Disable_;
		commit_rd = 0;
		commit_rob_id = 0;
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		flush_ = `Disable_;
		add_entry_ = `Disable_;
		ren_rd = 0;
		ren_rs1 = 0;
		ren_rs1_ready = `Disable;
		ren_rs2 = 0;
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_NOP;
		dec_iq_id = 0;
		exe_busy = 0;
		wb_e_ = `Disable_;
		wb_rd = 0;
		commit_e_ = `Disable_;
		commit_rd = 0;
		commit_rob_id = 0;
		#(STEP);
		reset_ = `Disable_;

		//***** Entry test
		//		issue order:
		//		iq_id[1] -> iq_id[2] -> iq_id[0] -> iq_id[3]
		$display("Entry add and issue test");
		#(STEP);
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 0;
		#(STEP);
		dec_clear;
		#(STEP);
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_GPR, addr: 1};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_GPR, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 1;
		#(STEP);
		//*** dispatch and issue at the same clock cycle
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 4};
		ren_rs1 = '{regtype: TYPE_PC, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 1};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 2;
		#(STEP);
		//*** second instruction that dependent on rob[0]
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 5};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 1};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 3;
		#(STEP);
		dec_clear;
		//*** write back
		#(STEP);
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr: 0};
		#(STEP);
		wb_clear;

		#(STEP*5);
		reset_ = `Enable_;
		#(STEP);
		reset_ = `Disable_;
		#(STEP*5);

		//***** Forwarding test (ALU)
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 0;
		#(STEP);
		//***** Issue stall on execution unit busy
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_iq_id = 0;
		#(STEP);
		dec_clear;
		#(STEP);
		// writeback
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr : 0};

		#(STEP*5);

		//***** Forwarding test (FPU)
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FPU;
		dec_iq_id = 0;
		#(STEP);
		//***** Issue stall on execution unit busy
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FPU;
		dec_iq_id = 0;
		#(STEP);
		dec_clear;
		#(STEP);
		// writeback
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr : 0};

		#(STEP*5);

		//***** Forwarding test (FDIV)
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FDIV;
		dec_iq_id = 0;
		#(STEP);
		//***** Issue stall on execution unit busy
		add_entry_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FDIV;
		dec_iq_id = 0;
		#(STEP);
		dec_clear;

		#(STEP*5);
		$finish;
	end

	`include "waves.vh"
`endif

endmodule
