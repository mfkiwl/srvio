/*
* <rv_opcodes.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _RV_OPCODES_SVH_INCLUDED_
`define _RV_OPCODES_SVH_INCLUDED_

`include "cpu_config.svh"

//***** basic parameters
`define RvOpW				7			// opcode width
`define RvOp				6:0			// opcode
`define RvFunct12W			12			// Function code 12
`define RvFunct12			31:20
`define RvFunct7W			7			// Function code 7
`define RvFunct7			31:25
`define RvFunct6W			6			// Function code 6
`define RvFunct6			31:26
`define RvFunct3W			3			// Function code 3
`define RvFunct3			14:12
`define RvRegW				5			// Register width
`define RvRd				11:7		// Register Destination
`define RvRs1				19:15		// Register Source 1 ( origin is 1 )
`define RvRs2				24:20		// Register Source 2
`define RvShamt32W			5			// shift amount width
`define RvShamt32			24:20
`define RvShamt64W			6			// shift amount width
`define RvShamt64			25:20
`define RvCsrW				12			// CSR address immediate

//*** R-type
typedef struct packed {
	logic [`RvFunct7W-1:0]	funct7;		// 31:25
	logic [`RvRegW-1:0]		rs2;		// 24:20
	logic [`RvRegW-1:0]		rs1;		// 19:15
	logic [`RvFunct3W-1:0]	funct3;		// 14:12
	logic [`RvRegW-1:0]		rd;			// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvRtype_t;

//*** I-type Instruction
`define RvImmW_I			12			// I-type Immediate
`define RvImmSign_I			11			// Sign bit for I-type immediate
`define RvImm_I				31:20		// I-type Immediate width
`define RvImm_IS32			24:20		// I-type 32bit Shift			
`define RvImm_IS64			24:20		// I-type 32bit Shift
typedef struct packed {
	logic [`RvImmW_I-1:0]	imm;		// 31:20
	logic [`RvRegW-1:0]		rs1;		// 19:15
	logic [`RvFunct3W-1:0]	funct3;		// 14:12
	logic [`RvRegW-1:0]		rd;			// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvItype_t;
//* 32bit Shift
typedef struct packed {
	logic [`RvFunct7W-1:0]	funct7;		// 31:25
	logic [`RvShamt32W-1:0]	shamt;		// 24:20
	logic [`RvRegW-1:0]		rs1;		// 19:15
	logic [`RvFunct3W-1:0]	funct3;		// 14:12
	logic [`RvRegW-1:0]		rd;			// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvIS32type_t;
//* 64bit Shift
typedef struct packed {
	logic [`RvFunct6W-1:0]	funct6;		// 31:26
	logic [`RvShamt64W-1:0]	shamt;		// 25:20
	logic [`RvRegW-1:0]		rs1;		// 19:15
	logic [`RvFunct3W-1:0]	funct3;		// 14:12
	logic [`RvRegW-1:0]		rd;			// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvIS64type_t;

//*** S-type Instruction
`define RvImmW_S			12			// S-type Immediate total width
`define RvImmSign_S			11			// Sign bit for S-type immediate
`define RvImmW_SH			7			// S-type Immediate high width
`define RvImm_SH			31:25		// S-type Immediate high
`define RvImmW_SL			5			// S-type Immediate low width
`define RvImm_SL			11:7		// S-type Immediate low
typedef struct packed {
	logic [`RvImmW_SH-1:0]	imm1;		// 31:25
	logic [`RvRegW-1:0]		rs2;		// 24:20
	logic [`RvRegW-1:0]		rs1;		// 19:15
	logic [`RvFunct3W-1:0]	funct3;		// 14:12
	logic [`RvRegW-1:0]		imm0;		// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvStype_t;

//*** U-type Instruction
`define RvImmW_U			20			// U-type immediate width
`define RvImmSign_U			19			// Sign bit for U-type immediate
`define RvImm_U				31:12		// U-type immediate
typedef struct packed {
	logic [`RvImmW_U-1:0]	imm;		// 31:12
	logic [`RvRegW-1:0]		rd;			// 11:7
	logic [`RvOpW-1:0]		opcode;		// 6:0
} RvUtype_t;

//*** J-Type Instruction (JAL)
`define RvImmW_J			20		// J-type immediate width
`define RvImmSign_J			19
`define RvImmScale_J		1		// J-type immediate padding
`define RvImm0_J			30:21	// imm[10:1]
`define RvImm0W_J			10
`define RvImm1_J			20		// imm[11]
`define RvImm1W_J			1
`define RvImm2_J			19:12	// imm[19:12]
`define RvImm2W_J			8
`define RvImm3_J			31		// imm[20]
`define RvImm3W_J			1
typedef struct packed {
	logic [`RvImm3W_J-1:0]	imm3;	// 31 ( imm[20] )
	logic [`RvImm0W_J-1:0]	imm0;	// 30:21 ( imm[10:1] )
	logic [`RvImm1W_J-1:0]	imm1;	// 20 ( imm[11] )
	logic [`RvImm2W_J-1:0]	imm2;	// 19:12 ( imm[19:12] )
	logic [`RvRegW-1:0]		rd;		// 11:7
	logic [`RvOpW-1:0]		opcode;	// 6:0
} RvJtype_t;

//*** B-type Instruction (Branch)
`define RvImmW_B			12		// B-type immediate width
`define RvImmSign_B			11
`define RvImmScale_B		1		// B-type immediate padding
`define RvImm0_B			11:8	// imm[4:1]
`define RvImm0W_B			4
`define RvImm1_B			30:25	// imm[10:5]
`define RvImm1W_B			6
`define RvImm2_B			7		// imm[11]
`define RvImm2W_B			1
`define RvImm3_B			31		// imm[12]
`define RvImm3W_B			1
typedef struct packed {
	logic [`RvImm3W_B-1:0]	imm3;	// 31 ( imm[12] )
	logic [`RvImm1W_B-1:0]	imm1;	// 30:25 ( imm[10:5] )
	logic [`RvRegW-1:0]		rs2;	// 24:20
	logic [`RvRegW-1:0]		rs1;	// 19:15
	logic [`RvFunct3W-1:0]	funct3;	// 14:12
	logic [`RvImm0W_B-1:0]	imm0;	// 11:8 ( imm[4:1] )
	logic [`RvImm2W_B-1:0]	imm2;	// 7 ( imm[11] )
	logic [`RvOpW-1:0]		opcode;	// 6:0
} RvBtype_t;



//***** Opcodes
`define RvOpLoad			'b000_0011
`define RvOpStore			'b010_0011
`define RvOpMadd			'b100_0011
`define RvOpBranch			'b110_0011

`define RvOpLoadFP			'b000_0111
`define RvOpStoreFP			'b010_0111 
`define RvOpMsub			'b100_0111
`define RvOpJalr			'b110_0111

`define RvOpCustom0			'b000_1011
`define RvOpCustom1			'b010_1011
`define RvOpNmsub			'b100_1011
// 7'b1101011 is reserved

`define RvOpMiscMem			'b000_1111
`define RvOpAmo				'b010_1111
`define RvOpNmadd			'b100_1111
`define RvOpJal				'b110_1111

`define RvOpImm				'b001_0011
`define RvOpR				'b011_0011
`define RvOpFP				'b101_0011
`define RvOpSystem			'b111_0011

`define RvOpAuipc			'b001_0111
`define RvOpLui				'b011_0111
// 7'b1010111 is reserved
// 7'b1110111 is reserved

// 7'b0011011 is RV64-specific
// 7'b0111011 is RV64-specific
`define RvOpCustom2			'b101_1011
`define RvOpCustom3 		'b111_1011


//***** Function Code
`define RvFunct3AddSub		'b000		// 0
`define RvFunct3Sll			'b001		// 1
`define RvFunct3Slt			'b010		// 2
`define RvFunct3Sltu		'b011		// 3
`define RvFunct3Xor			'b100		// 4
`define RvFunct3SraSrl		'b101		// 5
`define RvFunct3Or			'b110		// 6
`define RvFunct3And			'b111		// 7
`define RvFunct7Add			'b000_0000	// add
`define RvFunct7Sub			'b010_0000	// sub
`define RvFunct7Srl			'b000_0000	// srl, sll (32bit)
`define RvFunct7Sra			'b010_0000	// sra (32bit)

//*** Branch Funct3
`define RvFunct3Beq			'b000		// 0
`define RvFunct3Bne			'b001		// 1
`define RvFunct3Blt			'b100		// 4
`define RvFunct3Bge			'b101		// 5
`define RvFunct3Bltu		'b110		// 6
`define RvFunct3Bgeu 		'b111		// 7

//*** Load/Store Funct3
`define RvFunct3Byte		'b000	// load/store byte
`define RvFunct3Half		'b001	// load/store half
`define RvFunct3Word		'b010	// load/store word
`define RvFunct3Double		'b011 // load/store double
`define RvFunct3Ubyte		'b100	// load byte unsigned
`define RvFunct3Uhalf		'b101	// load half unsigned
`define RvFunct3Uword		'b110 // load word unsigned

//*** Misc memory funct3
`define RvFunct3Fence		'b000		// 0
`define RvFunct3Fence_I		'b001		// 1

//*** system funct3
`define RvFunct3Priv		'b000		// 0
`define RvFunct3Csrrw		'b001		// 1
`define RvFunct3Csrrs		'b010		// 2
`define RvFunct3Csrrc		'b011		// 3
`define RvFunct3Csrrwi		'b101		// 5
`define RvFunct3Csrrsi 		'b110		// 6
`define RvFunct3Csrrci 		'b111		// 7

//*** private funct12
`define RvFunct12Ecall		'b0000_0000_0000
`define RvFunct12Ebreak		'b0000_0000_0001
`define RvFunct12Eret		'b0001_0000_0000
`define RvFunct12Wfi		'b0001_0000_0010

//*** mult and div funct3
`define RvFunct7MulDiv		'h000_0001
`define RvFunct3Mul			'b000
`define RvFunct3Mulh		'b001
`define RvFunct3Mulhsu		'b010
`define RvFunct3Mulhu		'b011
`define RvFunct3Div			'b100
`define RvFunct3Divu		'b101
`define RvFunct3Rem			'b110
`define RvFunct3Remu		'b111

`endif //_RV_OPCODES_SVH_INCLUDED_
