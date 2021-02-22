/*
* <regfile.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _REGFILE_SVH_INCLUDED_
`define _REGFILE_SVH_INCLUDED_

`include "cpu_config.svh"

//***** GPR parameters
`define GprDepth		32						// GPR Entries
`define GprWidth		`DataWidth				// Bit width of GPR (32entry)
`define GprAddrWidth	$clog2(`GprDepth)		// 5
`define GprAddr			`GprAddrWidth-1:0		// 4:0


//***** FPR parameters
`define FprDepth		32						// FPR Entries
`define FprWidth		`DoubleBitWidth			// Bit width of FPR (32entry)
`define FprAddrWidth	$clog2(`FprDepth)		// 5
`define FprAddr			`FprAddrWidth-1:0		// 4:0



//***** Register File Index
`define RegTypeWidth	3
`define RegType			`RegTypeWidth-1:0
typedef enum logic[`RegType] {
	TYPE_NONE	= `RegTypeWidth'b000,
	TYPE_GPR	= `RegTypeWidth'b001,
	TYPE_FPR	= `RegTypeWidth'b010,
	TYPE_BYPASS	= `RegTypeWidth'b011,	// Bypass Register (Must be renamed)
	TYPE_IMM	= `RegTypeWidth'b100,	// Immediate
	TYPE_PC		= `RegTypeWidth'b101,	// use program counter
	TYPE_ROB	= `RegTypeWidth'b110	// Rob-based Rename Register
} RegType_t;

typedef struct packed {
	RegType_t				regtype;
	logic [`GprAddr]		addr;
} RegFile_t;

`endif // _REGFILE_SVH_INCLUDED_
