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
	BRTYPE_NONE		= 'b000,	// Not a branch
	BRTYPE_BRANCH	= 'b001,	// Branch
	BRTYPE_JUMP		= 'b010,	// normal jump, jr
	BRTYPE_CALL		= 'b011,	// function call
	BRTYPE_RET		= 'b100,	// function return
	BRTYPE_CALLRET	= 'b101		// function call/return
} BrInstType_t;

//***** branch instruction direction
`define BrTaken			0			// taken
`define BrNTaken		1			// not taken
`define DefaultPred		`BrTaken	// Prediction for Untracked Branch 

`endif // _BRANCH_SVH_INCLUDED_
