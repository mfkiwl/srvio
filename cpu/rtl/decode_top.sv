/*
* <decode_top.sv>
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
`include "cpu_if.svh"

module decode_top #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter INST = `InstWidth
)(
	input wire				clk,
	input wire				reset_,

	FetchDecIf.decode		fetch_dec_if,
	DecIsIf.decode			dec_is_if
);

	//***** internal wires
	//*** fetch to decode
	wire			inst_e_;
	wire [ADDR-1:0]	inst_pc;
	wire [INST-1:0]	inst;
	wire			dec_stall;
	//*** simple
	wire			dec_e_s_;
	RegFile_t		rs1_s;
	RegFile_t		rs2_s;
	RegFile_t		rd_s;
	logic			invalid_s;
	ImmData_t		imm_data_s;
	ExeUnit_t		unit_s;
	OpCommand_t		command_s;
	//*** complex (TODO)
	wire			dec_e_c_;
	RegFile_t		rs1_c;
	RegFile_t		rs2_c;
	RegFile_t		rd_c;
	logic			invalid_c;
	ImmData_t		imm_data_c;
	ExeUnit_t		unit_c;
	OpCommand_t		command_c;



	//***** output assign
	//*** decode to fetch
	assign fetch_dec_if.dec_stall = dec_stall;
	//*** decode to instruction scheduler
	assign dec_is_if.dec_e_ = dec_e_s_;
	assign dec_is_if.rs1 = rs1_s;
	assign dec_is_if.rs2 = rs2_s;
	assign dec_is_if.rd = rd_s;
	assign dec_is_if.invalid = invalid_s; 
	assign dec_is_if.imm_data = imm_data_s;
	assign dec_is_if.unit = unit_s;
	assign dec_is_if.command = command_s;



	//***** internal assign
	//*** fetch to decode
	assign inst_e_ = fetch_dec_if.inst_e_;
	assign inst_pc = fetch_dec_if.inst_pc;
	assign inst = fetch_dec_if.inst;
	//*** instruction scheduler to decode
	assign is_full = dec_is_if.is_full;



	//***** Simple RISC-V Decoder
	decoder #(
		.ADDR			( ADDR ),
		.DATA			( DATA )
	) decoder (
		.clk			( clk ),
		.reset_			( reset_ ),

		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),
		.is_full		( is_full ),
		.inst			( inst ),

		.stall			( dec_stall ),
		.dec_e_out_		( dec_e_s_ ),
		.rs1_out		( rs1_s ),
		.rs2_out		( rs2_s ),
		.rd_out			( rd_s ),
		.invalid_out	( invalid_s ),
		.imm_data_out	( imm_data_s ),
		.unit_out		( unit_s ),
		.command_out	( command_s )
	);



	//***** Complex Macro Decoder
	complex_dec #(
		.ADDR			( ADDR ),
		.DATA			( DATA )
	) compex_dec (
	);

endmodule
