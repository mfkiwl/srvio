/*
-- ============================================================================
-- FILE     : datapath.h
--			: general information about datapath
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/3/23	ide			create new
-- ============================================================================
*/

`ifndef _DEC_H_INCLUDED_
`define _DEC_H_INCLUDED_

/***** Extended Register Width *****/
`define ExtRegWidth		(`RV_REGW+1)	// reg + enable
`define ExtRegBus		`ExtRegWidth-1:0


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
//`define UnitMemory			`UnitWidth'b1000		// memory unit is renamed as AGU


/***** CPU operation code *****/
`define OpeWidth			10						// operation
`define OpeBus				`OpeWidth-1:0

`endif
