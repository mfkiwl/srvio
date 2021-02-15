/*
* <reorder_buffer_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exception.svh"
`include "sim.vh"

//`define DEBUG

module reorder_buffer_test;
	parameter STEP = 10;
	parameter DATA = `DataWidth;
	parameter ADDR = `AddrWidth;
	parameter ROB_DEPTH = `RobDepth;
	parameter ROB = $clog2(ROB_DEPTH);

	reg				clk;
	reg				reset_;

	reg				creg_exp_mask;
	reg [DATA-1:0]	creg_tvec;

	reg				dec_e_;
	reg [ADDR-1:0]	dec_pc;
	RegFile_t		dec_rd;
	RegFile_t		dec_rs1;
	RegFile_t		dec_rs2;
	reg				dec_br_;
	reg				dec_br_pred_taken_;
	reg				dec_jump_;
	reg				dec_invalid;

	reg				wb_e_;
	RegFile_t		wb_rd;
	reg [DATA-1:0]	wb_data;
	reg				wb_exp_;
	ExpCode_t		wb_exp_code;
	reg				wb_pred_miss_;
	reg				wb_jump_miss_;

	wire [ROB-1:0]	dec_rob_id;
	RegFile_t		ren_rs1;
	RegFile_t		ren_rs2;
	RegFile_t		ren_rd;
	wire			commit_e_;
	wire			flush_;
	wire [ADDR-1:0]	commit_pc;
	RegFile_t		commit_rd;
	wire			commit_exp_;
	ExpCode_t		commit_exp_code;
	wire [ADDR-1:0]	exp_handler_pc;
	wire [DATA-1:0]	commit_data;
	wire [ROB-1:0]	commit_rob_id;
	wire			rob_busy;

	//***** for verification
	RegFile_t		rob_id_history [$];
	int				index;

	reorder_buffer #(
		.DATA		( DATA ),
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH )
	) rob (
		.*
	);

`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	always @(posedge clk ) begin
		if ( dec_e_ == `Enable_ ) begin
			`SetCharGreen
			$display("instruction decode, pc[0x%x]", dec_pc);
			`ResetCharSetting
			$display("    rob-id[0x%x]", dec_rob_id);
			$display("    decode destination[0x%x]", dec_rd);
			$display("    renamed destination[0x%x]", ren_rd);
			$display("    decode source 1[0x%x]", dec_rs1);
			$display("    renamed source 1[0x%x]", ren_rs1);
			$display("    decode source 2[0x%x]", dec_rs2);
			$display("    renamed source 2[0x%x]", ren_rs2);
		end

		if ( wb_e_ == `Enable_ ) begin
			`SetCharYellow
			$display("writeback, rob-id[0x%x]", wb_rd.addr);
			`ResetCharSetting

			$display("    data[0x%x]", wb_data);
		end

		if ( commit_e_ == `Enable_ ) begin
			`SetCharMagenta
			$display("instruction commit, pc[0x%x]", commit_pc);
			`ResetCharSetting

			if ( commit_exp_ == `Enable_ ) begin
				$display("    Exception occur, code[0x%x]",commit_exp_code);
			end else if ( flush_ == `Enable_ ) begin
				$display("    pipeline flushed");
			end

			$display("    rob-id[0x%x]", commit_rob_id);
			$display("    rd[0x%x]", commit_rd);
			$display("    data[0x%x]", commit_data);
		end
	end

	task dec_clear;
		dec_e_ = `Disable_;
		dec_pc = 0;
		dec_rd = 0;
		dec_rs1 = 0;
		dec_rs2 = 0;
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = 0;
	endtask

	task wb_clear;
		wb_e_ = `Disable_;
		wb_rd = 0;
		wb_data = 0;
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		//*** creg
		creg_exp_mask = `Disable;
		creg_tvec = {30'hcafe<<2,2'b00};
		//*** decode
		dec_clear;
		//*** writeback
		wb_clear;

		#(STEP);
		reset_ = `Disable_;

		//***** normal instruction
		`SetCharBold
		`SetCharCyan
		$display("normal instruction");
		`ResetCharSetting
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hbeef0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 1};
		dec_rs1 = '{regtype: TYPE_GPR, addr: 2};
		dec_rs2 = '{regtype: TYPE_IMM, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
		wb_data = 'haaaa;
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
		dec_pc = 'hbeef0004;
		dec_rd = '{regtype: TYPE_NONE, addr: 0};
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};
		dec_rs2 = '{regtype: TYPE_GPR, addr: 3};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
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
		dec_pc = 'hbeef0008;
		dec_rd = '{regtype: TYPE_NONE, addr: 0};
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};
		dec_rs2 = '{regtype: TYPE_GPR, addr: 2};
		dec_br_ = `Enable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
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
		dec_pc = 'hbeef000c;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};
		dec_rs2 = '{regtype: TYPE_IMM, addr: 2};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Enable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
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
		dec_pc = 'hbeef0010;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};
		dec_rs2 = '{regtype: TYPE_IMM, addr: 2};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Enable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP*3);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		#(STEP);
		wb_clear;

		#(STEP*5);
		reset_ = `Enable_;
		#(STEP);
		reset_ = `Disable_;

		//***** reorder test
		`SetCharBold
		`SetCharCyan
		$display("reordering test");
		`ResetCharSetting
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 1};		// rename to rob[0]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 0};
		dec_rs2 = '{regtype: TYPE_IMM, addr: 0};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0004;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};		// rename to rob[1]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};	// rename to rob[0]
		dec_rs2 = '{regtype: TYPE_IMM, addr: 0};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0008;
		dec_rd = '{regtype: TYPE_GPR, addr: 3};		// rename to rob[2]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};	// rename to rob[0]
		dec_rs2 = '{regtype: TYPE_GPR, addr: 2};	// rename to rob[1]
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe000c;
		dec_rd = '{regtype: TYPE_GPR, addr: 4};		// rename to rob[3]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 2};	// rename to rob[1]
		dec_rs2 = '{regtype: TYPE_GPR, addr: 3}; 	// rename to rob[2]
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0010;
		dec_rd = '{regtype: TYPE_GPR, addr: 5};		// rename to rob[4]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 3};	// rename to rob[2]
		dec_rs2 = '{regtype: TYPE_GPR, addr: 1};	// rename to rob[0]
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0014;
		dec_rd = '{regtype: TYPE_GPR, addr: 4};		// rename to rob[5] (invalidate rename(rob[3]) )
		dec_rs1 = '{regtype: TYPE_GPR, addr: 5};	// rename to rob[4]
		dec_rs2 = '{regtype: TYPE_GPR, addr: 3};	// rename to rob[2]
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe0018;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};		// rename to rob[6] (invalidate rename(rob[1]) )
		dec_rs1 = '{regtype: TYPE_GPR, addr: 4};	// rename to rob[5]
		dec_rs2 = '{regtype: TYPE_GPR, addr: 3};	// rename to rob[2]
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(dec_rob_id);
		#(STEP);
		dec_e_ = `Enable_;
		dec_pc = 'hcafe001c;
		dec_rd = '{regtype: TYPE_GPR, addr: 7};		// rename to rob[7]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 6};	// not renamed
		dec_rs2 = '{regtype: TYPE_GPR, addr: 2};	// rename to rob[6]
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
			wb_rd = rob_id_history[index];
			rob_id_history.delete(index);
			wb_data = $urandom();
			wb_exp_ = `Disable_;
			wb_exp_code = EXP_I_MISS_ALIGN;
			wb_pred_miss_ = `Disable_;
			wb_jump_miss_ = `Disable_;
			#(STEP);
			wb_clear;
			#(STEP);
		end

		#(STEP*10);

		reset_ = `Enable_;
		#(STEP);
		reset_ = `Disable_;
		#(STEP);


		//***** rename test
		//	destination of commited instruction and 
		//		source of decode instruction are the same
		`SetCharBold
		`SetCharCyan
		$display("rename test");
		`ResetCharSetting
		dec_e_ = `Enable_;
		dec_pc = 'hbeef0000;
		dec_rd = '{regtype: TYPE_GPR, addr: 1};		// rename to rob[0]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 0};
		dec_rs2 = '{regtype: TYPE_IMM, addr: 0};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		wb_clear;
		dec_e_ = `Enable_;
		dec_pc = 'hbeef0004;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};		// rename to rob[0]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};	// must not be renamed
		dec_rs2 = '{regtype: TYPE_GPR, addr: 1};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;
		#(STEP);
		wb_e_ = `Enable_;
		wb_rd = rob_id_history.pop_front();
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		#(STEP);
		wb_clear;
		dec_e_ = `Enable_;
		dec_pc = 'hbeef0004;
		dec_rd = '{regtype: TYPE_GPR, addr: 2};		// rename to rob[0]
		dec_rs1 = '{regtype: TYPE_GPR, addr: 1};	// must not be renamed
		dec_rs2 = '{regtype: TYPE_GPR, addr: 1};
		dec_br_ = `Disable_;
		dec_br_pred_taken_ = `Disable_;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		rob_id_history.push_back(ren_rd);
		#(STEP);
		dec_clear;

		#(STEP*5);
		$finish;
	end

	`include "waves.vh"
`endif

endmodule
