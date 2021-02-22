/*
* <issue.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _ISSUE_SVH_INCLUDED_
`define _ISSUE_SVH_INCLUDED_

//***** register operand status
`define RegStatWidth	2
`define RegStat			`RegStatWidth-1:0
`define RegStatReady_	1	// bit1 means operand ready
typedef enum logic [`RegStat] {
	REG_READY		= `RegStatWidth'b00,
	REG_WAIT_WB		= `RegStatWidth'b01,
	REG_WAIT_EXE	= `RegStatWidth'b10,
	REG_WAIT		= `RegStatWidth'b11
} RegStat_t;

`endif // _ISSUE_SVH_INCLUDED_
