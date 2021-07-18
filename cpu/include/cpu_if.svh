/*
* <cpu_if.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _CPU_IF_SVH_INCLUDED_
`define _CPU_IF_SVH_INCLUDED_

//***** include dependent headers files
`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exe.svh"
`include "decode.svh"
`include "issue.svh"



//***** Instruction Cache and Fetch Stage Interface
interface ICacheFetchIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//*** ICache to Fetch Stage
	logic [INST-1:0]	ic_inst;
	logic				ic_stall;

	//*** Fetch Stage to ICache
	logic				fetch_e_;
	logic [ADDR-1:0]	fetch_pc;

	//*** Instruction Cache side signals
	modport icache(
		input	fetch_e_,
		input	fetch_pc,
		output 	ic_inst,
		output	ic_stall
	);

	//*** Fetch Stage side signals
	modport fetch(
		input 	ic_inst,
		input	ic_stall,
		output	fetch_e_,
		output	fetch_pc
	);

`ifdef SIMULATION
	//*** initialization
	task initialize_icache;
		fetch_e_ = `Disable_;
		fetch_pc = 0;
	endtask

	task initialize_fetch;
		ic_inst = 0;
		ic_stall = `Disable;
	endtask

	//*** debug
	bit [INST-1:0]			debug_rom [1024-1:0];

	task initialize_debug_rom (
		input string		format,
		input string		filename
	);
		if ( format == "b" ) begin
			// binary formalt
			$readmemb(filename, debug_rom);
		end else begin
			// hexadecimal format
			$readmemh(filename, debug_rom);
		end
	endtask

	task write_debug_rom (
		input bit [ADDR-1:0]	addr,
		input bit [INST-1:0]	inst
	);
		debug_rom[addr] = inst;
	endtask

	function [INST-1:0] read_debug_rom;
		if ( ic_stall == `Enable || fetch_e_ == `Disable_ ) begin
			read_debug_rom = {INST{1'b0}};
		end else begin
			read_debug_rom = debug_rom[fetch_pc[ADDR-1:2]];
		end
	endfunction
`endif

endinterface : ICacheFetchIf



//***** Fetch and Decode Interface
interface FetchDecIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//*** Fetch to Decode Stage
	logic				inst_e_;
	logic [ADDR-1:0]	inst_pc;
	logic [INST-1:0]	inst;
	logic				dec_flush_;
	logic				dec_stop;	// Stop decode until 
									//     miss predicted branch is commited

	//*** Decode to Fetch Stage
	logic				dec_stall;

	//*** Fetch Stage side signals
	modport fetch (
		input	dec_stall,
		output	inst_e_,
		output	inst_pc,
		output	inst,
		output	dec_flush_,
		output	dec_stop
	);

	//*** Decode Stage side signals
	modport decode (
		input	inst_e_,
		input	inst_pc,
		input	inst,
		input	dec_flush_,
		input	dec_stop,
		output	dec_stall
	);

`ifdef SIMULATION
	task initialize_fetch;
		dec_stall = `Disable;
	endtask

	task initialize_decode;
		inst_e_ = `Disable_;
		inst_pc = 0;
		inst = 0;
		dec_stop = `Disable;
	endtask
`endif

endinterface : FetchDecIf



//***** Decode and Issue Interface
interface DecIsIf #(
	parameter ADDR = `AddrWidth
);

	//*** Decode to Issue
	logic				dec_e_;
	logic [ADDR-1:0]	dec_pc;
	RegFile_t			dec_rd;
	RegFile_t			dec_rs1;
	RegFile_t			dec_rs2;
	logic				dec_br_;
	logic				dec_br_pred;
	logic				dec_jump_;
	logic				dec_invalid;
	ImmData_t			dec_imm;
	ExeUnit_t			dec_unit;
	OpCommand_t			dec_command;

	//*** Issue to Decoder
	logic				is_full;

	//*** Decode Stage side signals
	modport decode (
		input	is_full,
		output	dec_e_,
		output	dec_pc,
		output	dec_rd,
		output	dec_rs1,
		output	dec_rs2,
		output	dec_br_,
		output	dec_br_pred,
		output	dec_jump_,
		output	dec_invalid,
		output	dec_imm,
		output	dec_unit,
		output	dec_command
	);

	//*** Issue side signals
	modport issue (
		input	dec_e_,
		input	dec_pc,
		input	dec_rd,
		input	dec_rs1,
		input	dec_rs2,
		input	dec_br_,
		input	dec_br_pred,
		input	dec_jump_,
		input	dec_invalid,
		input	dec_imm,
		input	dec_unit,
		input	dec_command,
		output	is_full
	);

`ifdef SIMULATION
	task initialize_decode;
		is_full = `Disable;
	endtask

	task initialize_issue;
		dec_e_ = `Disable_;
		dec_rd = 0;
		dec_rs1 = 0;
		dec_rs2 = 0;
		dec_br_ = `Disable_;
		dec_br_pred = `Disable;
		dec_jump_ = `Disable_;
		dec_invalid = `Disable;
		dec_imm = 0;
		dec_unit = UNIT_NOP;
		dec_command = 0;
		is_full = `Disable;
	endtask
`endif

endinterface : DecIsIf



//***** Issue and Execution units Interface
interface IsExeIf #(
	parameter DATA = `DataWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
);

	//*** Issue to Exe
	logic				issue_e_;
	RegFile_t			issue_rd;
	logic				issue_data1_e_;
	logic [DATA-1:0]	issue_data1;
	logic				issue_data2_e_;
	logic [DATA-1:0]	issue_data2;
	ExeUnit_t			issue_unit;
	OpCommand_t			issue_command;

	//*** Exe to Issue
	logic				pre_wb_e_;
	RegFile_t			pre_wb_rd;
	logic				wb_e_;
	RegFile_t			wb_rd;
	logic [DATA-1:0]	wb_data;
	logic				wb_exp_;
	ExpCode_t			wb_exp_code;
	logic				wb_pred_miss_;
	logic				wb_jump_miss_;
	ExeBusy_t			exe_busy;

	modport issue (
		input	pre_wb_e_,
		input	pre_wb_rd,
		input	wb_e_,
		input	wb_rd,
		input	wb_data,
		input	wb_exp_,
		input	wb_exp_code,
		input	wb_pred_miss_,
		input	wb_jump_miss_,
		input	exe_busy,
		output	issue_e_,
		output	issue_rd,
		output	issue_data1,
		output	issue_data1_e_,
		output	issue_data2,
		output	issue_data2_e_,
		output	issue_unit,
		output	issue_command
	);

	modport exe (
		input	issue_e_,
		input	issue_rd,
		input	issue_data1,
		input	issue_data1_e_,
		input	issue_data2,
		input	issue_data2_e_,
		input	issue_unit,
		input	issue_command,
		output	pre_wb_e_,
		output	pre_wb_rd,
		output	wb_e_,
		output	wb_rd,
		output	wb_data,
		output	wb_exp_,
		output	wb_exp_code,
		output	wb_pred_miss_,
		output	wb_jump_miss_,
		output	exe_busy
	);

`ifdef SIMULATION
	task initialize_issue;
		pre_wb_e_ = `Disable_;
		pre_wb_rd = 0;
		wb_e_ = `Disable_;
		wb_rd = 0;
		wb_data = 0;
		wb_exp_ = `Disable_;
		wb_exp_code = EXP_I_MISS_ALIGN;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		exe_busy = 0;
	endtask

	task initialize_exe;
		issue_e_ = `Disable_;
		issue_rd = 0;
		issue_data1 = 0;
		issue_data1_e_ = `Disable_;
		issue_data2 = 0;
		issue_data2_e_ = `Disable_;
		issue_unit = UNIT_NOP;
		issue_command = 0;
	endtask
`endif

endinterface : IsExeIf



//***** Exe Stage and Data Cache Interface
interface ExeDCacheIf #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth
);
endinterface : ExeDCacheIf



//***** Exchange Branch/Jump/Exception information
interface PcInstIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
);

	//*** Fetch to Issue

	//*** Fetch to Exe
	logic				exe_br_pred;
	logic [ADDR-1:0]	exe_target;

	//*** Decode to Issue

	//*** Issue to Fetch
	//logic				dec_e_;
	logic				dec_rob_br_;
	//logic				dec_jr_;
	//logic				dec_jump_;
	logic [ROB-1:0]		dec_rob_id;

	//*** Exe to Fetch
	logic [ROB-1:0]		exe_rob_id;
	logic				wb_e_;
	logic [ROB-1:0]		wb_rob_id;
	logic				wb_pred_miss_;
	logic				wb_jump_miss_;
	logic				wb_br_result;
	logic [ADDR-1:0]	wb_tar_addr;
	logic				wb_exp_;

	//*** Commit to Fetch
	logic				commit_e_;
	logic				flush_;
	logic				commit_exp_;
	logic [ADDR-1:0]	commit_pc;
	logic [ROB-1:0]		commit_rob_id;

	modport fetch (
		//input	dec_e_,
		input	dec_rob_br_,
		//input	dec_jr_,
		//input	dec_jump_,
		input	dec_rob_id,
		// branch check
		input	exe_rob_id,
		output	exe_br_pred,
		output	exe_target,
		// writeback
		input	wb_e_,
		input	wb_rob_id,
		input	wb_pred_miss_,
		input	wb_jump_miss_,
		input	wb_br_result,
		input	wb_tar_addr,
		input	wb_exp_,
		// commit
		input	commit_e_,
		input	flush_,
		input	commit_exp_,
		input	commit_pc,
		input	commit_rob_id
	);

	modport issue (
		output	dec_rob_br_,
		output	dec_rob_id,
		// commit
		output	commit_e_,
		output	commit_exp_,
		output	flush_,
		output	commit_pc,
		output	commit_rob_id
	);

	modport exe (
		// pipeline flush
		input	flush_,
		// branch check
		input	exe_br_pred,
		input	exe_target,
		output	exe_rob_id,
		// writeback
		output	wb_e_,
		output	wb_rob_id,
		output	wb_pred_miss_,
		output	wb_jump_miss_,
		output	wb_br_result,
		output	wb_tar_addr,
		output	wb_exp_
	);

`ifdef SIMULATION
	task initialize_fetch;
		dec_rob_br_ = `Disable_;
		dec_rob_id = 0;
		exe_rob_id = 0;
		wb_e_ = `Disable_;
		wb_rob_id = 0;
		wb_pred_miss_ = `Disable_;
		wb_jump_miss_ = `Disable_;
		wb_br_result = `Disable;
		wb_tar_addr = 0;
		wb_exp_ = `Disable_;
		commit_e_ = `Disable_;
		flush_ = `Disable_;
		commit_exp_ = `Disable_;
		commit_pc = 0;
		commit_rob_id = 0;
	endtask

	task initialize_issue;
	endtask

	task initialize_exe;
		exe_br_pred = 0;
		exe_target = 0;
	endtask

`endif

endinterface : PcInstIf

`endif // _CPU_IF_SVH_INCLUDED_
