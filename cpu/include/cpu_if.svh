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

`include "stddef.vh"

// Instruction Cache and Fetch Stage Interface
interface ICacheFetchIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//***** ICache to Fetch Stage
	logic				ic_e_;
	logic [ADDR-1:0]	ic_pc;
	logic [INST-1:0]	ic_inst;

	//***** Fetch Stage to ICache
	logic				fetch_e_;
	logic [ADDR-1:0]	fetch_pc;

	//***** Instruction Cache side signals
	modport icache(
		input	fetch_e_,
		input	fetch_pc,
		output	ic_e_,
		output 	ic_pc,
		output 	ic_inst
	);

	//***** Fetch Stage side signals
	modport fetch(
		input	ic_e_,
		input 	ic_pc,
		input 	ic_inst,
		output	fetch_e_,
		output	fetch_pc
	);

endinterface : ICacheFetchIf



// Fetch and Decode Interface
interface FetchDecIf #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth
);

	//***** Fetch to Decode Stage
	logic				inst_e_;
	logic [ADDR-1:0]	inst_pc;
	logic [INST-1:0]	inst;

	//***** Decode to Fetch Stage
	logic				dec_jump_;
	logic				dec_branch_;
	logic [ADDR-1:0]	dec_target;

	//***** Fetch Stage side signals
	modport fetch (
		input	dec_jump_,
		input	dec_branch_,
		input	dec_target,
		output	inst_e_,
		output	inst_pc,
		output	inst
	);

	//***** Decode Stage side signals
	modport decode (
		input	inst_e_,
		input	inst_pc,
		input	inst,
		output	dec_jump_,
		output	dec_branch_,
		output	dec_target
	);

endinterface : FetchDecodeIf

`endif // _CPU_IF_SVH_INCLUDED_
