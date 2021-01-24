/*
 * $Id: fpu.h,v 1.7.6.1.2.1.2.4 2019/01/08 00:15:20 beppu Exp $
 *
 *  Header File for Floating Point Execution Unit
 *
 */

/***************** for dc shell ********************/
`define DW_INCLUDE_IEEE754
`define FPU_NO_PIPELINE
/***************************************************/

`define EXEFPUNO           2        // Execution FPU Number

// Floating Point Unit Operation
`define FLOATINGPOINT      9        // Floating-Point Operation Width
`define FPU_OP             2:0      // Floating-Point Operation ( Define Below )
`define FPU_CVTTO          4:3      // Convert Mode ( Define Below )
`define FPU_NEG            3        // Negate Operation
`define FPU_ABS            4        // Absolute Operation
`define FPU_SUB            4        // Subtract Operation
`define FPU_ROUND          6:5      // Rounding Mode ( Define Below )
`define FPU_INTEGER        7        // Operand is the Word ( Integer ) Precision
`define FPU_DOUBLE         8        // Operands are the Double Precision
`define FPU_CONDITION      6:3      // Compare Condition
`define FPU_COND_INV       6        // Compare Invalid
`define FPU_COND_CF        5:3      // Condition Field

// Floating Point Operation Code
`define FPU_NOP            3'b000   // No Operation
`define FPU_THROUGH        3'b001   // Through Input0 Operation
`define FPU_ADD            3'b010   // Add Operation
`define FPU_MUL            3'b011   // Multiply Operation
`define FPU_CONVERT        3'b100   // Convert Operation
`define FPU_COMPARE        3'b101   // Compare Operation

// Convert Mode
`define FPU_CVTTOI         4        // Convert Mode ( to Integer )
`define FPU_CVTTOD         3        // Convert Mode ( to Double )
`define FPU_CVTTO_SINGLE   2'b00    // Convert to Single Precision
`define FPU_CVTTO_DOUBLE   2'b01    // Convert to Double Precision
`define FPU_CVTTO_INTEGER  2'b10    // Convert to Integer
`define FPU_CVTTO_INT_RND  2'b11    // Convert to Integer with Rounding Mode

// Floating Point Unit Error
`define FPU_EXCEPTION      4       // Floating Point Exception Width
`define FPU_EXP_OVF        0       // Overflow Exception
`define FPU_EXP_UDF        1       // Underflow Exception
`define FPU_EXP_IXC        2       // Inexact Exception
`define FPU_EXP_INV        3       // Invalid Exception

// Rounding Mode
`define RND                2       // Rounding Mode Width
`define RND_NEAR           2'b00   // Round to Nearest
`define RND_TRUNC          2'b01   // Round to Zero
`define RND_CEIL           2'b10   // Round to Positive Infinity
`define RND_FLOOR          2'b11   // Round to Negative Infinity

`define NormalizeWidth     6
`define BiasWidth          11
`define MaxWidth           12
`define MinWidth           11

// Pipeline Buffer
`define FPU_DELAY          3        // Floating Point Execution Delay

`define FPU_ROUNDNEAR      2'b00

`define FPU_CTRLR_WIDTH    6
`define FPU_CTRLR_RND      5:4
`define FPU_CTRLR_MASK     3:0
`define FPU_CTRLR_MASK_I   3
`define FPU_CTRLR_MASK_U   2
`define FPU_CTRLR_MASK_O   1
`define FPU_CTRLR_MASK_V   0
