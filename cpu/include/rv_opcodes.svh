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
`define RvOpLoad			`RvOpW'b0000011
`define RvOpStore			`RvOpW'b0100011
`define RvOpMadd			`RvOpW'b1000011
`define RvOpBranch			`RvOpW'b1100011

`define RvOpLoadFP			`RvOpW'b0000111
`define RvOpStoreFP			`RvOpW'b0100111 
`define RvOpMsub			`RvOpW'b1000111
`define RvOpJalr			`RvOpW'b1100111

`define RvOpCustom0			`RvOpW'b0001011
`define RvOpCustom1			`RvOpW'b0101011
`define RvOpNmsub			`RvOpW'b1001011
// 7'b1101011 is reserved

`define RvOpMiscMem			`RvOpW'b0001111
`define RvOpAmo				`RvOpW'b0101111
`define RvOpNmadd			`RvOpW'b1001111
`define RvOpJal				`RvOpW'b1101111

`define RvOpImm				`RvOpW'b0010011
`define RvOpR				`RvOpW'b0110011
`define RvOpFP				`RvOpW'b1010011
`define RvOpSystem			`RvOpW'b1110011

`define RvOpAuipc			`RvOpW'b0010111
`define RvOpLui				`RvOpW'b0110111
// 7'b1010111 is reserved
// 7'b1110111 is reserved

// 7'b0011011 is RV64-specific
// 7'b0111011 is RV64-specific
`define RvOpCustom2			`RvOpW'b1011011
`define RvOpCustom3 		`RvOpW'b1111011


//***** Function Code
`define RvFunct3AddSub		`RvFunct3W'b000		// 0
`define RvFunct3Sll			`RvFunct3W'b001		// 1
`define RvFunct3Slt			`RvFunct3W'b010		// 2
`define RvFunct3Sltu		`RvFunct3W'b011		// 3
`define RvFunct3Xor			`RvFunct3W'b100		// 4
`define RvFunct3SraSrl		`RvFunct3W'b101		// 5
`define RvFunct3Or			`RvFunct3W'b110		// 6
`define RvFunct3And			`RvFunct3W'b111		// 7
`define RvFunct7Add			`RvFunct7W'b0000000	// add
`define RvFunct7Sub			`RvFunct7W'b0100000	// sub
`define RvFunct7Srl			`RvFunct7W'b0000000	// srl, sll (32bit)
`define RvFunct7Sra			`RvFunct7W'b0100000	// sra (32bit)

//*** Branch Funct3
`define RvFunct3Beq			`RvFunct3W'b000		// 0
`define RvFunct3Bne			`RvFunct3W'b001		// 1
`define RvFunct3Blt			`RvFunct3W'b100		// 4
`define RvFunct3Bge			`RvFunct3W'b101		// 5
`define RvFunct3Bltu		`RvFunct3W'b110		// 6
`define RvFunct3Bgeu 		`RvFunct3W'b111		// 7

//*** Load/Store Funct3
`define RvFunct3Byte		`RvFunct3W'b000	// load/store byte
`define RvFunct3Half		`RvFunct3W'b001	// load/store half
`define RvFunct3Word		`RvFunct3W'b010	// load/store word
`define RvFunct3Double		`RvFunct3W'b011 // load/store double
`define RvFunct3Ubyte		`RvFunct3W'b100	// load byte unsigned
`define RvFunct3Uhalf		`RvFunct3W'b101	// load half unsigned
`define RvFunct3Uword		`RvFunct3W'b110 // load word unsigned

//*** Misc memory funct3
`define RvFunct3Fence		`RvFunct3W'b000		// 0
`define RvFunct3Fence_I		`RvFunct3W'b001		// 1

//*** system funct3
`define RvFunct3Priv		`RV_FUNCT3W'b000		// 0
`define RvFunct3Csrrw		`RV_FUNCT3W'b001		// 1
`define RvFunct3Csrrs		`RV_FUNCT3W'b010		// 2
`define RvFunct3Csrrc		`RV_FUNCT3W'b011		// 3
`define RvFunct3Csrrwi		`RV_FUNCT3W'b101		// 5
`define RvFunct3Csrrsi 		`RV_FUNCT3W'b110		// 6
`define RvFunct3Csrrci 		`RV_FUNCT3W'b111		// 7

//*** private funct12
`define RvFunct12Ecall		`RvFunct12W'b000000000000
`define RvFunct12Ebreak		`RvFunct12W'b000000000001
`define RvFunct12Eret		`RvFunct12W'b000100000000
`define RvFunct12Wfi		`RvFunct12W'b000100000010

//*** mult and div funct3
`define RvFunct7MulDiv		`RvFunct7W'h0000001
`define RvFunct3Mul			`RvFunct3W'b000
`define RvFunct3Mulh		`RvFunct3W'b001
`define RvFunct3Mulhsu		`RvFunct3W'b010
`define RvFunct3Mulhu		`RvFunct3W'b011
`define RvFunct3Div			`RvFunct3W'b100
`define RvFunct3Divu		`RvFunct3W'b101
`define RvFunct3Rem			`RvFunct3W'b110
`define RvFunct3Remu		`RvFunct3W'b111

`endif //_RV_OPCODES_SVH_INCLUDED_
