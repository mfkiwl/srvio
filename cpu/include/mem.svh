/*
* <mem.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _MEM_SVH_INCLUDED_
`define _MEM_SVH_INCLUDED_

//***** Memory Unit Operation
//*** Operation Type
`define MemOpWidth			3
`define MemOp				`MemOpWidth-1:0
typedef enum logic[`MemOp] {
	MEM_NOP		= `MemOpWidth'b000,
	MEM_LOAD	= `MemOpWidth'b001,
	MEM_STORE	= `MemOpWidth'b010,
	MEM_AMO		= `MemOpWidth'b011,
	MEM_CSR		= `MemOpWidth'b100
} MemOp_t;

//*** Sub-operation
`define MemSubOpWidth		4
`define MemSubOp			`MemSubOpWidth-1:0
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



//***** Mem Command
`define MemCommandWidth		7
typedef struct packed {
	logic [`MemSubOp]		sub_op;
	MemOp_t					op;
} MemCommand_t;

`endif // _MEM_SVH_INCLUDED_
