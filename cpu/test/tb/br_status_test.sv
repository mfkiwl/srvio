/*
* <br_status_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "rv_opcodes.svh"
`include "rv_regs.svh"
`include "branch.svh"
`include "sim.vh"

module br_status_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter ROB_DEPTH = `RobDepth;
	parameter PRED_MAX = `PredMaxDepth;
	parameter ROB = $clog2(ROB_DEPTH);

	int							clock_cnt;

	reg							clk;
	reg							reset_; 
	// fetch request
	reg							fetch_stall_;
	reg [ADDR-1:0]				fetch_pc;
	reg							btb_hit;
	reg [ADDR-1:0]				btb_addr;
	BrInstType_t				btb_type;
	reg							br_pred;
	reg							ret_v;
	reg [ADDR-1:0]				ret_pc;
	wire [ADDR-1:0]				next_fetch_pc;
	// fetch
	reg							inst_e_;
	reg [ADDR-1:0]				inst_pc;	// fixed to 0x1000 for debug purpose
	union packed {
		RvJtype_t	jump;
		RvItype_t	jr;
		RvBtype_t	branch;
	}							inst;
	wire						inst_br_;
	wire						inst_call_;
	wire						inst_return_;
	// decode
	reg							dec_br_;
	reg [ROB-1:0]				dec_rob_id;
	// exe
	reg [ROB-1:0]				exe_rob_id;
	wire						exe_br_pred;
	wire [ADDR-1:0]				exe_target;
	// writeback
	reg							wb_e_;
	reg [ROB-1:0]				wb_rob_id;
	reg							wb_pred_miss_;
	reg							wb_jump_miss_;
	reg							wb_br_result;
	reg [ADDR-1:0]				wb_tar_addr;
	wire						wb_flush_;
	// commit
	reg							commit_e_;
	reg [ROB-1:0]				commit_rob_id;
	wire						br_result;
	wire						br_pred_miss_;
	wire						jump_miss_;
	wire						br_commit_;
	wire						jump_commit_;
	wire						jump_call_;
	wire						jump_return_;
	wire [ADDR-1:0]				com_tar_addr;
	wire						pred_busy;

	br_status #(
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH ),
		.PRED_MAX	( PRED_MAX )
	) br_status (
		.*
	);

	//***** clear Signals
	//*** all value related to fetch request
	task clear_fetch_req;
		fetch_stall_ = `Disable_;
		btb_hit = `Disable;
		btb_addr = 0;
		btb_type = BRTYPE_NONE;
		br_pred = `BrTaken;
		ret_v = `Disable;
		ret_pc = 0;
	endtask

	//*** clear all value related to fetch
	task clear_fetch;
		inst_e_ = `Disable_;
		inst_pc = 'h1000;
		inst = 0;
	endtask

	//*** clear all value related to decode
	task clear_dec;
		dec_br_ = `Disable_;
		dec_rob_id = 0; 
	endtask

	//*** clear execution stage request
	task clear_exe;
		exe_rob_id = 0;
	endtask

	//*** clear all value related to writeback
	task clear_wb;
		wb_e_ = `Disable_;
		wb_rob_id = 0;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 0;
	endtask

	//*** clear all value related to commit 
	task clear_commit;
		commit_e_ = `Disable_;
		commit_rob_id = 0;
	endtask



	//***** status check
	//*** execution branch/jump in execution stage
	task check_exe_status;
		input				branch;
		input				expect_br_pred;
		input [ADDR-1:0]	expect_tar_addr;

		$display("Check Branch Status in Execution Status");
		if ( exe_br_pred == `BrTaken ) begin
			$display("    Branch Prediction: Taken");
		end else begin
			$display("    Branch Prediction: Not Taken");
		end
		$display("    Branch Target: 0x%x", exe_target);

		if ( branch ) begin
			// branch
			assert ( exe_br_pred == expect_br_pred )
				else $error("Branch Status Buffer Read Failed");
		end else begin
			// jump
			assert ( exe_target == expect_tar_addr )
				else $error("Branch Status Buffer Read Failed");
		end
	endtask

	task check_com_status;
		input				branch;
		input				expect_br_result;
		input				expect_br_pred_miss_;
		input				expect_jump_miss_;
		input [ADDR-1:0]	expect_com_tar_addr;

		if ( branch ) begin
			// branch
			assert ( expect_br_pred_miss_ == br_pred_miss_ ) begin
			end else begin
				`SetCharBold
				`SetCharRed
				$error("Branch Prediction Miss resutl is incorrect");
				`ResetCharSetting
				$fatal(1);
			end

			assert ( expect_br_result == br_result ) begin
			end else begin
				`SetCharBold
				`SetCharRed
				$error("Branch result is wrong");
				`ResetCharSetting
				$fatal(1);
			end
		end else begin
			// jump
			assert ( com_tar_addr == expect_com_tar_addr ) begin
			end else begin
				`SetCharBold
				`SetCharRed
				$error("Branch Status Buffer Read Failed");
				`ResetCharSetting
				$fatal(1);
			end
		end
	endtask



	//***** Assertion Propertyies
	property fetch_req_check ( pc_match );
		@(posedge clk) $rose(btb_hit) |-> ##0 pc_match;
	endproperty

	property fetch_check ( pc_match );
		@(posedge clk) $fell(inst_e_) |-> ##0 pc_match;
	endproperty

	property wb_miss_check ( pc_match );
		@(posedge clk) $fell(wb_e_) |-> ##[0:1] ( pc_match );
	endproperty



`ifndef VERILATOR
	always #(STEP/2) begin
		clk = ~clk;
	end

	always @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			fetch_pc <= 0;
		end else begin
			fetch_pc <= next_fetch_pc;
		end

		fork
			if ( dec_br_ == `Enable_ ) begin
				#(STEP/2);
				clear_dec;
			end

			if ( inst_e_ == `Enable_ ) begin
				#(STEP/2);
				clear_fetch;
			end

			if ( wb_e_ == `Enable_ ) begin
				#(STEP/2);
				clear_wb;
			end

			if ( commit_e_ == `Enable_ ) begin
				#(STEP/2);
				clear_commit;
			end
		join
	end

	always @( posedge clk ) begin
		$display("@Clock cycle %d", clock_cnt);
		$display("    Fetch pc : 0x%x", fetch_pc);
		$display("    Next Fetch Pc : 0x%x", next_fetch_pc);
		clock_cnt = clock_cnt + 1;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		clear_fetch_req;
		clear_fetch;
		clear_dec;
		clear_exe;
		clear_wb;
		clear_commit;

		#(STEP);
		reset_ = `Disable_;

		//***** start from pc: 0x0
		//	fetch until pc : 0xC
		`SetCharCyan
		`SetCharBold
		$display("Sequential fetch");
		`ResetCharSetting

		#(STEP*4);



		//***** find untracked branch in fetched inst (Branch Hit)
		//	inst pc : 0x1000
		`SetCharCyan
		`SetCharBold
		$display("\nbFind Untracked Branch (Branch Hit)");
		`ResetCharSetting
		assert property(fetch_check(next_fetch_pc == inst_pc+('hf0<<1))) begin
			`SetCharBold
			`SetCharGreen
			$display("Branch is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharBold
			`SetCharRed
			$error("Failed to detect untracked branch");
			`ResetCharSetting
			$fatal(1);
		end
		inst_e_ = `Enable_;
		inst.branch.opcode = `RvOpBranch;
		{inst.branch.imm3, inst.branch.imm2,
			inst.branch.imm1, inst.branch.imm0} = 'hf0;
		#(STEP);
		// add rob_id for this branch
		dec_br_ = `Enable_;
		dec_rob_id = 'h1;
		#(STEP*4);
		// read branch status on execution
		exe_rob_id = 'h1;
		#(STEP);
		check_exe_status(`Enable, `BrTaken, inst_pc+'hf0<<1);
		// write back this branch
		wb_e_ = `Enable_;
		wb_rob_id = 1; 
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 0; 
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h1; 
		check_com_status(`Enable, `BrTaken, `Disable_, `Disable_, 0);
		#(STEP);



		//***** find untracked branch in fetched inst (Branch Miss)
		//	inst pc : 0x1000
		//	branch target pc : 0x1400
		//	fall through address : 0x1004
		`SetCharCyan
		`SetCharBold
		$display("\nFind Untracked Branch (Branch Miss)");
		`ResetCharSetting
		inst_e_ = `Enable_;
		inst.branch.opcode = `RvOpBranch;
		{inst.branch.imm3, inst.branch.imm2,
			inst.branch.imm1, inst.branch.imm0} = 'h400;
		#(STEP);
		dec_br_ = `Enable_;
		dec_rob_id = 'h8;
		#(STEP*4);
		// read branch status on execution
		exe_rob_id = 'h8;
		#(STEP);
		check_exe_status(`Enable, `BrTaken, inst_pc + 'h400<<1);
		// write back this branch
		assert property (wb_miss_check(next_fetch_pc == inst_pc + 'h004) ) begin
			`SetCharBold
			`SetCharGreen
			$display("Branch is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharBold
			`SetCharRed
			$error("Miss Predicted Path is not redirected");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 8; 
		wb_pred_miss_ = `Enable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrNTaken;
		wb_tar_addr = 0; 
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h1; 
		check_com_status(`Enable, `BrNTaken, `Enable_, `Disable_, 0);
		#(STEP);



		//***** Branch Prediction (Taken Branch)
		//	fetch pc : 0x100c
		//	target addr : 0x1_0000
		`SetCharCyanBold
		$display("\nBranch Prediction (Predict Taken Branch)");
		`ResetCharSetting
		assert property (fetch_req_check('h1_0000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("Branch is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Branch Prediction True is not properly processed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h1_0000;
		btb_type = BRTYPE_BRANCH;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		// instruction is fetched
		assert property (fetch_check(fetch_pc != inst_pc)) begin
		end else begin
			$error("Incorrect untracked branch detection");
			$fatal(1);
		end
		inst_e_ = `Enable_;
		inst.branch.opcode = `RvOpBranch;
		{inst.branch.imm3, inst.branch.imm2,
			inst.branch.imm1, inst.branch.imm0} = 'h0;	// target is dummy...
		#(STEP);
		// add rob_id for this branch
		dec_br_ = `Enable_;
		dec_rob_id = 'h2;
		#(STEP*4);
		exe_rob_id = 'h2;
		#(STEP);
		check_exe_status(`Enable, `BrTaken, 0);
		wb_e_ = `Enable_;
		wb_rob_id = 'h2;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 0;
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h2; 
		check_com_status(`Enable, `BrTaken, `Disable_, `Disable_, 0);
		#(STEP);



		//***** Branch Prediction ( Not Taken Branch )
		// fetch pc : 0x10020
		// target addr : 0x10220
		// fall through addr : 0x10024
		`SetCharCyanBold
		$display("\nBranch Prediction (Not Taken Branch)");
		`ResetCharSetting
		assert property (fetch_req_check('h1_0024 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("Branch fell through successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Branch Prediction NotTaken is not properly processed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h1_0220;
		btb_type = BRTYPE_BRANCH;
		br_pred = `BrNTaken;
		#(STEP);
		clear_fetch_req;
		assert property (fetch_check(fetch_pc != inst_pc)) begin
		end else begin
			$error("Incorrect untracked branch detection");
			$fatal(1);
		end
		inst_e_ = `Enable_;
		inst.branch.opcode = `RvOpBranch;
		{inst.branch.imm3, inst.branch.imm2,
			inst.branch.imm1, inst.branch.imm0} = 'h100;	// target is dummy...
		#(STEP);
		// add rob_id for this branch
		dec_br_ = `Enable_;
		dec_rob_id = 'h9;
		#(STEP*4);
		exe_rob_id = 'h9;
		#(STEP);
		check_exe_status(`Enable, `BrNTaken, 0);
		wb_e_ = `Enable_;
		wb_rob_id = 'h9;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrNTaken;
		wb_tar_addr = 0;
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h9; 
		check_com_status(`Enable, `BrNTaken, `Disable_, `Disable_, 0);
		#(STEP*4);



		//***** Jump Target Prediction
		// fetch pc : 0x10050
		// target addr : 0x1000
		`SetCharCyanBold
		$display("\nJump Target Prediction");
		`ResetCharSetting
		assert property (fetch_req_check('h2000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("Jump Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h2000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_;
		inst.jump.opcode = `RvOpJal;
		{inst.jump.imm3, inst.jump.imm2,
			inst.jump.imm1, inst.jump.imm0} = 'h800;
		#(STEP);
		dec_br_ = `Enable_;
		dec_rob_id = 'h5;
		#(STEP*4);
		exe_rob_id = 'h5;
		#(STEP);
		check_exe_status(`Disable, `BrTaken, 'h2000);
		wb_e_ = `Enable_;
		wb_rob_id = 'h5;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h2000;
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h5; 
		check_com_status(`Disable, `BrTaken, `Disable_, `Disable_, 'h2000);
		#(STEP*2);



		//***** JALR Target Prediction (Miss Prediction)
		// fetch pc : 0x2020
		// predicted target : 0x1000
		// true target : 0x1_0000
		`SetCharCyanBold
		$display("\nJALR Target Prediction (Target Miss)");
		`ResetCharSetting
		assert property (fetch_req_check('h1000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("JALR Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction Failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h1000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_;
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		dec_br_ = `Enable_;
		dec_rob_id = 'h4;
		#(STEP*4);
		exe_rob_id = 'h4;
		#(STEP);
		check_exe_status(`Disable, `BrTaken, 'h1000);
		assert property (wb_miss_check(next_fetch_pc == 'h1_0000)) begin
			`SetCharBold
			`SetCharGreen
			$display("JALR is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharBold
			`SetCharRed
			$error("Miss JALR path is not redirected");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h4;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_0000;
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h5; 
		check_com_status(`Disable, `BrTaken, `Disable_, `Enable_, 'h1_0000);
		#(STEP*2);



		//***** Fetch Stall (Just stall)
		fetch_stall_ = `Enable_;
		#(STEP*5);
		fetch_stall_ = `Disable_;



		//***** Fetch Stall (Redirected on writeback)
		// false fetch target : 'h2000
		// true fetch target : 'h1_0000
		// 
		`SetCharCyanBold
		$display("\nFetch Stall (Branch Fetch Stall)");
		`ResetCharSetting
		btb_hit = `Enable;
		btb_addr = 'h2000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		// Assert stall signal at the end of the cache access cycle
		fetch_stall_ = `Enable_;
		#(STEP*4);
		fetch_stall_ = `Disable_;
		assert property (fetch_check (next_fetch_pc != 'h1000)) begin
			`SetCharGreenBold
			$display("JALR after miss is successfully detected 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$display("JALR after miss is falsely detected 0x%x", fetch_pc);
			`ResetCharSetting
			$fatal(1);
		end
		inst_e_ = `Enable_;
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		dec_br_ = `Enable_;
		dec_rob_id = 'h4;
		#(STEP*4);
		exe_rob_id = 'h4;
		#(STEP);
		check_exe_status(`Disable, `BrTaken, 'h2000);
		assert property (wb_miss_check(next_fetch_pc == 'h1_0000)) begin
			`SetCharGreenBold
			$display("JALR is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Miss JALR path is not redirected");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h4;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_0000;
		#(STEP);
		commit_e_ = `Enable_;
		commit_rob_id = 'h5; 
		check_com_status(`Disable, `BrTaken, `Disable_, `Enable_, 'h1_0000);
		#(STEP*4);



		//***** Miss prediction of an already-flushed instruction
		// 1st jump
		//    fetch pc : 1_0010
		//    predicted target : 0x2_0000
		//    true target : 0x1_0000
		// 2nd jump
		//    fetch pc : 1_0010
		//    predicted target : 0x2_5000
		//    true target : don't care
		`SetCharCyanBold
		$display("\nMiss Prediction after partial flush");
		`ResetCharSetting
		assert property (fetch_req_check('h2_0000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("JALR Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction Failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h2_0000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_;
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		// first jump
		dec_br_ = `Enable_;
		dec_rob_id = 'h1;
		// second jump
		assert property (fetch_req_check('h2_5000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("JALR Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction Failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h2_5000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_; 
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		// second jump
		dec_br_ = `Enable_;
		dec_rob_id = 'h3;
		#(STEP*3);
		// first jump
		exe_rob_id = 'h1;
		#(STEP);
		// first jump
		check_exe_status(`Disable, `BrTaken, 'h2_0000);
		assert property (wb_miss_check(next_fetch_pc == 'h1_0000)) begin
			`SetCharGreenBold
			$display("JALR is successfully redirected to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Miss JALR path is not redirected");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h1;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_0000;
		#(STEP);
		// second jump
		exe_rob_id = 'h3;
		#(STEP);
		// second jump
		check_exe_status(`Disable, `BrTaken, 'h2_5000);
		assert property (wb_miss_check(next_fetch_pc != 'h1_5000)) begin
			`SetCharGreenBold
			$display("Flushed jump is successfully ignored");
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Flushed jump falsely takes effect");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h3;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_5000;
		#(STEP*3);
		commit_e_ = `Enable_;
		commit_rob_id = 'h1; 
		check_com_status(`Disable, `BrTaken, `Disable_, `Enable_, 'h1_0000);
		#(STEP*4);



		//***** Miss predictions with reordered branches
		// 1st jump
		//    fetch pc : 1_0020
		//    predicted target : 0x2_0000
		//    true target : 0x1_0000
		// 2nd jump
		//    fetch pc : 2_0004
		//    predicted target : 0x2_5000
		//    true target : don't care
		`SetCharCyanBold
		$display("\nMiss Prediction after partial flush");
		`ResetCharSetting
		assert property (fetch_req_check('h2_0000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("JALR Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction Failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h2_0000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_;
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		// first jump
		dec_br_ = `Enable_;
		dec_rob_id = 'h1;
		// second jump
		assert property (fetch_req_check('h2_5000 == next_fetch_pc)) begin
			`SetCharGreenBold
			$display("JALR Successfully to 0x%x", fetch_pc);
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Jump Prediction Failed");
			`ResetCharSetting
			$fatal(1);
		end
		btb_hit = `Enable;
		btb_addr = 'h2_5000;
		btb_type = BRTYPE_JUMP;
		br_pred = `BrTaken;
		#(STEP);
		clear_fetch_req;
		inst_e_ = `Enable_; 
		inst.jr.opcode = `RvOpJalr;
		inst.jr.imm = 0;
		#(STEP);
		// second jump
		dec_br_ = `Enable_;
		dec_rob_id = 'h3;
		#(STEP*3);
		// execute second jump
		exe_rob_id = 'h3;
		#(STEP);
		// second jump
		check_exe_status(`Disable, `BrTaken, 'h2_5000);
		assert property (wb_miss_check(next_fetch_pc == 'h1_5000)) begin
			`SetCharGreenBold
			$display("Second jump is successfully redirected");
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("Second jump falsely takes effect");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h3;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_5000;
		#(STEP);
		// then first jump
		exe_rob_id = 'h1;
		#(STEP);
		// second jump
		check_exe_status(`Disable, `BrTaken, 'h2_0000);
		assert property (wb_miss_check(next_fetch_pc == 'h1_0000)) begin
			`SetCharGreenBold
			$display("First jump is successfully redirected");
			`ResetCharSetting
		end else begin
			`SetCharRedBold
			$error("First jump falsely takes effect");
			`ResetCharSetting
			$fatal(1);
		end
		wb_e_ = `Enable_;
		wb_rob_id = 'h1;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Enable_;
		wb_br_result = `BrTaken;
		wb_tar_addr = 'h1_0000;
		#(STEP*3);
		commit_e_ = `Enable_;
		commit_rob_id = 'h1; 
		check_com_status(`Disable, `BrTaken, `Disable_, `Enable_, 'h1_0000);
		#(STEP*5);



		$finish;
	end

	`include "waves.vh"
`endif

endmodule
