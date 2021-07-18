/*
* <exe.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _EXE_SVH_INCLUDED_
`define _EXE_SVH_INCLUDED_

//***** include dependent headers files
`include "regfile.svh"
`include "exception.svh"



//***** execution command
`define ExeOpWidth			3
`define ExeOp				`ExeOpWidth-1:0
`define ExeSubOpWidth		4
`define ExeSubOp			`ExeSubOpWidth-1:0
`define ExeCommandWidth		(`ExeOpWidth+`ExeSubOpWidth)
`define ExeCommand			`ExeCommandWidth-1:0



//***** Functional Unit configuration
`define ExeUnitWidth	3
`define ExeUnitBus		`ExeUnitWidth-1:0
typedef enum logic[`ExeUnitBus] {
	UNIT_NOP	= 0,
	UNIT_ALU	= 1,
	UNIT_DIV  	= 2,
	UNIT_FPU  	= 3,
	UNIT_FDIV 	= 4,
	UNIT_CSR	= 5,
	UNIT_MEM	= 6
} ExeUnit_t;



//***** Functional unit latency (Actual Latency - 1)
//*** Latency counter
`define ExeLatCntWidth	3
`define ExeLatCnt		`ExeLatCntWidth-1:0
//*** Latency of each Functional Unit
`define AluLatency		'd0
`define DivLatency		'd4
`define FpuLatency		'd2
`define FdivLatency		'd6
`define CsrLatency		'd0
`define MemLatency		'd0	// Not used



//***** Writeback Prioirty of functional units 
//			Lower value means higher priority
`define ExePriorWidth	2
`define ExePrior		`ExePriorWidth-1:0
`define AluPrior		'd0
`define DivPrior		'd2
`define FpuPrior		'd1
`define FdivPrior		'd2
`define CsrPrior		'd1
`define MemPrior		'd1



//***** functional unit busy signals
typedef struct packed {
	logic		alu;
	logic		div;
	logic		fpu;
	logic		fdiv;
	logic		csr;
	logic		mem;
} ExeBusy_t;



//***** ALU Operations
//*** Operation Type
typedef enum logic[`ExeOp] {
	ALU_NOP		= 'b000,
	ALU_ADD		= 'b001,
	ALU_MULT	= 'b010,
	ALU_COMP	= 'b011,
	ALU_SHIFT	= 'b100,
	ALU_LOGIC	= 'b101
} AluOp_t;

//*** Sub-operations
//* Unsigned
`define AluUnsigned			0
`define AluWord				1	// 32bit operation (64bit CPU only)
//* Add or Sub select
`define AluSub				2
`define AluJump				3
//* Multiplication
`define AluMulHigh			2
`define AluSrc1Sign			3
//* Compare Condition
`define AluCompLt			1	// 0: Eq, 1: Lt
`define AluCompNeg			2	// Negate condition 
`define AluBranch			3
//* Shift Direction
`define AluRight			2
`define AluArith			3
//* Logical Operation
`define AluLogicOp			1:0
`define AluLogicAnd			2'b00
`define AluLogicOr			2'b01
`define AluLogicXor			2'b10
`define AluLogicNeg			2	// Invert (NOT)

//*** ALU Command
typedef struct packed {
	logic [`ExeSubOp]		sub_op;
	AluOp_t					op;
} AluCommand_t;



//***** Integer Divider Operations
typedef enum logic[`ExeOp] {
	DIV_NOP = 'b000,
	DIV_DIV = 'b001,
	DIV_REM = 'b010
} DivOp_t;

//*** Sub-operations
//* Unsigned
`define DivUnsigned			0
`define DivWord				1	// 32bit operation (64bit CPU only)

//*** DIV Command
typedef struct packed {
	logic [`ExeSubOp]		sub_op;
	DivOp_t					op;
} DivCommand_t;



//***** FPU Operation



//***** CSR Operation
//*** Operation Type
typedef enum logic[`ExeOp] {
	CSR_NOP		= 'b000,
	CSR_RW		= 'b001,
	CSR_RS		= 'b010,	// Read and Set Bits
	CSR_RC		= 'b011		// Read and Clear Bits
} CsrOp_t;

//*** Sub-Operations
`define CsrImmediate		0

//*** CSR Commands
typedef struct packed {
	logic [`ExeSubOp]		sub_op;
	CsrOp_t					op;
} CsrCommand_t;


//***** Memory Unit Operation
//*** Operation Type
typedef enum logic[`ExeOp] {
	MEM_NOP		= 'b000,
	MEM_LOAD	= 'b001,
	MEM_STORE	= 'b010,
	MEM_AMO		= 'b011,
	MEM_CSR		= 'b100
} MemOp_t;

//*** Sub-operation
//* Unsigned
`define MemUnsigned			0
//* Memory Operation Format
`define MemSizeWidth		2
`define MemSize				`MemSizeWidth:1
`define MemSizeByte			'b00
`define MemSizeHalf			'b01
`define MemSizeWord			'b10
`define MemSizeDouble		'b11
//* Control & Status Register Access
`define MemCsrOpWidth		2
`define MemCsrOp			`MemCsrOpWidth-1:0
`define MemCsrOpRW			'b00
`define MemCsrOpRS			'b01
`define MemCsrOpRC			'b10

//*** Mem Command
typedef struct packed {
	logic [`ExeSubOp]		sub_op;
	MemOp_t					op;
} MemCommand_t;

`endif //_EXE_SVH_INCLUDED_
