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
	logic				ic_e_;
	logic [ADDR-1:0]	ic_pc;
	logic [INST-1:0]	ic_inst;
	logic				ic_stall_;

	//*** Fetch Stage to ICache
	logic				fetch_e_;
	logic [ADDR-1:0]	fetch_pc;
	logic				flush_;

	//*** Instruction Cache side signals
	modport icache(
		input	fetch_e_,
		input	fetch_pc,
		input	flush_,
		output	ic_e_,
		output 	ic_pc,
		output 	ic_inst,
		output	ic_stall_
	);

	//*** Fetch Stage side signals
	modport fetch(
		input	ic_e_,
		input 	ic_pc,
		input 	ic_inst,
		input	ic_stall_,
		output	fetch_e_,
		output	fetch_pc,
		output	flush_
	);

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

	//*** Decode to Fetch Stage
	logic				dec_stall;

	//*** Fetch Stage side signals
	modport fetch (
		input	dec_stall,
		output	inst_e_,
		output	inst_pc,
		output	inst
	);

	//*** Decode Stage side signals
	modport decode (
		input	inst_e_,
		input	inst_pc,
		input	inst,
		output	dec_stall
	);

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

endinterface : IsExeIf



//***** Exchange Branch/Jump information
interface PcInstIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
);

	//*** Fetch to Issue

	//*** Decode to Issue

	//*** Issue to Fetch
	logic [ROB-1:0]		dec_rob_id;

	modport fetch (
		input	dec_rob_id
	);

	//modport decode (
	//);

	modport issue (
		output	dec_rob_id
	);

	//modport exe (
	//);

endinterface : PcInstIf

`endif // _CPU_IF_SVH_INCLUDED_
