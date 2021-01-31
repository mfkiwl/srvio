/*
* <datapath.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _DATAPATH_SVH_INCLUDED_
`define _DATAPATH_SVH_INCLUDED_

/***** CPU funtion unit configuration *****/
`define UnitWidth			3					// number of units
`define UnitBus				`UnitWidth-1:0		// Not Unit-Bath
`define UnitNop				`UnitWidth'b000		// No Unit assign
`define UnitInt				`UnitWidth'b001		// integer (alu)
`define UnitCint			`UnitWidth'b010		// int divider
`define UnitAgu				`UnitWidth'b011		// Address generation
`define UnitFpu				`UnitWidth'b100		// fpu
`define UnitCfpu			`UnitWidth'b101		// fp divider
`define UnitBranch			`UnitWidth'b110		// branch unit

/***** CPU operation code *****/
`define OpeWidth			10						// operation
`define OpeBus				`OpeWidth-1:0

`endif // _DATAPATH_SVH_INCLUDED_
