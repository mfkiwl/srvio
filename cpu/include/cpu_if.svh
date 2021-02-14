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
`include "alu.svh"
`include "mem.svh"
`include "decode.svh"



//***** Instruction Cache and Fetch Stage Interface
interface ICacheFetchIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//*** ICache to Fetch Stage
	logic				ic_e_;
	logic [ADDR-1:0]	ic_pc;
	logic [INST-1:0]	ic_inst;

	//*** Fetch Stage to ICache
	logic				fetch_e_;
	logic [ADDR-1:0]	fetch_pc;

	//*** Instruction Cache side signals
	modport icache(
		input	fetch_e_,
		input	fetch_pc,
		output	ic_e_,
		output 	ic_pc,
		output 	ic_inst
	);

	//*** Fetch Stage side signals
	modport fetch(
		input	ic_e_,
		input 	ic_pc,
		input 	ic_inst,
		output	fetch_e_,
		output	fetch_pc
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



//***** Decode and Instruction Scheduler Interface
interface DecIsIf #(
	parameter ADDR = `AddrWidth, 
	parameter INST = `InstWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
);

	//*** Decode to Instruction Scheduler
	logic				en_;
	loigc [ADDR-1:0]	pc;
	RegFile_t			rd;
	RegFile_t			rs1;
	RegFile_t			rs2;
	logic				br_;
	logic				br_pred_taken_;
	logic				jump_;
	logic				invalid;
	ImmData_t			imm_data;
	ExeUnit_t			unit;
	OpCommand_t			command;

	//*** Instruction Scheduler to Decoder
	logic				is_full;
	logic [ROB-1:0]		dec_rob_id;

	//*** Decode Stage side signals
	modport decode (
		input	is_full,
		input	dec_rob_id,
		output	en_,
		output	rd,
		output	rs1,
		output	rs2,
		output	br_,
		output	br_pred_taken_,
		output	jump_,
		output	invalid,
		output	imm_data,
		output	unit,
		output	command
	);

	//*** Instruction Scheduler side signals
	modport inst_sched (
		input	en_,
		input	rd,
		input	rs1,
		input	rs2,
		input	br_,
		input	br_pred_taken_,
		input	jump_,
		input	invalid,
		input	imm_data,
		input	unit,
		input	command,
		output	is_full,
		output	dec_rob_id
	);

endinterface : DecIsIf



//***** Exchange Branch/Jump information
interface CtrlInstIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//*** Fetch to Instruction Schedule

	//*** Decode to Instruction Schedule

	modport fetch (
	);

	modport decode (
	);

	modport inst_sched (
	);

	modport exe (
	);

endinterface

`endif // _CPU_IF_SVH_INCLUDED_
