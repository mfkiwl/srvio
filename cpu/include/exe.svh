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
`define ExeLatCntWidth	2
`define ExeLatCnt		`ExeLatCntWidth-1:0
//*** Latency of each Functional Unit
`define ALU_LATENCY		`ExeLatCntWidth'd0
`define DIV_LATENCY		`ExeLatCntWidth'd2
`define FPU_LATENCY		`ExeLatCntWidth'd1
`define FDIV_LATENCY	`ExeLatCntWidth'd2
`define CSR_LATENCY		`ExeLatCntWidth'd0
`define MEM_LATENCY		`ExeLatCntWidth'd2	// latency without cache miss



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
	ALU_NOP		= `ExeOpWidth'b000,
	ALU_ADD		= `ExeOpWidth'b001,
	ALU_MULT	= `ExeOpWidth'b010,
	ALU_COMP	= `ExeOpWidth'b011,
	ALU_SHIFT	= `ExeOpWidth'b100,
	ALU_LOGIC	= `ExeOpWidth'b101
} AluOp_t;

//*** Sub-operations
//* Unsigned
`define AluUnsigned			0
//* Add or Sub select
`define AluSub				1
`define AluJump				2
//* Compare Condition
`define AluCompLt			1	// 0: Eq, 1: Lt
`define AluCompNeg			2	// Negate condition 
`define AluBranch			3
//* Shift Direction
`define AluRotate			1
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



//***** FPU Operation



//***** Memory Unit Operation
//*** Operation Type
typedef enum logic[`ExeOp] {
	MEM_NOP		= `ExeOpWidth'b000,
	MEM_LOAD	= `ExeOpWidth'b001,
	MEM_STORE	= `ExeOpWidth'b010,
	MEM_AMO		= `ExeOpWidth'b011,
	MEM_CSR		= `ExeOpWidth'b100
} MemOp_t;

//*** Sub-operation
//* Unsigned
`define MemUnsigned			0
//* Memory Operation Format
`define MemSizeWidth		2
`define MemSize				`MemSizeWidth:1
`define MemSizeByte			`MemSizeWidth'b00
`define MemSizeHalf			`MemSizeWidth'b01
`define MemSizeWord			`MemSizeWidth'b10
`define MemSizeDouble		`MemSizeWidth'b11
//* Control & Status Register Access
`define MemCsrOpWidth		2
`define MemCsrOp			`MemCsrOpWidth-1:0
`define MemCsrOpRW			`MemCsrOpWidth'b00
`define MemCsrOpRS			`MemCsrOpWidth'b01
`define MemCsrOpRC			`MemCsrOpWidth'b10

//*** Mem Command
typedef struct packed {
	logic [`ExeSubOp]		sub_op;
	MemOp_t					op;
} MemCommand_t;

`endif //_EXE_SVH_INCLUDED_
