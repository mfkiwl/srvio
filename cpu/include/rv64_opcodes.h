/*
-- ============================================================================
-- FILE     : rv64_opcodes.h
--			: 64bit risc-v instrcution sets
--			: format and different other than rv32 is describted
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/12/5	ide			create new
-- ============================================================================
*/
`ifndef _RV64_OPCODES_H_INCLUDED_
`define _RV64_OPCODES_H_INCLUDED_

`ifndef _RV32_OPCODES_H_INCLUDED_
 $error("rv32_opcodes.h must be included first");
`endif


/***** Basic parameter for RV64 *****/
`define RV64_FUNCT6_SRL		`RV_FUNCT6W'h000000	// srl, sll (64bit)
`define RV64_FUNCT6_SRA		`RV_FUNCT6W'h010000	// sra (64bit)

/***** RV64 Function Code *****/
`define RV64_FUNCT3_DOUBLE	`RV_FUNCT3W'h011	// load/store double
`define RV64_FUNCT3_UWORD	`RV_FUNCT3W'h110	// load word unsigned

`endif // _RV64_OPCODES_H_INCLUDED_
