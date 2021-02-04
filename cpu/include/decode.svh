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

//***** Functional Unit configuration
`define ExeUnitWidth	3
`define ExeUnitBus		(`ExeUnitWidth-1):0
typedef enum logic[`ExeUnitBus] {
	ExeUnitALU  = 0,
	ExeUnitDiv  = 1,
	ExeUnitFPU  = 2,
	ExeUnitFDiv = 3,
	ExeUnitMem	= 4
} ExeUnit_t;


typedef struct {
	ExeUnit_t	unit;
} Decode_t;

`endif //_DECODE_SVH_INCLUDED_
