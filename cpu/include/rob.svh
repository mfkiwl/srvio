/*
* <rob.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _ROB_SVH_INCLUDED_
`define _ROB_SVH_INCLUDED_

//***** Instruction Type
`define RobWbTypeWidth	2
`define RobWbType		`RobWbTypeWidth-1:0
typedef enum logic [`RobWbType] {
	WB_TYPE_NOP		= `RobWbTypeWidth'b00,
	WB_TYPE_EXE		= `RobWbTypeWidth'b01,
	WB_TYPE_BR		= `RobWbTypeWidth'b10,
	WB_TYPE_JUMP	= `RobWbTypeWidth'b11
} RobWbType_t;

`endif // _ROB_SVH_INCLUDED_
