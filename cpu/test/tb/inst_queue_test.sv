/*
* <inst_queue_test.sv>
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

module inst_queue_test;
	parameter STEP = 10;
	parameter IQ_DEPTH = `IqDepth;
	parameter ROB_DEPTH = `RobDepth;
	parameter IQ = $clog2(IQ_DEPTH);
	parameter ROB = $clog2(ROB_DEPTH);

	reg				clk;
	reg				reset_;
	reg				flush_;
	reg				dec_e_;
	reg				dec_invalid;
	ImmData_t		dec_imm;
	ExeUnit_t		dec_unit;
	OpCommand_t		dec_command;
	RegFile_t		ren_rd;
	RegFile_t		ren_rs1;
	reg				ren_rs1_ready;
	RegFile_t		ren_rs2;
	reg				ren_rs2_ready;
	reg				wb_e_;
	RegFile_t		wb_rd;
	ExeBusy_t		exe_busy;
	reg				commit_e_;
	RegFile_t		commit_rd;
	reg [ROB-1:0]	commit_rob_id;

	wire			issue_e_;
	RegFile_t		issue_rd;
	RegFile_t		issue_rs1;
	RegFile_t		issue_rs2;
	ImmData_t		issue_imm;
	ExeUnit_t		issue_unit;
	OpCommand_t		issue_command;
	wire			busy;

	inst_queue #(
		.IQ_DEPTH	( IQ_DEPTH ),
		.ROB_DEPTH	( ROB_DEPTH )
	) inst_queue (
		.*
	);

`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	always @( posedge clk ) begin
		if ( dec_e_ == `Enable_ ) begin
			`SetCharBold
			`SetCharGreen
			$display("Dispatched");
			`ResetCharSetting
			$display("    dec_iq_id: 0x%x", inst_queue.dec_iq_id);
			$display("    ren_rd: %s, 0x%x",
				ren_rd.regtype.name(), ren_rd.addr);
			$display("    dec_unit: %s", dec_unit.name());
			$display("    dec_imm: %x", dec_imm);
		end

		if ( issue_e_ == `Enable_ ) begin
			`SetCharBold
			`SetCharYellow
			$display("Issued");
			`ResetCharSetting
			$display("    issue_iq_id: 0x%x", inst_queue.issue_iq_id);
			$display("    issue_rd: %s, 0x%x", 
				issue_rd.regtype.name(), issue_rd.addr);
			$display("    issue_unit: %s", issue_unit.name());
			$display("    issue_imm: %x", issue_imm);
		end
	end

	task dec_clear;
		dec_e_ = `Disable_;
		dec_invalid = `Disable;
		dec_imm = 0;
		dec_unit = UNIT_NOP;
		dec_command = 0;
		ren_rd = 0;
		ren_rs1 = 0;
		ren_rs1_ready = `Disable;
		ren_rs2 = 0;
		ren_rs2_ready = `Disable;
	endtask

	task wb_clear;
		exe_busy = 0;
		wb_e_ = `Disable_;
		wb_rd = 0;
	endtask

	task com_clear;
		commit_e_ = `Disable_;
		commit_rd = 0;
		commit_rob_id = 0;
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		flush_ = `Disable_;
		dec_clear;
		wb_clear;
		com_clear;
		#(STEP);
		reset_ = `Disable_;

		//***** Enry Test
		`SetCharBold
		`SetCharCyan
		$display("Entry add and issue test");
		`ResetCharSetting
		#(STEP);
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 0;
		#(STEP);
		dec_clear;
		#(STEP);
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_GPR, addr: 1};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_GPR, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 1;
		#(STEP);
		//*** dispatch and issue at the same clock cycle
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 4};
		ren_rs1 = '{regtype: TYPE_PC, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 1};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 2;
		#(STEP);
		//*** second instruction that dependent on rob[0]
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 5};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 1};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 3;
		#(STEP);
		dec_clear;
		//*** write back
		#(STEP);
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr: 0};
		#(STEP);
		wb_clear;

		//***** Forwarding test (ALU)
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 0;
		#(STEP);
		dec_clear;
		#(STEP);
		//***** Issue stall on execution unit busy
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_ALU;
		dec_imm = 1;
		#(STEP);
		dec_clear;
		#(STEP);
		// writeback
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr : 0};
		#(STEP);
		wb_clear;

		//***** Forwarding test (FPU)
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FPU;
		dec_imm = 0;
		#(STEP);
		//***** Issue stall on execution unit busy
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FPU;
		dec_imm = 1;
		#(STEP);
		dec_clear;
		#(STEP);
		// writeback
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr : 0};
		#(STEP)
		wb_clear;

		#(STEP*2);
		//***** Forwarding test (FDIV)
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 0};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FDIV;
		dec_imm = 0;
		#(STEP);
		//***** Issue stall on execution unit busy
		dec_e_ = `Enable_;
		ren_rd = '{regtype: TYPE_ROB, addr: 3};
		ren_rs1 = '{regtype: TYPE_ROB, addr: 2};
		ren_rs1_ready = `Disable;
		ren_rs2 = '{regtype: TYPE_IMM, addr: 0};
		ren_rs2_ready = `Disable;
		dec_unit = UNIT_FDIV;
		dec_imm = 1;
		#(STEP);
		dec_clear;

		#(STEP);
		// writeback
		wb_e_ = `Enable_;
		wb_rd = '{regtype: TYPE_ROB, addr : 0};

		#(STEP*5);
		$finish;
	end
`endif

`include "waves.vh"

endmodule
