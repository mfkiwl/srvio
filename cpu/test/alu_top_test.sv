/*
* <alu_top_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exe.svh"
`include "decode.svh"
`include "regfile.svh"
`include "exception.svh"
`include "sim.vh"

module alu_top_test;
	parameter STEP = 10;
	parameter DATA = `DataWidth;
	parameter ADDR = `AddrWidth;
	parameter ROB_DEPTH = `RobDepth;
	// constant
	parameter ROB = $clog2(ROB_DEPTH);

	reg					clk;
	reg					reset_;
	reg					flush_;
	reg					issue_e_;
	RegFile_t			rd;
	reg					data1_e_;
	reg [DATA-1:0]		data1;
	reg					data2_e_;
	reg [DATA-1:0]		data2;
	AluCommand_t		command;
	reg [ADDR-1:0]		pred_addr;
	reg					br_pred;
	wire [ROB-1:0]		alu_rob_id;
	reg					wb_ack_;
	wire				wb_req_;
	RegFile_t			pre_wb_rd;
	wire				wb_e_;
	RegFile_t			wb_rd;
	wire [DATA-1:0]		wb_data;
	wire				wb_exp_;
	ExpCode_t			wb_exp_code;
	wire				wb_pred_miss_;
	wire				wb_jump_miss_;
	wire				busy;

	alu_top #(
		.DATA		( DATA ),
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH )
	) alu_top (
		.*
	);

`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	always @( posedge clk ) begin
		if ( issue_e_ == `Enable_ ) begin
			`SetCharMagenta
			$display("Issue");
			`ResetCharSetting
			$display("    rd: %s, 0x%x", rd.regtype.name(), rd.addr);
		end

		if ( wb_e_ == `Enable_ ) begin
			`SetCharYellow
			$display("Writeback");
			`ResetCharSetting
			$display("    wb_rd: %s, 0x%x", wb_rd.regtype.name(), wb_rd.addr);
			$display("    wb_data: 0x%x", wb_data);
		end
	end

	task clear_issue;
		issue_e_ = `Disable_;
		rd = 0;
		data1_e_ = `Disable_;
		data1 = 0;
		data2_e_ = `Disable_;
		data2 = 0;
		command = 0;
	endtask

	task clear_exe;
		pred_addr = 0;
		br_pred = `Low;
	endtask

	task clear_wb;
		wb_ack_ = `Disable_;
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		flush_ = `Disable_;
		issue_e_ = `Disable_;
		rd = 0;
		data1 = 0;
		data1_e_ = `Disable_;
		data2 = 0;
		data2_e_ = `Disable_;
		command = 0;
		pred_addr = 0;
		br_pred = 0;
		wb_ack_ = `Disable_;

		#(STEP);
		reset_ = `Disable_;

		// issue & writeback check
		#(STEP);
		`SetCharBold
		`SetCharCyan
		$display("Issue & Writeback check");
		`ResetCharSetting
		issue_e_ = `Enable_;
		wb_ack_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		#(STEP);
		clear_issue;
		clear_wb;
		#(STEP);

		// issue & writeback (blocked)
		`SetCharBold
		`SetCharCyan
		$display("Issue & Writeback check (blocked)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 1};
		#(STEP);
		clear_issue;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		#(STEP);

		// alu operation check (add, dword)
		`SetCharBold
		`SetCharCyan
		$display("add check (-1+10)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 2};
		data1 = 10;		// 10
		data1_e_ = `Enable_;
		data2 = '1;		// -1
		data2_e_ = `Enable_;
		command.op = ALU_ADD;
		command.sub_op[`AluWord] = `Disable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// internal forwarding
		`SetCharBold
		`SetCharCyan
		$display("add check (Internal Forwarding, -1+9)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 3};
		data1_e_ = `Disable_;	// data1 = 9
		data2 = '1;		// -1
		data2_e_ = `Enable_;
		command.op = ALU_ADD;
		command.sub_op[`AluWord] = `Disable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// alu operation check (add, word)
		`SetCharBold
		`SetCharCyan
		$display("add check (word, -1+10) )");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 3};
		data1 = 10;		// 10
		data1_e_ = `Enable_;
		data2[`Word] = '1;		// -1
		data2_e_ = `Enable_;
		command.op = ALU_ADD;
		command.sub_op[`AluWord] = `Enable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// multiply
		// multiply ( high )
		// multiply ( high, signed/unsigned )
		// multiply ( high, unsigned )

		// compare ( eq, true )
		`SetCharBold
		`SetCharCyan
		$display("Compare Equal (10 == 10)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 10;		// 10
		data1_e_ = `Enable_;
		data2 = 10;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_COMP;
		command.sub_op[`AluCompLt] = `Low;
		command.sub_op[`AluCompNeg] = `Low;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// compare ( eq, false )
		`SetCharBold
		`SetCharCyan
		$display("Compare Equal (10 == 9)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 10;		// 10
		data1_e_ = `Enable_;
		data2 = 9;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_COMP;
		command.sub_op[`AluCompLt] = `Low;
		command.sub_op[`AluCompNeg] = `Low;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// compare ( not eq )
		`SetCharBold
		`SetCharCyan
		$display("Compare Not Equal (10 != 9)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 10;		// 10
		data1_e_ = `Enable_;
		data2 = 9;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_COMP;
		command.sub_op[`AluCompLt] = `Low;
		command.sub_op[`AluCompNeg] = `Enable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// compare ( less than )
		`SetCharBold
		`SetCharCyan
		$display("Compare Not Equal (-1 < 10)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = '1;		// -1
		data1_e_ = `Enable_;
		data2 = 10;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_COMP;
		command.sub_op[`AluCompLt] = `Enable;
		command.sub_op[`AluCompNeg] = `Disable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// compare ( less than, unsigned ) 
		`SetCharBold
		`SetCharCyan
		$display("Compare Not Equal (int max < 10)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = '1;		// -1
		data1_e_ = `Enable_;
		data2 = 10;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_COMP;
		command.sub_op[`AluUnsigned] = `Enable;
		command.sub_op[`AluCompLt] = `Enable;
		command.sub_op[`AluCompNeg] = `Disable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// shift
		`SetCharBold
		`SetCharCyan
		$display("Shift Left (in range)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 1;		// 1
		data1_e_ = `Enable_;
		data2 = 10;		// 10
		data2_e_ = `Enable_;
		command.op = ALU_SHIFT;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// shift left
		`SetCharBold
		`SetCharCyan
		$display("Shift Left (out of range)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 1;		// 1
		data1_e_ = `Enable_;
		data2 = 100;	// 100
		data2_e_ = `Enable_;
		command.op = ALU_SHIFT;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// shift right
		`SetCharBold
		`SetCharCyan
		$display("Shift right (arithmetic, 0b1000..0 >> 10)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 0;
		data1[DATA-1] = 1'b1;
		data1_e_ = `Enable_;
		data2 = 15;	// 15
		data2_e_ = `Enable_;
		command.op = ALU_SHIFT;
		command.sub_op[`AluRight] = `Enable;
		command.sub_op[`AluArith] = `Enable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		// logical operation
		`SetCharBold
		`SetCharCyan
		$display("Logical Operation (And, 0101 & 1111)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 'ha;	// 0101
		data1_e_ = `Enable_;
		data2 = 'hf;	// 1111
		data2_e_ = `Enable_;
		command.op = ALU_LOGIC;
		command.sub_op[`AluLogicOp] = `AluLogicAnd;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		`SetCharBold
		`SetCharCyan
		$display("Logical Operation (Nand, 0101 & 1111)");
		`ResetCharSetting
		issue_e_ = `Enable_;
		rd = '{regtype: TYPE_ROB, addr: 0};
		data1 = 'ha;	// 0101
		data1_e_ = `Enable_;
		data2 = 'hf;	// 1111
		data2_e_ = `Enable_;
		command.op = ALU_LOGIC;
		command.sub_op[`AluLogicOp] = `AluLogicAnd;
		command.sub_op[`AluLogicNeg] = `Enable;
		wb_ack_ = `Enable_;
		#(STEP);
		clear_wb;
		clear_issue;
		#(STEP);

		#(STEP*5);
		$finish;
	end

	`include "waves.vh"
`endif
endmodule
