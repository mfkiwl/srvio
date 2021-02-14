/*
* <alu.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _ALU_SVH_INCLUDED_
`define _ALU_SVH_INCLUDED_

//***** ALU Operation 
//*** Operation Type
`define AluOpWidth			3
`define AluOp				`AluOpWidth-1:0
typedef enum logic[`AluOp] {
	ALU_NOP		= `AluOpWidth'b000,
	ALU_ADD		= `AluOpWidth'b001,
	ALU_MULT	= `AluOpWidth'b010,
	ALU_COMP	= `AluOpWidth'b011,
	ALU_SHIFT	= `AluOpWidth'b100,
	ALU_LOGIC	= `AluOpWidth'b101
} AluOp_t;

//*** Sub-operations
`define AluSubOpWidth		4
`define AluSubOp			`AluSubOpWidth-1:0
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



//***** Commit Data Format
//*** branch
`define AluBrTaken_			0	// bit0 of writeback data



//***** ALU Command
//	Width must be `OpCommandWidth
`define AluCommandWidth		7	// op + sub_op
typedef struct packed {
	logic [`AluSubOp]		sub_op;
	AluOp_t					op;
} AluCommand_t;

`endif // _ALU_SVH_INCLUDED_
