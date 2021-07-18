/*
* <rv_verif.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _RV_VERIF_SVH_INCLUDED_
`define _RV_VERIF_SVH_INCLUDED_

`include "cpu_config.svh"
`include "rv_opcodes.svh"

//***** for verification
//***** common verification class for 32/64 bit
virtual class rv_verif;
	//*** ALU instructions
	static function [`InstWidth-1:0] alu_inst (
		input string			op,
		input [`RvRegW-1:0]		rd,
		input [`RvRegW-1:0]		rs1,
		input [`RvRegW-1:0]		rs2
	);
		RvRtype_t				r_type_inst;
		reg [`RvFunct7W-1:0]	funct7;
		reg [`RvFunct3W-1:0]	funct3;

		case ( op )
			"add" : begin
				funct7 = `RvFunct7Add;
				funct3 = `RvFunct3AddSub;
			end
			"sub" : begin
				funct7 = `RvFunct7Sub;
				funct3 = `RvFunct3AddSub;
			end
			"sll" : begin
				funct7 = 0;
				funct3 = `RvFunct3Sll;
			end
			"slt" : begin
				funct7 = 0;
				funct3 = `RvFunct3Slt;
			end
			default : begin
				funct7 = 0;
				funct3 = 0;
			end
		endcase

		r_type_inst = RvRtype_t'{
			funct7	: funct7,
			rs2		: rs2,
			rs1		: rs1,
			funct3	: funct3,
			rd		: rd,
			opcode	: `RvOpR
		};

		alu_inst = r_type_inst;
	endfunction



	//*** alu immediate inst
	static function [`InstWidth-1:0] alu_i_inst (
		input string			op,
		input [`RvImmW_I-1:0]	imm,
		input [`RvRegW-1:0]		rd,
		input [`RvRegW-1:0]		rs1
	);
		localparam SHAMT = $clog2(`WordBitWidth);
		RvItype_t				i_type_inst;
		reg [`RvImmW_I-1:0]		imm_i;
		reg [`RvFunct3W-1:0]	funct3;
		reg [SHAMT-1:0]			shamt;
		reg [`RvFunct7W-1:0]	funct7;

		shamt = imm[SHAMT-1:0];

		case ( op )
			"addi" : begin
				funct3 = `RvFunct3AddSub;
				imm_i = imm;
			end
			"slti" : begin
				funct3 = `RvFunct3Slt;
				imm_i = imm;
			end
			"sltiu" : begin
				funct3 = `RvFunct3Sltu;
				imm_i = imm;
			end
			"xori" : begin
				funct3 = `RvFunct3Xor;
				imm_i = imm;
			end
			"ori" : begin
				funct3 = `RvFunct3Or;
				imm_i = imm;
			end
			"andi" : begin
				funct3 = `RvFunct3And;
				imm_i = imm;
			end
			"slli" : begin
				funct3 = `RvFunct3Sll;
				imm_i = {`RvFunct7W'b0, shamt};
			end
			"srli" : begin
				funct3 = `RvFunct3SraSrl;
				funct7 = `RvFunct7Srl;
				imm_i = {funct7, shamt};
			end
			"srai" : begin
				funct3 = `RvFunct3SraSrl;
				funct7 = `RvFunct7Sra;
				imm_i = {funct7, shamt};
			end
		endcase

		i_type_inst = RvItype_t'{
			imm		: imm_i,
			rs1		: rs1,
			funct3	: funct3,
			rd		: rd,
			opcode	: `RvOpImm
		};

		alu_i_inst = i_type_inst;
	endfunction



	//*** branch instructions
	static function [`InstWidth-1:0] br_inst (
		input string			op,
		input [`RvImmW_B-1:0]	imm,
		input [`RvRegW-1:0]		rs1,
		input [`RvRegW-1:0]		rs2
	);
		RvBtype_t				b_type_inst;
		reg [`RvImm0W_B-1:0]	imm0;
		reg [`RvImm1W_B-1:0]	imm1;
		reg [`RvImm2W_B-1:0]	imm2;
		reg [`RvImm3W_B-1:0]	imm3;
		reg [`RvFunct3W-1:0]	funct3;

		case ( op )
			"beq" : begin
				funct3 = `RvFunct3Beq;
			end
			"bne" : begin
				funct3 = `RvFunct3Bne;
			end
			"blt" : begin
				funct3 = `RvFunct3Blt;
			end
			"bge" : begin
				funct3 = `RvFunct3Bge;
			end
			"bltu" : begin
				funct3 = `RvFunct3Bltu;
			end
			"bgeu" : begin
				funct3 = `RvFunct3Bgeu;
			end
			default : begin
				funct3 = 0;
				$error("Unknown Operation: %x", op);
			end
		endcase

		{imm3, imm2, imm1, imm0} = imm;
		b_type_inst = RvBtype_t'{
			imm3	: imm3,
			imm1 	: imm1,
			rs2		: rs2,
			rs1		: rs1,
			funct3	: funct3,
			imm0	: imm0,
			imm2	: imm2,
			opcode	: `RvOpBranch
		};

		br_inst = b_type_inst;

	endfunction : br_inst



	//*** Jump instruction
	static function [`InstWidth-1:0] jal_inst (
		input [`RvImmW_J-1:0]	imm,
		input [`RvRegW-1:0]		rd
	);
		RvJtype_t				j_type_inst;
		reg [`RvImm0W_J-1:0]	imm0;
		reg [`RvImm1W_J-1:0]	imm1;
		reg [`RvImm2W_J-1:0]	imm2;
		reg [`RvImm3W_J-1:0]	imm3;

		{imm3, imm2, imm1, imm0} = imm;

		j_type_inst = RvJtype_t'{
			imm3	: imm3,
			imm0	: imm0,
			imm1	: imm1,
			imm2	: imm2,
			rd		: rd,
			opcode	: `RvOpJal
		};

		jal_inst = j_type_inst;
	endfunction

	static function [`InstWidth-1:0] jalr_inst (
		input [`RvImmW_I-1:0]	imm,
		input [`RvRegW-1:0]		rd,
		input [`RvRegW-1:0]		rs1
	);
		RvItype_t				i_type_inst;

		i_type_inst = RvItype_t'{
			imm		: imm,
			rs1		: rs1,
			funct3	: 3'b0,
			rd		: rd,
			opcode	: `RvOpJalr
		};

		jalr_inst = i_type_inst;
	
	endfunction



	//*** Memroy access instructions
	static function [`InstWidth-1:0] mem_inst (
		input string			op,
		input [`RvImmW_I-1:0]	imm,
		input [`RvRegW-1:0]		rd,
		input [`RvRegW-1:0]		rs1
	);
		RvItype_t				i_type_inst;
		reg [`RvOpW-1:0]		opcode;
		reg [`RvFunct3W-1:0]	funct3;

		case ( op )
			"lb" : begin
				opcode = `RvOpLoad;
				funct3 = `RvFunct3Byte;
			end
			"lh" : begin
				opcode = `RvOpLoad;
				funct3 = `RvFunct3Half;
			end
			"lw" : begin
				opcode = `RvOpLoad;
				funct3 = `RvFunct3Word;
			end
			"lbu" : begin
				opcode = `RvOpLoad;
				funct3 = `RvFunct3Ubyte;
			end
			"lhu" : begin
				opcode = `RvOpLoad;
				funct3 = `RvFunct3Uhalf;
			end
			"sb" : begin
				opcode = `RvOpStore;
				funct3 = `RvFunct3Byte;
			end
			"sh" : begin
				opcode = `RvOpStore;
				funct3 = `RvFunct3Half;
			end
			"sw" : begin
				opcode = `RvOpStore;
				funct3 = `RvFunct3Word;
			end
			default : begin
				opcode = 0;
				funct3 = 0;
			end
		endcase

		i_type_inst = RvItype_t'{
			imm		: imm,
			rs1		: rs1,
			funct3	: funct3,
			rd		: rd,
			opcode	: opcode
		};

		mem_inst = i_type_inst;
	endfunction : mem_inst



endclass : rv_verif



//***** verification class for 64bit ISA
virtual class rv64_verif extends rv_verif;
endclass : rv64_verif

`endif // _RV_VERIF_SVH_INCLUDED_
