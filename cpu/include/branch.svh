/*
* <branch.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _BRANCH_SVH_INCLUDED_
`define _BRANCH_SVH_INCLUDED_

//***** Branch and Jump instruction format
`define BrInstTypeWidth		3
`define BrInstType			`BrInstTypeWidth-1:0
typedef enum logic [`BrInstType] {
	BRTYPE_NONE		= `BrInstTypeWIdth'b000,	// Not a branch
	BRTYPE_BRANCH	= `BrInstTypeWidth'b001,	// Branch
	BRTYPE_JUMP		= `BrInstTypeWidth'b010,	// normal jump, jr
	BRTYPE_CALL		= `BrInstTypeWidth'b011,	// function call
	BRTYPE_RET		= `BrInstTypeWidth'b100		// function return
} BrInstType_t;

//***** branch instruction direction
`define BrTaken			0	// taken
`define BrNTaken		1	// not taken

`endif // _BRANCH_SVH_INCLUDED_
