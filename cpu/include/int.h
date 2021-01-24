/*
-- ============================================================================
-- FILE	 : int.h
--			: header for integer unit
-- ----------------------------------------------------------------------------
-- Revision	Date		Coding_by	Comment
-- 1.0.0	 2019/3/23	ide			copied from respii.
-- ============================================================================
*/

`define EXEINTNO		4		// Execution Integer Number

// Integer Unit Operation
`define INTEGER			7		// Integer Operation Width
`define INT_OP			3:0		// Integer Operation ( Define Below )
`define INT_RIGHT		4		// Shift Right
`define INT_ROTATE		5		// Rotate Operation
`define INT_ARITH		6		// Shift with Arithmetic
`define INT_UNSIGNED	4		// Add / Multiply with Unsigned
`define INT_HIGH		6		// High Word is Taken for Multiply
`define INT_SUB			6		// Subtract Operation for Add
`define INT_NOT			6		// Not Operation for Or
/*
`define INT_SYSCALL		4		// System Call Exception
`define INT_BREAK		5		// Break Operation
`define INT_INVINST		6		// Invalid Exception
*/
`define INT_EXP_CODE	6:4		// Exception Code

// Integer Operation Code
`define INT_NOP			4'b0000	// No Operation
`define INT_AND			4'b0001	// And Operation
`define INT_OR			4'b0010	// Or Operation
`define INT_XOR			4'b0011	// Exclusive Operation
`define INT_ADD			4'b0100	// Add Operation
`define INT_MULT		4'b0101	// Multiply Operation
`define INT_SHIFT		4'b0110	// Shift Operation
`define INT_COMP		4'b0111	// Compare Operation
`define INT_THROUGH		4'b1000	// Through Operation
`define INT_EXP			4'b1001	// Exception

/*
// Exception Code
`define INT_EXP_CODE_SYSCALL	3'h0
`define INT_EXP_CODE_BREAK		3'h1
`define INT_EXP_CODE_INVINST	3'h2
`define INT_EXP_CODE_IMMU_LENT	3'h4
`define INT_EXP_CODE_IMMU_GENT	3'h5
`define INT_EXP_CODE_IMMU_PRO	3'h6
*/
