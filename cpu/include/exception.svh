/*
* <exception.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _EXCEPTION_SVH_INCLUDED_
`define _EXCEPTION_SVH_INCLUDED_

/***** Exception Code Parameter *****/
`define ExpCodeWidth		5
`define ExpCode				`ExpCodeWidth-1:0


/***** Exception Code List ( Interrupt in mcause is 1'b0 ) *****/
typedef enum logic[`ExpCode] {
	EXP_I_MISS_ALIGN	= 'b0_0000,	// Instruction Miss align
	EXP_I_FAULT			= 'b0_0001,	// Instruction Access Fault
	EXP_I_ILLEGAL		= 'b0_0010,	// Illegal Instruction
	EXP_BREAK			= 'b0_0011,	// Breakpoint Exception
	EXP_D_MISS_ALIGN	= 'b0_0100,	// Load Miss Align
	EXP_D_FAULT			= 'b0_0101,	// Load Access Fault
	EXP_AMO_MISS_ALIGN	= 'b0_0110,	// store/AMO miss align
	EXP_AMO_FAULT		= 'b0_0111,	// store/AMO Access Fault
	EXP_USER_ENV_CALL	= 'b0_1000,	// User Environment Call
	EXP_SV_ENV_CALL		= 'b0_1001,	// Supervisor Environment Call
//	EXP_				= 'b0_1010,	// Reserved
	EXP_MAC_ENV_CALL	= 'b0_1011,	// Machine Environment Call
	EXP_I_PAGE_FAULT	= 'b0_1100,	// Instruction Page Fault
	EXP_D_PAGE_FAULT	= 'b0_1101,	// Load (Data) Page Fault
//	EXP_				= 'b0_1110,	// Reserved
	EXP_AMO_PAGE_FAULT	= 'b0_1111	// Store/AMO Page Fault
//	EXP_				= 'b1_0000-	// Reserved
} ExpCode_t;


/***** Interrupt Code Parameter ( Interrupt in mcause is 1'b1 ) *****/
typedef enum logic[`ExpCode] {
	USER_SOFT_INT	= 'b0_0000,
	SV_SOFT_INT		= 'b0_0001
} IntCode_t;
/***** Interrupt Code List *****/
//TODO: fill
//ierrupt Exception	Code Description
//1		0			User software interrupt
//1 		1 			Supervisor software interrupt
//1 		2 			Reserved for future standard use
//1 		3 			Machine software interrupt
//1 		4 			User timer interrupt
//1 		5 			Supervisor timer interrupt
//1 		6 			Reserved for future standard use
//1 		7 			Machine timer interrupt
//1 		8 			User external interrupt
//1 		9 			Supervisor external interrupt
//1 		10			Reserved for future standard use
//1 		11 			Machine external interrupt
//1 		12–15		Reserved for future standard use
//1 		≥16		Reserved for platform use



//***** Interupt and Exception
`define ExpHandleWidth	(`ExpCodeWidth+1)
`define ExpHandle		`IntExpHandleWidth-1:0
typedef struct packed {
	logic		ie_;	// Interrupt (`High), Exception (`Low)
	union packed {
		ExpCode_t		e;
		IntCode_t		i;
	} code;
} ExpHandle_t;

`endif // _EXCEPTION_SVH_INCLUDED_
