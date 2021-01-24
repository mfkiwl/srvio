/*
-- ============================================================================
-- FILE     : rob.h
--			: Parameter for Reorder Buffer
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/12/7	ide			create new
-- ============================================================================
*/

`ifndef _ROB_H_INCLUDED_
`define _ROB_H_INCLUDED_

`ifndef _CPU_CONFIG_H_INCLUDED_
 $error("cpu_config.h must be included first");
`endif

/***** Reorder Buffer parameter *****/
`define RobWidth		`AddrWidth // + ~~~~ ( add something )
`define RobBus			`RobWidth-1:0		// Rnage of Rob
`define RobAddr			$clog2(`RobDepth)	// Address of Rob
`define RobAddrBus		`RobAddr-1:0		// Address bus of Rob

`endif // _ROB_H_INCLUDED_
