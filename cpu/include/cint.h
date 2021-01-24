/*
 * $Id: cint.h,v 1.7.10.1.2.4 2018/12/26 02:47:34 ide Exp $
 *
 *  Header File for Complex Integer Execution Unit
 *
 */

/******** for dc shell *********/
`define CINT_DIV_PIPE
`define SHORTER_DIV
/*******************************/

`define EXECINTNO		1				// Execution CINT Number

// Complex Integer Unit Operation
`define CINT			3				// Complex Integer Instruction Width
`define CINT_OP			1:0				// Complex Integer Operation
`define CINT_UNSIGNED	2				// Divide with Unsigned

// Complex Integer Operation Code
`define CINT_NOP		2'b00           // No Operation
`define CINT_DIV		2'b10           // DIV Operation
`define CINT_REM		2'b11           // Remainder Operation

// Pipeline Buffer
`ifdef CINT_DIV_PIPE
 `ifdef SHORTER_DIV
  `define CINT_DELAY		2			// shorter pipe (presume DW_div_pipe)
 `else
  `define CINT_DELAY		9			// Cint Execution Delay
 `endif
`else
 `define CINT_DELAY			9			// Cint Execution Delay
`endif
