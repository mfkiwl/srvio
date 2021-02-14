/*
* <fpu.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _FPU_SVH_INCLUDED_
`define _FPU_SVH_INCLUDED_

//***** FPU Operation
//*** Operation Type
`define FpuOpWidth			3
`define FpuOp				`FpuOpWidth-1:0
typedef enum logic[`FpuOp] {
	FPU_NOP		= `AluOpWidth'b000,
	FPU_ADD		= `AluOpWidth'b001,
	FPU_MULT	= `AluOpWidth'b010,
	FPU_COMP	= `FpuOpWidth'b011,
	FPU_CONV_I	= `AluOpWidth'b100,
	FPU_CONV_F	= `AluOpWidth'b101
} FpuOp_t;

//*** Sub-operation
`define FpuSubOpWidth		4
`define FpuSubOp			`FpuSubOpWidth-1:0
//* Double or Single Precision
`define FpuDouble			0
//* Add or Sub select
`define FpuSub				1
//* Compare Condition
`define FpuCompLt			1
`define FpuCompNeg			2
//* Convert to Float/Integer
`define FpuCvtUnsigned		1
`define FpuCvtDWord			2

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

`endif // _FPU_SVH_INCLUDED_
