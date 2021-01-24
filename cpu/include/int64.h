/*
 * $Id: int64.h,v 1.3.12.1 2013/11/02 13:31:29 kaneda Exp $
 *
 *  Header File for 64bit Integer and SIMD Unit
 *
 */

`define EXEINT64NO     1               // Execution Integer64 Number

// Integer Unit Operation ( [6:0] is same to INT Unit )
`define INT64          10              // Integer Operation Width
`define INT64_MAIN     7               // Integer Operation Main Width

`define INT64_OP       3:0             // Integer Operation ( Define Below )
`define INT64_RIGHT    4               // Shift Right
`define INT64_ROTATE   5               // Rotate Operation
`define INT64_ARITH    6               // Shift with Arithmetic
`define INT64_UNSIGNED 4               // Add / Multiply with Unsigned
`define INT64_HIGH     6               // High Word is Taken for Multiply
`define INT64_SUB      6               // Subtract Operation for Add
`define INT64_NOT      6               // Not Operation for Or
`define INT64_THRSUB   5:4             // Through Sub Operation
`define INT64_SCALAR   7               // Scalar Operation
`define INT64_SIMD     9:8             // SIMD Operation ( Define Below )

// Integer Operation Code ( [2:0] is same to INT Unit )
`define INT64_NOP      4'b0000         // No Operation
`define INT64_AND      4'b0001         // AND Operation
`define INT64_OR       4'b0010         // OR, NOR Operation
`define INT64_XOR      4'b0011         // XOR Operation
`define INT64_ADD      4'b0100         // ADD, SUB, THROUGH Operation
`define INT64_MULT     4'b0101         // MULT Operation
`define INT64_SHIFT    4'b0110         // SLL, SRA, SRL Operation
`define INT64_COMP     4'b0111         // SLT Operation
`define INT64_THROUGH  4'b1000         // Through Operation

// SIMD Mode
`define INT64_SIMD64   2'b00           // 64bit Double Word Operation
`define INT64_SIMD8    2'b01           // 8bit x 8 Operation
`define INT64_SIMD16   2'b10           // 16bit x 4 Operation
`define INT64_SIMD32   2'b11           // 32bit x 2 Operation

// Through Sub Operation
`define INT64_THR_NRM  2'b00           // Through Normaly
`define INT64_THR_TLO  2'b01           // Through Low Value to High
`define INT64_THR_THI  2'b10           // Through High Value to Low

`define INT64_THR_PCK  2'b00           // Through with Pack Operation
`define INT64_THR_CT1  2'b01           // Through with Cat Type1 Operation
`define INT64_THR_CT2  2'b10           // Through with Cat Type2 Operation
`define INT64_THR_CT3  2'b11           // Through with Cat Type3 Operation
