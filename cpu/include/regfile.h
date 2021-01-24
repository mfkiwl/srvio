/*
-- ============================================================================
-- FILE     : regfile.h
--			: Parameter of register file
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/12/7	ide			create new
-- ============================================================================
*/

`ifndef _REGFLIE_H_INCLUDED_
`define _REGFILE_H_INCLUDED_

`ifndef _CPU_CONFIG_H_INCLUDED_
 $error("cpu_config.h must be included first");
`endif

/***** GPR parameters *****/
`define GprAddr			$clog2(`GprDepth)		// 5
`define GprAddrBus		`GprWidth-1:0			// 4:0
`define GpRenAddr		$clog2(`GpRenBufDepth)	// 7
`define GpRenAddrBus	`GpRenAddr-1:0			// 6:0
`define GpRenWidth		`GpRenAddr				// renamed ID width


/***** FPR parameters *****/
`define FprAddr			$clog2(`FprDepth)		// 5
`define FpAddrBus		`FprAddr-1:0			// 4:0
`define FpRenAddr		$clog2(`FpRenBufDepth)	// 6
`define FpRenAddrBus	`FpRenAddr-1:0			// 5:0
`define FpRenWidth		`FpRenAddr				// renamed ID width

`endif // _REGFILE_H_INCLUDED_
