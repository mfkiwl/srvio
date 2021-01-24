/*
-- ============================================================================
-- FILE	 : mem.h
--			: header for memory unit
-- ----------------------------------------------------------------------------
-- Revision	Date		Coding_by	Comment
-- 1.0.0	 2019/3/24	ide			copied from respii.
-- ============================================================================
*/

`define EXEMEMNO          1         // Execution Memory Number

// Memory Access Unit Operation
`define MEMORY            10        // Memory Operation Width
`define MEMORY_SYNC       9         // Syncronization operation
`define MEMORY_UC         9         // Uncache Load / Store
`define MEMORY_OP         2:0       // Memory Operation ( Define Below )
`define MEMORY_RW_        3         // Store to Control Register
`define MEMORY_SIZE       6:4       // Access Size ( Define Below )
`define MEMORY_THREADOP   8:4       // Thread Control Sub Operation
`define MEMORY_UNSIGNED   7         // Load with Unsigned
`define MEMORY_CTRLSP     7         // Control Special Operation
`define MEMORY_ATOMIC     8         // Atomic Load / Store
`define MEMORY_SUBOP      8:4       // Memory Sub Operation

// Memory Operation Code
`define MEMORY_MEMORY     3'b001    // Load Operation
`define MEMORY_THREAD     3'b010    // Thread Control Operation
`define MEMORY_CTRL       3'b011    // Control Register Operation
`define MEMORY_IMMU       3'b100    // I-MMU Operation
`define MEMORY_DMMU       3'b101    // D-MMU Operation
`define MEMORY_CTRL2      3'b110    // Control Register Operation

// Access Size
`define MEMORY_SIZEW      3         // Size Specified Width
`define MEMORY_BYTE       3'b000    // Access with Byte Width
`define MEMORY_HALF       3'b001    // Access with Half Word Width
`define MEMORY_WORD       3'b010    // Access with Word Width
`define MEMORY_DOUBLEWORD 3'b011    // Access with Double Word Width
`define MEMORY_UNALIGNEDL 3'b100    // Access with Unaligned Width ( LEFT )
`define MEMORY_UNALIGNEDR 3'b101    // Access with Unaligned Width ( RIGHT )

`define MEMORY_SUBOP_VEC  5'b11111  // Vector Load / Store Operation

// Operation 
`define MEMORY_OPE_BUS    5:0       // Size + Uncache + Atomic + Unsigned or Thread Operation
`define MEMORY_OPE_SIZE   5:3       // Size
`define MEMORY_OPE_UC     2         // Uncache
`define MEMORY_OPE_ATOM   1         // Atomic
`define MEMORY_OPE_USIGN  0         // Unsigned

`define INFO_THREAD       13:11
