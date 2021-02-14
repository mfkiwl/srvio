/*
* <rob_status_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "rob.svh"
`include "exception.svh"
`include "sim.vh"

//`define DEBUG

module rob_status_test;
	parameter STEP = 10; 
	parameter DATA = `DataWidth;
	parameter ADDR = `AddrWidth;
	parameter ROB_DEPTH = `RobDepth;
	parameter ROB = $clog2(ROB_DEPTH);

	reg				clk;
	reg				reset_;

	reg				dec_e_;
	reg [ADDR-1:0]	dec_pc;
	RegFile_t		dec_rd;
	reg				dec_br_;
	reg				dec_br_pred_taken_;
	reg				dec_jump_;
	reg				dec_invalid;
	wire [ROB-1:0]	dec_rob_id;

	reg				wb_e_;
	reg [ROB-1:0]	wb_rob_id;
	reg				wb_exp_;
	ExpCode_t		wb_exp_code;
	reg				wb_pred_miss_;
	reg				wb_jump_miss_;
	wire			commit_e_;
	wire			flush_;
	wire [ADDR-1:0]	com_pc;
	RegFile_t		com_rd;
	wire			com_exp_;
	ExpCode_t		com_exp_code;
	wire [ROB-1:0]	com_rob_id;
	wire			rob_busy;

	//***** for verification
	bit [ROB-1:0]	rob_id_history [$];
	int				index;


	rob_status #(
		.DATA		( DATA ),
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH )
	) rob_status (
		.*
	);



`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	always @(posedge clk ) begin
		if ( wb_e_ == `Enable_ ) begin
			$display("writeback, rob-id[%x]", wb_rob_id);
		end

		if ( commit_e_ == `Enable_ ) begin
			$display("instruction commit, pc[%x]", com_pc);

			if ( com_exp_ == `Enable_ ) begin
				$display("Exception occur, code[%x]",com_exp_code);
			end else if ( flush_ == `Enable_ ) begin
				$display("pipeline flushed");
			end
		end
	end

	task dec_clear;
		dec_e_ = `Disable_;
		dec_pc = 0;
		dec_rd = 0;
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = 0;
	endtask

	task wb_clear;
		wb_e_ = `Disable_;
		wb_rob_id = 0;
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		//*** decode
		dec_e_ = `Disable_;
		dec_pc = 0;
		dec_rd = 0;
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = 0;
		//*** writeback
		wb_e_ = `Disable_;
		wb_rob_id = 0;
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;

		#(STEP);
		reset_ = `Disable_;

		//***** normal instruction
		`SetCharBold
		`SetCharCyan
		$display("normal instruction");
		`ResetCharSetting
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 1};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		#(STEP);
		wb_clear;


		// branch ( prediction hit )
		`SetCharBold
		`SetCharCyan
		$display("Branch (Prediction hit)");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		#(STEP);
		wb_clear;

		// branch ( prediction miss )
		`SetCharBold
		`SetCharCyan
		$display("Branch (Prediction miss)");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Enable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Enable_;
		wb_jump_miss_ = `Disable_;
		#(STEP);
		wb_clear;

		// jump ( target hit )
		`SetCharBold
		`SetCharCyan
		$display("Jump (target hit)");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Enable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		#(STEP);
		wb_clear;

		// jump ( target miss )
		`SetCharBold
		`SetCharCyan
		$display("Jump (target miss)");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Enable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		#(STEP);
		wb_clear;

		//***** normal instruction ( exception )
		`SetCharBold
		`SetCharCyan
		$display("normal instruction (exception)");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rob_id = rob_id_history.pop_front();
		wb_exp_ = `Enable_;
		wb_exp_code = EXP_I_FAULT;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		#(STEP);
		wb_clear;

		// invalid instruction
		`SetCharBold
		`SetCharCyan
		$display("invalid instruction");
		`ResetCharSetting
		#(STEP*5);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Enable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;
		#(STEP*5);


		//***** reorder test
		`SetCharBold
		`SetCharCyan
		$display("reordering test");
		`ResetCharSetting
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0004;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0008;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe000c;
		dec_rd = '{regtype: TYPE_GPR, addr: 4};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0010;
		dec_rd = '{regtype: TYPE_GPR, addr: 5};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0014;
		dec_rd = '{regtype: TYPE_GPR, addr: 6};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0018;
		dec_rd = '{regtype: TYPE_GPR, addr: 6};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe001c;
		dec_rd = '{regtype: TYPE_GPR, addr: 6};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_clear;

		#(STEP*5);

		while ( rob_id_history.size > 0 ) begin
			wb_e_ = `Enable_;
			index = $urandom_range(0,rob_id_history.size-1);
			wb_rob_id = rob_id_history[index];
			rob_id_history.delete(index);
			wb_exp_ = `Disable_;
			wb_exp_code = EXP_I_MISS_ALIGN;
			wb_pred_miss_ = `Disable_;
			wb_jump_miss_ = `Disable_;
			#(STEP);
			wb_clear;
			#(STEP);
		end


		#(STEP*5);
		$finish;
	end

	`include "waves.vh"

`endif


endmodule
