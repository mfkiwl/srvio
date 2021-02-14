/*
* <process_config.vh>
*
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
*
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _CPU_CONFIG_H_INCLUDED_
`define _CPU_CONFIG_H_INCLUDED_

`include "stddef.vh"

//***** CPU bit select
//`define CPU32		0
`define CPU64		1

//*** CPU ISA
typedef enum {
	ISA_RISCV	= 0,
	ISA_MIPS	= 1
} ISA_t;
`define CPU_ISA			ISA_RISCV	// ISA select (*)


//***** CPU Databus Configuration
`ifdef	CPU64
  //*** 64bit cpu
  `define DataWidth		64						// `DoubleBitWidth
  `define AddrWidth		64 						//
`else	// CPU32
  //*** 32bit cpu
  `define DataWidth		32 						// `WordBitWidth
  `define AddrWidth		32 						//
`endif

//*** Respective data width configuration
`define DataBus			`DataWidth-1:0			// Data bus range
`define AddrBus			`AddrWidth-1:0			// Address bus
`define InstWidth		`WordBitWidth			// 32bit ( 64bit and 32bit cpu )
`define InstBus			`InstWidth-1:0			// Instruction range


//***** Branch predictor configuration ( -> branch.h )
//*** quantity
`define PredTableDepth	1024					// # of Prediction table (*)
`define PredCntWidth	2						// counter width (*)
`define PredMaxDepth	4						// Prediction depth (*)
//*** prediction type
typedef enum {
	BR_PRED_CNT			= 0,
	BR_PRED_CORRELATE	= 1,
	BR_PRED_GSHARE		= 2,
	BR_PRED_TAGE		= 3
} BrPredType_t;
`define PredType		BR_PRED_CNT				// predictor select

//*** Branch Target Buffer Configuration
`define BtbTableDepth	256						// BTB Entry Depth
`define BtbCntWidth		2						// BTB confidence couter

//*** Return Address Stack Configuration ( -> branch.h )
`define RaStackDepth	16						// Depth of Return Address stack



//***** Instruction Execution (Out-of-Order)
`define SBDepth			16						// Depth of Score Board
`define RobDepth		16						// Depth of Rob
												//	up to 32-entry is supported



//***** Packing to Struct

`endif //_CPU_CONFIG_H_INCLUDED_
