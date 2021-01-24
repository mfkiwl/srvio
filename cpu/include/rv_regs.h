/*
-- ============================================================================
-- FILE     : rv_regs.h
--			: Register Usage of RISC-V
-- ----------------------------------------------------------------------------
-- Revision  Date		Coding_by	Comment
-- 1.0.0     2019/12/06	ide			create new
-- ============================================================================
*/

`ifndef _RV_REGS_H_INCLUDED_
`define _RV_REGS_H_INCLUDED_

`ifndef _RV32_OPCODES_H_INCLUDED_
 $error("rv32_opcodes.h must be included first");
`endif


/***** GPR Usage *****/
`define RV_ZERO_REG		`RV_REGW'b00000		// (x0/zero) : Zero
`define RV_RA_REG		`RV_REGW'b00001		// (x1/ra)	 : Return Address
`define RV_SP_REG		`RV_REGW'b00010		// (x2/sp)	 : Stack Pointer
`define RV_GP_REG		`RV_REGW'b00011		// (x3/gp)	 : Global Pointer
`define RV_TP_REG		`RV_REGW'b00100		// (x4/tp)	 : Thread Pointer
`define RV_T0_REG		`RV_REGW'b00101		// (x5/t0)	 : Temporary0
`define RV_T1_REG		`RV_REGW'b00110		// (x6/t1)	 : Temporary1
`define RV_T2_REG		`RV_REGW'b00111		// (x7/t2)	 : Temporary2
`define RV_S0_REG		`RV_REGW'b01000		// (x8/s0/fp): Saved0
`define RV_FP_REG		`RV_REGW'b01000		//			 : Frame Pointer
`define RV_S1_REG		`RV_REGW'b01001		// (x9/s1)	 : Saved1
`define RV_A0_REG		`RV_REGW'b01010		// (x10/a0)	 : Arg0 / Return value
`define RV_A1_REG		`RV_REGW'b01011		// (x11/a1)	 : Arg1 / Return value
`define RV_A2_REG		`RV_REGW'b01100		// (x12/a2)	 : Arg2
`define RV_A3_REG		`RV_REGW'b01101		// (x13/a3)	 : Arg3
`define RV_A4_REG		`RV_REGW'b01110		// (x14/a4)	 : Arg4
`define RV_A5_REG		`RV_REGW'b01111		// (x15/a5)	 : Arg5
`define RV_A6_REG		`RV_REGW'b10000		// (x16/a6)	 : Arg6
`define RV_A7_REG		`RV_REGW'b10001		// (x17/a7)	 : Arg7
`define RV_S2_REG		`RV_REGW'b10010		// (x18/s2)  : Saved2
`define RV_S3_REG		`RV_REGW'b10011		// (x19/s3)  : Saved3
`define RV_S4_REG		`RV_REGW'b10100		// (x20/s4)  : Saved4
`define RV_S5_REG		`RV_REGW'b10101		// (x21/s5)  : Saved5
`define RV_S6_REG		`RV_REGW'b10110		// (x22/s6)  : Saved6
`define RV_S7_REG		`RV_REGW'b10111		// (x23/s7)  : Saved7
`define RV_S8_REG		`RV_REGW'b11000		// (x24/s8)  : Saved8
`define RV_S9_REG		`RV_REGW'b11001		// (x25/s9)  : Saved9
`define RV_S10_REG		`RV_REGW'b11010		// (x26/s10) : Saved10
`define RV_S11_REG		`RV_REGW'b11011		// (x27/s11) : Saved11
`define RV_T3_REG		`RV_REGW'b11100		// (x28/t3)  : Temporary3
`define RV_T4_REG		`RV_REGW'b11101		// (x29/t4)  : Temporary4
`define RV_T5_REG		`RV_REGW'b11110		// (x30/t5)  : Temporary5
`define RV_T6_REG		`RV_REGW'b11111		// (x31/t6)  : Temporary6


/***** FPR Usage *****/
`define RV_FT0_REG		`RV_REGW'b00000		// (f0/ft0)	 : Temporary0
`define RV_FT1_REG		`RV_REGW'b00001		// (f1/ft1)	 : Temporary1
`define RV_FT2_REG		`RV_REGW'b00010		// (f2/ft2)	 : Temporary2
`define RV_FT3_REG		`RV_REGW'b00011		// (f3/ft3)	 : Temporary3
`define RV_FT4_REG		`RV_REGW'b00100		// (f4/ft4)	 : Temporary4
`define RV_FT5_REG		`RV_REGW'b00101		// (f5/ft5)	 : Temporary5
`define RV_FT6_REG		`RV_REGW'b00110		// (f6/ft6)	 : Temporary6
`define RV_FT6_REG		`RV_REGW'b00111		// (f7/ft7)	 : Temporary7
`define RV_FS0_REG		`RV_REGW'b01000		// (f8/fs0)	 : Saved0
`define RV_FS1_REG		`RV_REGW'b01001		// (f9/fs1)	 : Saved1
`define RV_FA0_REG		`RV_REGW'b01010		// (f10/fa0) : Arg0 / Return value
`define RV_FA1_REG		`RV_REGW'b01011		// (f11/fa1) : Arg1 / Return value
`define RV_FA2_REG		`RV_REGW'b01100		// (f12/fa2) : Arg2
`define RV_FA3_REG		`RV_REGW'b01101		// (f13/fa3) : Arg3
`define RV_FA4_REG		`RV_REGW'b01110		// (f14/fa4) : Arg4
`define RV_FA5_REG		`RV_REGW'b01111		// (f15/fa5) : Arg5
`define RV_FA6_REG		`RV_REGW'b10000		// (f16/fa6) : Arg6
`define RV_FA7_REG		`RV_REGW'b10001		// (f17/fa7) : Arg7
`define RV_FS2_REG		`RV_REGW'b10010		// (f18/fs2) : Arg10
`define RV_FS3_REG		`RV_REGW'b10011		// (f19/fs3) : Saved3
`define RV_FS4_REG		`RV_REGW'b10100		// (f20/fs4) : Saved4
`define RV_FS5_REG		`RV_REGW'b10101		// (f21/fs5) : Saved5
`define RV_FS6_REG		`RV_REGW'b10110		// (f22/fs6) : Saved6
`define RV_FS7_REG		`RV_REGW'b10111		// (f23/fs7) : Saved7
`define RV_FS8_REG		`RV_REGW'b11000		// (f24/fs8) : Saved8
`define RV_FS9_REG		`RV_REGW'b11001		// (f25/fs9) : Saved9
`define RV_FS10_REG		`RV_REGW'b11010		// (f26/fs10): Saved10
`define RV_FS11_REG		`RV_REGW'b11011		// (f27/fs11): Saved11
`define RV_FT3_REG		`RV_REGW'b11100		// (f28/ft3) : Temporary3
`define RV_FT4_REG		`RV_REGW'b11101		// (f29/ft4) : Temporary4
`define RV_FT5_REG		`RV_REGW'b11110		// (f30/ft5) : Temporary5
`define RV_FT6_REG		`RV_REGW'b11111		// (f31/ft6) : Temporary6


`endif // _RV_REGS_H_INCLUDED_
