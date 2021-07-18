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
	//*** fetch
	wire			inst_e_;
	wire [ADDR-1:0]	inst_pc;
	wire [INST-1:0]	inst;
	wire			dec_flush_;	// flsuh instructions in decode stage
	//*** simple
	RegFile_t		rs1_s;
	RegFile_t		rs2_s;
	RegFile_t		rd_s;
	wire			br_s_;
	wire			jump_s_;
	wire			invalid_s;
	ImmData_t		imm_data_s;
	ExeUnit_t		unit_s;
	OpCommand_t		command_s;
	//*** complex (TODO)
	RegFile_t		rs1_c;
	RegFile_t		rs2_c;
	RegFile_t		rd_c;
	wire			invalid_c;
	ImmData_t		imm_data_c;
	ExeUnit_t		unit_c;
	OpCommand_t		command_c;



	//***** assign internal
	assign inst_e_ = fetch_dec_if.inst_e_;
	assign inst_pc = fetch_dec_if.inst_pc;
	assign inst = fetch_dec_if.inst;
	assign dec_flush_ = fetch_dec_if.dec_flush_;



	//***** Decoder Control
	decode_ctrl #(
		.ADDR			( ADDR )
	) decode_ctrl (
		.clk			( clk ),
		.reset_			( reset_ ),

		.inst_e_		( inst_e_ ),
		.inst_pc		( inst_pc ),

		.dec_flush_		( dec_flush_ ),
		.dec_stop		( fetch_dec_if.dec_stop ),
		.is_full		( dec_is_if.is_full ),

		.rs1_s			( rs1_s ),
		.rs2_s			( rs2_s ),
		.rd_s			( rd_s ),
		.br_s_			( br_s_ ),
		.jump_s_		( jump_s_ ),
		.invalid_s		( invalid_s ),
		.imm_data_s		( imm_data_s ),
		.unit_s			( unit_s ),
		.command_s		( command_s ),

		.rs1_c			( rs1_c ),
		.rs2_c			( rs2_c ),
		.rd_c			( rd_c ),
		.invalid_c		( invalid_c ),
		.imm_data_c		( imm_data_c ),
		.unit_c			( unit_c ),
		.command_c		( command_c ),

		.stall			( fetch_dec_if.dec_stall ),
		.dec_e_			( dec_is_if.dec_e_ ),
		.dec_pc			( dec_is_if.dec_pc ),
		.rs1			( dec_is_if.dec_rs1 ),
		.rs2			( dec_is_if.dec_rs2 ),
		.br_			( dec_is_if.dec_br_ ),
		.br_pred		( dec_is_if.dec_br_pred ),
		.jump_			( dec_is_if.dec_jump_ ),
		.rd				( dec_is_if.dec_rd ),
		.invalid		( dec_is_if.dec_invalid ),
		.imm_data		( dec_is_if.dec_imm ),
		.unit			( dec_is_if.dec_unit ),
		.command		( dec_is_if.dec_command )
	);



	//***** Simple RISC-V Decoder
	decoder #(
		.DATA			( DATA )
	) decoder (
		.inst			( inst ),

		.rs1_out		( rs1_s ),
		.rs2_out		( rs2_s ),
		.rd_out			( rd_s ),
		.br_out_		( br_s_ ),
		.jump_out_		( jump_s_ ),
		.invalid_out	( invalid_s ),
		.imm_data_out	( imm_data_s ),
		.unit_out		( unit_s ),
		.command_out	( command_s )
	);



	//***** Complex Macro Decoder
	//complex_dec #(
	//	.ADDR			( ADDR ),
	//	.DATA			( DATA )
	//) compex_dec (
	//);

endmodule
