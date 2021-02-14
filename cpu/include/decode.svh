/*
* <decode.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _DECODE_SVH_INCLUDED_
`define _DECODE_SVH_INCLUDED_

//***** include dependent files
`include "alu.svh"
`include "mem.svh"



//***** Functional Unit configuration
`define ExeUnitWidth	3
`define ExeUnitBus		`ExeUnitWidth-1:0
typedef enum logic[`ExeUnitBus] {
	UNIT_NOP	= 0,
	UNIT_ALU	= 1,
	UNIT_DIV  	= 2,
	UNIT_FPU  	= 3,
	UNIT_FDIV 	= 4,
	UNIT_CSR	= 5
	UNIT_MEM	= 6,
} ExeUnit_t;



//***** Operation Command
`define OpCommandWidth	5	// (仮)
`define OpCommand		`OpCommandWidth-1:0
typedef union packed {
	AluCommand_t		alu;
	MemCommand_t		mem;
} OpCommand_t;



//***** Immediate Encoding
`define ImmShiftWidth	2
`define ImmShift		`ImmShiftWidth-1:0
`define ImmSizeWidth	2
`define ImmSize			`ImmSizeWidth-1:0
`define ImmDataWidth	20
`define ImmData			`ImmDataWidth-1:0
`define ImmWidth		26
//*** Immediate shift encoding
typedef enum logic [`ImmShift] {
	IMM_NO_SHIFT	= `ImmShiftWidth'b00,
	IMM_SHIFT1		= `ImmShiftWidth'b01,
	IMM_SHIFT12		= `ImmShiftWidth'b10
} ImmShift_t;

//*** Immediate bit width encoding
typedef enum logic [`ImmSize] {
	IMM_SIZE5		= `ImmSizeWidth'b00,
	IMM_SIZE12		= `ImmSizeWidth'b01,
	IMM_SIZE12_5	= `ImmSizeWidth'b10,
	IMM_SIZE20		= `ImmSizeWidth'b11
} ImmSize_t;

typedef struct packed {
	logic				sign;	// sign extenstion
	ImmShift_t			shift;	// shift amount
	ImmSize_t			size;	// immediate size
	logic [`ImmData]	data;
} ImmData_t;

`endif //_DECODE_SVH_INCLUDED_
