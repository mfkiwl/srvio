/*
 * $Id: cfpu.h,v 1.2.12.1 2013/11/02 13:31:28 kaneda Exp $
 *
 *  Header File for Complex Floating Point Execution Unit
 *
 */

`define EXECFPNO           1         // Execution Complex Floating Point Number

// Complex Floating Point Unit Operation
`define CFPU               3         // Complex Floating Point Operation Width
`define CFPU_OP            1:0       // Complex Floating Point Operation
`define CFPU_DOUBLE        2         // Double Presision

// Complex Floating Point Operation Code
`define CFPU_NOP           2'b00     // No Operation
`define CFPU_DIV           2'b01     // Floating Point Division
// `define CFPU_SQRT          2'b10     // Floating Point Square Root

// Rounding Mode
`define RND                2         // Rounding Mode Width
`define RND_NEAR           2'b00     // Round to Nearest
`define RND_TRUNC          2'b01     // Round to Zero
`define RND_CEIL           2'b10     // Round to Positive Infinity
`define RND_FLOOR          2'b11     // Round to Positive Infinity

// Other Definision
`define EXP_DNORM          6         // log2( FRAC_D )
`define DIV_BASE           60

// Division Part
`define STATE              4
`define RADIX              3
`define MUX                2

`define STATE_FIN          4'd15
`define STATE_FINP         4'd14
`define STATE_SETS         4'd9
`define STATE_SETD         4'd5
`define STATE_DENORM       4'd1

// Special Part
`define SPECIAL            2
`define SPE_NORM           2'b01
`define SPE_ZERO           2'b00
`define SPE_INF            2'b10
`define SPE_NAN            2'b11
`define SPE_DNOR           2'b00
`define SPE_TINY           2'b10
`define SPE_HUGE           2'b11
