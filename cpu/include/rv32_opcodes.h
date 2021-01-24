/*
-- ============================================================================
-- FILE     : rv32_opcodes.h
--			: 32bit risc-v instrcution sets ( mostly 64bit compatible )
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/3/23	ide			create new
-- ============================================================================
*/
`ifndef _RV32_OPCODES_H_INCLUDED_
`define _RV32_OPCODES_H_INCLUDED_


/***** basic parameters *****/
`define RV_OPW				7		// opcode width
`define RV_OP				6:0		// opcode
`define RV_FUNCT12W			12		// Function code 12 width
`define RV_FUNCT12			31:20	// Function code 12
`define RV_FUNCT7W			7		// Function code 7 width (R-type)
`define RV_FUNCT7			31:25	// Function code 7 (R-type)
`define RV_FUNCT6W			6		// Function code 6 width (for 64bit SRA)
`define RV_FUNCT6			31:26	// Function code 6 (for 64bit SRA)
`define RV_FUNCT3W			3		// Function code 3 width (R-type)
`define RV_FUNCT3			14:12	// Function code 3 width (R-type)
`define RV_REGW				5		// Register width
`define RV_RD				11:7	// Register Destination
`define RV_RS1				19:15	// Register Source 1 ( origin is 1 )
`define RV_RS2				24:20	// Register Source 2
/* I-type immediate */
`define RV_IMMIW			12		// I-type Immediate
`define RV_IMMI_SIGN		11		// Sign bit for I-type immediate
`define RV_IMMI				31:20	// I-type Immediate width
/* S-type immediate */
`define RV_IMMSW			12		// S-type Immediate total width
`define RV_IMMS_SIGN		11		// Sign bit for S-type immediate
`define RV_IMMSHW			7		// S-type Immediate high width
`define RV_IMMSH			31:25	// S-type Immediate high
`define RV_IMMSLW			5		// S-type Immediate low width
`define RV_IMMSL			11:7	// S-type Immediate low
/* U-type immediate */
`define RV_IMMUW			20		// U-type immediate width
`define RV_IMMU_SIGN		19		// Sign bit for U-type immediate
`define RV_IMMU				31:12	// U-type immediate
/* J-Type immediate (JAL) */
`define RV_IMMJW			20		// J-type immediate width
`define RV_IMMJ_SIGN		19
`define RV_IMMJ_SCALE		1		// J-type immediate padding
`define RV_IMMJ0			30:21	// imm[10:1]
`define RV_IMMJ1			20		// imm[11]
`define RV_IMMJ2			19:12	// imm[19:12]
`define RV_IMMJ3			31		// imm[20]
/* B-type immediate (Branch) */
`define RV_IMMBW			12		// B-type immediate width
`define RV_IMMB_SIGN		11
`define RV_IMMB_SCALE		1		// B-type immediate padding
`define RV_IMMB0			11:8	// imm[4:1]
`define RV_IMMB1			30:25	// imm[10:5]
`define RV_IMMB2			7		// imm[11]
`define RV_IMMB3			31		// imm[12]
/* Shift amount */
`define RV_SHAMTW			5		// shift amount width
`define RV_SHAMT			24:20	// shift amount
/* CSR */
`define RV_CSRW				12		// csr address immediate width
`define RV_CSR				31:20	// csr immediate


/***** Opcodes *****/
`define RV_OP_LOAD			`RV_OPW'b0000011
`define RV_OP_STORE			`RV_OPW'b0100011
`define RV_OP_MADD			`RV_OPW'b1000011
`define RV_OP_BRANCH		`RV_OPW'b1100011

`define RV_OP_LOAD_FP		`RV_OPW'b0000111
`define RV_OP_STORE_FP		`RV_OPW'b0100111 
`define RV_OP_MSUB			`RV_OPW'b1000111
`define RV_OP_JALR			`RV_OPW'b1100111

`define RV_OP_CUSTOM_0		`RV_OPW'b0001011
`define RV_OP_CUSTOM_1		`RV_OPW'b0101011
`define RV_OP_NMSUB			`RV_OPW'b1001011
// 7'b1101011 is reserved

`define RV_OP_MISC_MEM		`RV_OPW'b0001111
`define RV_OP_AMO			`RV_OPW'b0101111
`define RV_OP_NMADD			`RV_OPW'b1001111
`define RV_OP_JAL			`RV_OPW'b1101111

`define RV_OP_IMM			`RV_OPW'b0010011
`define RV_OP_R				`RV_OPW'b0110011
`define RV_OP_FP			`RV_OPW'b1010011
`define RV_OP_SYSTEM		`RV_OPW'b1110011

