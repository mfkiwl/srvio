/*
* <decoder_test.sv>
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
`include "rv_opcodes.svh"

module decoder_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter DATA = `DataWidth;
	parameter INST = `InstWidth;

	reg					clk;
	reg					reset_;
	reg [ADDR-1:0]		inst_pc;
	reg					stall;
	wire RegFile_t		rs1_out;
	wire RegFile_t		rs2_out;
	wire RegFile_t		rd_out;
	wire				invalid_out;
	wire ImmData_t		imm_data_out;
	wire ExeUnit_t		unit_out;
	wire OpCommand_t	command_out;

	union packed {
		RvRtype_t		r;
		RvItype_t		i;
		RvIS32type_t	is32;
		RvIS64type_t	is64;
		RvStype_t		s;
		RvUtype_t		u;
		RvJtype_t		j;
		RvBtype_t		b;
	} inst;

	decoder #(
		.ADDR		( ADDR ),
		.DATA		( DATA ),
		.INST		( INST )
	) decoder (
		.*
	);

 `ifndef VERILATOR
	always #( STEP/2 ) begin
		clk <= ~clk;
	end

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		inst_pc = 'hdeadbeef;
		inst = 'hcafecafe;
		#(STEP);
		inst.r.opcode = `RvOpR;
		inst.r.funct3 = `RvFunct3AddSub;
		inst.r.funct7 = `RvFunct7Add;

		#(STEP);
		inst = 'hcafecafe;
		inst.i.opcode = `RvOpImm;
		inst.i.funct3 = `RvFunct3AddSub;

		#(STEP);
		inst = 'hcafecafe;
		inst.is32.opcode = `RvOpImm;
		inst.is32.funct3 = `RvFunct3Sll;

		#(STEP);
		reset_ = `Disable_;

		#(STEP*5);
		$finish;
	end

 `ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
 `endif
`endif
endmodule
