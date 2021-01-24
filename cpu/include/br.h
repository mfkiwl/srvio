/*
-- ============================================================================
-- FILE	 : br.h
--			: header for branch unit
-- ----------------------------------------------------------------------------
-- Revision	Date		Coding_by	Comment
-- 1.0.0	 2019/3/24	ide			Inplanted from respii.
-- ============================================================================
*/

`define EXEBRNO				2		// Execution Branch Number

// Branch Unit Operation	
`define BRANCH				9		// Branch Operation Width
`define BRANCH_OP			2:0		// Branch Operation ( Define Below )
`define BRANCH_COND			5:3		// Branch Condition ( Define Below )
`define BRANCH_UNSIGNED		6		// Compare with Unsigned
`define BRANCH_TRUE			6		// Branch on Condition True
`define BRANCH_LINK			7		// Branch with Link ( Procedure Call )
`define BRANCH_PREDTRUE		8		// Prediction True

// Branch Operation Code
`define BRANCH_NOP			3'b000	// No Operation
`define BRANCH_J			3'b001	// Jump Operation
`define BRANCH_JR			3'b010	// Jump Register Operation
`define BRANCH_TRAP			3'b011	// Trap Operation
`define BRANCH_BR			3'b100	// Branch Operation
`define BRANCH_BC			3'b101	// Floating Conditional Branch Operation
`define BRANCH_ERET			3'b110	// Exception Return

// Branch Condition
`define BRANCH_ATRUE		3'b000	// Always True
`define BRANCH_AFALSE		3'b001	// Always False
`define BRANCH_EQ			3'b010	// Equal
`define BRANCH_NE			3'b011	// Not Equal
`define BRANCH_GE			3'b100	// Greater Equal
`define BRANCH_LT			3'b101	// Less Than
`define BRANCH_GT			3'b110	// Greater Than
`define BRANCH_LE			3'b111	// Less Equal

// Branch Result
`define BRANCH_RESULT		3		// Branch Result Width
`define BRANCH_RES_JR		0		// Jump Register Operation
`define BRANCH_RES_TRN		1		// Trap Not Taken
`define BRANCH_RES_ERET		2		// Exception Return

// Branch Status
`define BRANCH_STATUS		6		// Branch Status Width
`define BRANCH_ST_JR		0		// Jump Register
`define BRANCH_ST_TR		1		// Trap Enable
`define BRANCH_ST_TRN		2		// Trap Disable
`define BRANCH_ST_ERET		3		// Exception Return
`define BRANCH_ST_HIT		4		// Branch Prediction Hit
`define BRANCH_ST_MISS		5		// Branch Prediction Miss

`define BRANCH_LINK_PLUS	3'd4	 // Value which Plus PC for Link Operation
