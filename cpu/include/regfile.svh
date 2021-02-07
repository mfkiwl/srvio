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
`define GprAddr			`GprWidth-1:0			// 4:0


//***** FPR parameters
`define FprDepth		32						// FPR Entries
`define FprWidth		`DoubleBitWidth			// Bit width of FPR (32entry)
`define FprAddrWidth	$clog2(`FprDepth)		// 5
`define FpAddr			`FprAddr-1:0			// 4:0



//***** Register File Index
`define RegTypeWidth	3
`define RegType			`RegTypeWidth-1:0
typedef enum logic[`RegType] {
	TYPE_NONE	= 3'b000,
	TYPE_GPR	= 3'b001,
	TYPE_FPR	= 3'b010,
	TYPE_IMM	= 3'b011,	// Immediate
	TYPE_CSR	= 3'b100,	// CSR
	TYPE_PC		= 3'b101	// use program counter
} RegType_t;

typedef struct packed {
	RegType_t				regtype;
	logic [`GprAddr]		addr;
} RegFile_t;

`endif // _REGFILE_SVH_INCLUDED_