`define RV_OP_AUIPC			`RV_OPW'b0010111
`define RV_OP_LUI			`RV_OPW'b0110111
// 7'b1010111 is reserved
// 7'b1110111 is reserved

// 7'b0011011 is RV64-specific
// 7'b0111011 is RV64-specific
`define RV_OP_CUSTOM_2		`RV_OPW'b1011011
`define RV_OP_CUSTOM_3 		`RV_OPW'b1111011


/***** Function Code *****/
`define RV_FUNCT3_ADD_SUB	`RV_FUNCT3W'b000		// 0
`define RV_FUNCT3_SLL		`RV_FUNCT3W'b001		// 1
`define RV_FUNCT3_SLT		`RV_FUNCT3W'b010		// 2
`define RV_FUNCT3_SLTU		`RV_FUNCT3W'b011		// 3
`define RV_FUNCT3_XOR		`RV_FUNCT3W'b100		// 4
`define RV_FUNCT3_SRA_SRL	`RV_FUNCT3W'b101		// 5
`define RV_FUNCT3_OR		`RV_FUNCT3W'b110		// 6
`define RV_FUNCT3_AND		`RV_FUNCT3W'b111		// 7
`define RV_FUNCT7_ADD		`RV_FUNCT7W'b0000000	// add
`define RV_FUNCT7_SUB		`RV_FUNCT7W'b0100000	// sub
`define RV_FUNCT7_SRL		`RV_FUNCT7W'b0000000	// srl, sll (32bit)
`define RV_FUNCT7_SRA		`RV_FUNCT7W'b0100000	// sra (32bit)

/* Branch Funct3 */
`define RV_FUNCT3_BEQ		`RV_FUNCT3W'b000		// 0
`define RV_FUNCT3_BNE		`RV_FUNCT3W'b001		// 1
`define RV_FUNCT3_BLT		`RV_FUNCT3W'b100		// 4
`define RV_FUNCT3_BGE		`RV_FUNCT3W'b101		// 5
`define RV_FUNCT3_BLTU		`RV_FUNCT3W'b110		// 6
`define RV_FUNCT3_BGEU 		`RV_FUNCT3W'b111		// 7

/* Load/Store Funct3 */
`define RV_FUNCT3_BYTE		`RV_FUNCT3W'b000		// load/store byte
`define RV_FUNCT3_HALF		`RV_FUNCT3W'b001		// load/store half
`define RV_FUNCT3_WORD		`RV_FUNCT3W'b010		// load/store word
`define RV_FUNCT3_UBYTE		`RV_FUNCT3W'b100		// load byte unsigned
`define RV_FUNCT3_UHALF		`RV_FUNCT3W'b101		// load half unsigned

/* Misc memory funct3 */
`define RV_FUNCT3_FENCE		`RV_FUNCT3W'b000		// 0
`define RV_FUNCT3_FENCE_I	`RV_FUNCT3W'b001		// 1

/* system funct3 */
`define RV_FUNCT3_PRIV		`RV_FUNCT3W'b000		// 0
`define RV_FUNCT3_CSRRW		`RV_FUNCT3W'b001		// 1
`define RV_FUNCT3_CSRRS		`RV_FUNCT3W'b010		// 2
`define RV_FUNCT3_CSRRC		`RV_FUNCT3W'b011		// 3
`define RV_FUNCT3_CSRRWI	`RV_FUNCT3W'b101		// 5
`define RV_FUNCT3_CSRRSI 	`RV_FUNCT3W'b110		// 6
`define RV_FUNCT3_CSRRCI 	`RV_FUNCT3W'b111		// 7

/* private funct12 */
`define RV_FUNCT12_ECALL	`RV_FUNCT12W'b000000000000
`define RV_FUNCT12_EBREAK	`RV_FUNCT12W'b000000000001
`define RV_FUNCT12_ERET		`RV_FUNCT12W'b000100000000
`define RV_FUNCT12_WFI		`RV_FUNCT12W'b000100000010


/* mult and div funct3 */
`define RV_FUNCT7_MUL_DIV	`RV_FUNCT7W'h0000001
`define RV_FUNCT3_MUL		`RV_FUNCT3W'b000
`define RV_FUNCT3_MULH		`RV_FUNCT3W'b001
`define RV_FUNCT3_MULHSU	`RV_FUNCT3W'b010
`define RV_FUNCT3_MULHU		`RV_FUNCT3W'b011
`define RV_FUNCT3_DIV		`RV_FUNCT3W'b100
`define RV_FUNCT3_DIVU		`RV_FUNCT3W'b101
`define RV_FUNCT3_REM		`RV_FUNCT3W'b110
`define RV_FUNCT3_REMU		`RV_FUNCT3W'b111

`endif //_RV32_OPCODES_H_INCLUDED_
