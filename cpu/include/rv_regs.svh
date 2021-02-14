/*
* <rv_regs.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _RV_REGS_SVH_INCLUDED_
`define _RV_REGS_SVH_INCLUDED_

`include "rv_opcodes.svh"

//***** GPR
`define RvZeroReg	`RvRegW'b00000		// (x0/zero) : Zero
`define RvRaReg		`RvRegW'b00001		// (x1/ra)	 : Return Address
`define RvSpReg		`RvRegW'b00010		// (x2/sp)	 : Stack Pointer
`define RvGpReg		`RvRegW'b00011		// (x3/gp)	 : Global Pointer
`define RvTpReg		`RvRegW'b00100		// (x4/tp)	 : Thread Pointer
`define RvT0Reg		`RvRegW'b00101		// (x5/t0)	 : Temporary0
`define RvT1Reg		`RvRegW'b00110		// (x6/t1)	 : Temporary1
`define RvT2Reg		`RvRegW'b00111		// (x7/t2)	 : Temporary2
`define RvS0Reg		`RvRegW'b01000		// (x8/s0/fp): Saved0
`define RvFpReg		`RvRegW'b01000		//			 : Frame Pointer
`define RvS1Reg		`RvRegW'b01001		// (x9/s1)	 : Saved1
`define RvA0Reg		`RvRegW'b01010		// (x10/a0)	 : Arg0 / Return value
`define RvA1Reg		`RvRegW'b01011		// (x11/a1)	 : Arg1 / Return value
`define RvA2Reg		`RvRegW'b01100		// (x12/a2)	 : Arg2
`define RvA3Reg		`RvRegW'b01101		// (x13/a3)	 : Arg3
`define RvA4Reg		`RvRegW'b01110		// (x14/a4)	 : Arg4
`define RvA5Reg		`RvRegW'b01111		// (x15/a5)	 : Arg5
`define RvA6Reg		`RvRegW'b10000		// (x16/a6)	 : Arg6
`define RvA7Reg		`RvRegW'b10001		// (x17/a7)	 : Arg7
`define RvS2Reg		`RvRegW'b10010		// (x18/s2)  : Saved2
`define RvS3Reg		`RvRegW'b10011		// (x19/s3)  : Saved3
`define RvS4Reg		`RvRegW'b10100		// (x20/s4)  : Saved4
`define RvS5Reg		`RvRegW'b10101		// (x21/s5)  : Saved5
`define RvS6Reg		`RvRegW'b10110		// (x22/s6)  : Saved6
`define RvS7Reg		`RvRegW'b10111		// (x23/s7)  : Saved7
`define RvS8Reg		`RvRegW'b11000		// (x24/s8)  : Saved8
`define RvS9Reg		`RvRegW'b11001		// (x25/s9)  : Saved9
`define RvS10Reg	`RvRegW'b11010		// (x26/s10) : Saved10
`define RvS11Reg	`RvRegW'b11011		// (x27/s11) : Saved11
`define RvT3Reg		`RvRegW'b11100		// (x28/t3)  : Temporary3
`define RvT4Reg		`RvRegW'b11101		// (x29/t4)  : Temporary4
`define RvT5Reg		`RvRegW'b11110		// (x30/t5)  : Temporary5
`define RvT6Reg		`RvRegW'b11111		// (x31/t6)  : Temporary6


//***** FPR Usage
`define RvFt0Reg		`RvRegW'b00000		// (f0/ft0)	 : Temporary0
`define RvFt1Reg		`RvRegW'b00001		// (f1/ft1)	 : Temporary1
`define RvFt2Reg		`RvRegW'b00010		// (f2/ft2)	 : Temporary2
`define RvFt3Reg		`RvRegW'b00011		// (f3/ft3)	 : Temporary3
`define RvFt4Reg		`RvRegW'b00100		// (f4/ft4)	 : Temporary4
`define RvFt5Reg		`RvRegW'b00101		// (f5/ft5)	 : Temporary5
`define RvFt6Reg		`RvRegW'b00110		// (f6/ft6)	 : Temporary6
`define RvFt6Reg		`RvRegW'b00111		// (f7/ft7)	 : Temporary7
`define RvFs0Reg		`RvRegW'b01000		// (f8/fs0)	 : Saved0
`define RvFs1Reg		`RvRegW'b01001		// (f9/fs1)	 : Saved1
`define RvFa0Reg		`RvRegW'b01010		// (f10/fa0) : Arg0 / Return value
`define RvFa1Reg		`RvRegW'b01011		// (f11/fa1) : Arg1 / Return value
`define RvFa2Reg		`RvRegW'b01100		// (f12/fa2) : Arg2
`define RvFa3Reg		`RvRegW'b01101		// (f13/fa3) : Arg3
`define RvFa4Reg		`RvRegW'b01110		// (f14/fa4) : Arg4
`define RvFa5Reg		`RvRegW'b01111		// (f15/fa5) : Arg5
`define RvFa6Reg		`RvRegW'b10000		// (f16/fa6) : Arg6
`define RvFa7Reg		`RvRegW'b10001		// (f17/fa7) : Arg7
`define RvFs2Reg		`RvRegW'b10010		// (f18/fs2) : Arg10
`define RvFs3Reg		`RvRegW'b10011		// (f19/fs3) : Saved3
`define RvFs4Reg		`RvRegW'b10100		// (f20/fs4) : Saved4
`define RvFs5Reg		`RvRegW'b10101		// (f21/fs5) : Saved5
`define RvFs6Reg		`RvRegW'b10110		// (f22/fs6) : Saved6
`define RvFs7Reg		`RvRegW'b10111		// (f23/fs7) : Saved7
`define RvFs8Reg		`RvRegW'b11000		// (f24/fs8) : Saved8
`define RvFs9Reg		`RvRegW'b11001		// (f25/fs9) : Saved9
`define RvFs10Reg		`RvRegW'b11010		// (f26/fs10): Saved10
`define RvFs11Reg		`RvRegW'b11011		// (f27/fs11): Saved11
`define RvFt3Reg		`RvRegW'b11100		// (f28/ft3) : Temporary3
`define RvFt4Reg		`RvRegW'b11101		// (f29/ft4) : Temporary4
`define RvFt5Reg		`RvRegW'b11110		// (f30/ft5) : Temporary5
`define RvFt6Reg		`RvRegW'b11111		// (f31/ft6) : Temporary6


`endif // _RV_REGS_SVH_INCLUDED_
