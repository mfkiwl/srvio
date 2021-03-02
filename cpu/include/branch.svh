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
`define BrInstTypeWidth		2
`define BrInstType			`BrInstTypeWidth-1:0
typedef enum logic [`BrInstType] {
	BRTYPE_BRANCH	= `BrInstTypeWidth'b00,
	BRTYPE_JUMP		= `BrInstTypeWidth'b01,	// normal jump, jr
	BRTYPE_CALL		= `BrInstTypeWidth'b10,	// function call
	BRTYPE_RET		= `BrInstTypeWidth'b11	// function return
} BrInstType_t;

//***** branch instruction direction
`define BrTaken			1	// taken
`define BrNTaken		0	// not taken

`endif // _BRANCH_SVH_INCLUDED_
