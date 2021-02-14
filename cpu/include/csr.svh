/*
* <csr.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _CSR_SVH_INCLUDED_
`define _CSR_SVH_INCLUDED_

`include "cpu_config.svh"

/***** control register parameter *****/
`define CsrData			`DataWidth
`define CsrAddrWidth	12
`define CsrAddr			`CsrAddrWidth-1:0



//***** Privileged level (not accessable from csr instructions)
`define PrivLvWidth		2
`define PrivLv			`PrivLvWidth-1:0
typedef enum logic [`PrivLv] {
	PRIV_USER		= `PrivLvWidth'b00,		// user mode
	PRIV_SV			= `PrivLvWidth'b01,		// supervisor mode
	PRIV_MACHINE	= `PrivLvWidth'b11		// machine mode 
} PrivLw_t;



//***** List of Control & Status Registers
//*** User Trap Setup
//* User Status Register
`define CsrUSTATUS			`CsrAddrWidth'h000
//* User Interrupt Enable
`define CsrUIE				`CsrAddrWidth'h004
//* User Trap Handler Base Address
`define CsrUTVEC			`CsrAddrWidth'h005

//*** User Trap Handling
//* Scratch Register for User Trap Handlers
`define CsrUSCRATCH			`CsrAddrWidth'h040
//* User Exception Program Counter
`define CsrUEPC				`CsrAddrWidth'h041
//* User Trap Cause
`define CsrUCAUSE			`CsrAddrWidth'h042
//* User Bad Address or Instruction
`define CsrUTVAL			`CsrAddrWidth'h043
//* User Interrupt Pending
`define CsrUIP				`CsrAddrWidth'h044

//*** User Floating Point CSR
//* Floating-Point Accrued Exceptions
`define CsrFFLAGS			`CsrAddrWidth'h001
//* Floating-Point Dynamic Rounding Mode
`define CsrFRM				`CsrAddrWidth'h002
//* Floating-Point Control and Status Register
`define CsrFCSR				`CsrAddrWidth'h003

//*** User Counter/Timers
//* Cycle Counter for RDCYCLE instruction
`define CsrCYCLE			`CsrAddrWidth'hc00
`define CsrCYCLEH			`CsrAddrWidth'hc80	// RV32 only
//* Timer for RDTIME instruction
`define CsrTIME				`CsrAddrWidth'hc01
`define CsrTIMEH			`CsrAddrWidth'hc81	// RV32 only
//* Instruction-retired counter for RDINSTRET instruction
`define CsrINSTRET			`CsrAddrWidth'hc02
`define CsrINSTRETH			`CsrAddrWidth'hc82	// RV32 only
//* Performance-monitoring Counter
`define CsrHPMCOUNTER3		`CsrAddrWidth'hc03
`define CsrHPMCOUNTER4		`CsrAddrWidth'hc04
`define CsrHPMCOUNTER5		`CsrAddrWidth'hc05
`define CsrHPMCOUNTER6		`CsrAddrWidth'hc06
`define CsrHPMCOUNTER7		`CsrAddrWidth'hc07
`define CsrHPMCOUNTER8		`CsrAddrWidth'hc08
`define CsrHPMCOUNTER9		`CsrAddrWidth'hc09
`define CsrHPMCOUNTER10		`CsrAddrWidth'hc0a
`define CsrHPMCOUNTER11		`CsrAddrWidth'hc0b
`define CsrHPMCOUNTER12		`CsrAddrWidth'hc0c
`define CsrHPMCOUNTER13		`CsrAddrWidth'hc0d
`define CsrHPMCOUNTER14		`CsrAddrWidth'hc0e
`define CsrHPMCOUNTER15		`CsrAddrWidth'hc0f
`define CsrHPMCOUNTER16		`CsrAddrWidth'hc10
`define CsrHPMCOUNTER17		`CsrAddrWidth'hc11
`define CsrHPMCOUNTER18		`CsrAddrWidth'hc12
`define CsrHPMCOUNTER19		`CsrAddrWidth'hc13
`define CsrHPMCOUNTER20		`CsrAddrWidth'hc14
`define CsrHPMCOUNTER21		`CsrAddrWidth'hc15
`define CsrHPMCOUNTER22		`CsrAddrWidth'hc16
`define CsrHPMCOUNTER23		`CsrAddrWidth'hc17
`define CsrHPMCOUNTER24		`CsrAddrWidth'hc18
`define CsrHPMCOUNTER25		`CsrAddrWidth'hc19
`define CsrHPMCOUNTER26		`CsrAddrWidth'hc1a
`define CsrHPMCOUNTER27		`CsrAddrWidth'hc1b
`define CsrHPMCOUNTER28		`CsrAddrWidth'hc1c
`define CsrHPMCOUNTER29		`CsrAddrWidth'hc1d
`define CsrHPMCOUNTER30		`CsrAddrWidth'hc1e
`define CsrHPMCOUNTER31		`CsrAddrWidth'hc1f
`define CsrHPMCOUNTER3H		`CsrAddrWidth'hc03	// only for RV32
`define CsrHPMCOUNTER4H		`CsrAddrWidth'hc04
`define CsrHPMCOUNTER5H		`CsrAddrWidth'hc05
`define CsrHPMCOUNTER6H		`CsrAddrWidth'hc06
`define CsrHPMCOUNTER7H		`CsrAddrWidth'hc07
`define CsrHPMCOUNTER8H		`CsrAddrWidth'hc08
`define CsrHPMCOUNTER9H		`CsrAddrWidth'hc09
`define CsrHPMCOUNTER10H	`CsrAddrWidth'hc0a
`define CsrHPMCOUNTER11H	`CsrAddrWidth'hc0b
`define CsrHPMCOUNTER12H	`CsrAddrWidth'hc0c
`define CsrHPMCOUNTER13H	`CsrAddrWidth'hc0d
`define CsrHPMCOUNTER14H	`CsrAddrWidth'hc0e
`define CsrHPMCOUNTER15H	`CsrAddrWidth'hc0f
`define CsrHPMCOUNTER16H	`CsrAddrWidth'hc10
`define CsrHPMCOUNTER17H	`CsrAddrWidth'hc11
`define CsrHPMCOUNTER18H	`CsrAddrWidth'hc12
`define CsrHPMCOUNTER19H	`CsrAddrWidth'hc13
`define CsrHPMCOUNTER20H	`CsrAddrWidth'hc14
`define CsrHPMCOUNTER21H	`CsrAddrWidth'hc15
`define CsrHPMCOUNTER22H	`CsrAddrWidth'hc16
`define CsrHPMCOUNTER23H	`CsrAddrWidth'hc17
`define CsrHPMCOUNTER24H	`CsrAddrWidth'hc18
`define CsrHPMCOUNTER25H	`CsrAddrWidth'hc19
`define CsrHPMCOUNTER26H	`CsrAddrWidth'hc1a
`define CsrHPMCOUNTER27H	`CsrAddrWidth'hc1b
`define CsrHPMCOUNTER28H	`CsrAddrWidth'hc1c
`define CsrHPMCOUNTER29H	`CsrAddrWidth'hc1d
`define CsrHPMCOUNTER30H	`CsrAddrWidth'hc1e
`define CsrHPMCOUNTER31H	`CsrAddrWidth'hc1f

//*** Supervisor Trap Status
//* Supervisor status register
`define CsrSSTATUS			`CsrAddrWidth'h100
//* Supervisor exception delegation register
`define CsrSEDELEG			`CsrAddrWidth'h102
//* Supervisor interrupt delegation register
`define CsrSIDELEG			`CsrAddrWidth'h103
//* Supervisor interrupt-enable register
`define CsrSIE				`CsrAddrWidth'h104
//* Supervisor trap handler base address
`define CsrSTVEC			`CsrAddrWidth'h105
//* Supervisor counter enable
`define CsrSCOUNTEREN		`CsrAddrWidth'h106

//*** Supervisor Trap Handling
//* Scratch register for supervisor trap handlers
`define CsrSSCRATCH			`CsrAddrWidth'h140
//* Supervisor exception program counter
`define CsrSEPC				`CsrAddrWidth'h141
//* Supervisor trap cause
`define CsrSCAUSE			`CsrAddrWidth'h142
//* Supervisor bad address or instruction
`define CsrSTVAL			`CsrAddrWidth'h143
//* Supervisor interrupt pending
`define CsrSIP				`CsrAddrWidth'h144

//*** Supervisor Protection and Translatoin
//* Supervisor address translation and protection
`define CsrSATP				`CsrAddrWidth'h180
`ifdef CPU64 //64bit cpu
 `define CsrSATP_MODE		4
 `define CsrSATP_ASID		16
 `define CsrSATP_PPN		44
 `define CsrSATP_MODE_BARE	`SATP_MODE'b0000
 `define CsrSATP_MODE_SV37	`SATP_MODE'b1000
 `define CsrSATP_MODE_SV48	`SATP_MODE'b1001
 `define CsrSATP_MODE_SV57	`SATP_MODE'b1010
 `define CsrSATP_MODE_SV64	`SATP_MODE'b1011
`else // 32bit cpu
 `define CsrSATP_MODE		1
 `define CsrSATP_ASID		9
 `define CsrSATP_PPN		22
 `define CsrSATP_MODE_BARE	`SATP_MODE'b0
 `define CsrSATP_MODE_SV32	`SATP_MODE'b1
`endif

//*** Machine Information Register
//* Vendor ID
`define CsrMVENDORID		`CsrAddrWidth'hf11
//* Architecture ID
`define CsrMARCHID			`CsrAddrWidth'hf12
//* Implementation ID
`define CsrMIMPID			`CsrAddrWidth'hf13
//* Hardware thread ID
`define CsrMHARTID			`CsrAddrWidth'hf14

//*** Machine Trap Setup
//* Machine status register (also read from
`define CsrMSTATUS			`CsrAddrWidth'h300
`define CsrMST_MPP			2
`define CsrMST_FS			2
`define CsrMST_XS			2
`ifdef CPU64
 `define CsrMST_WPRI0		1		// reserved part0 [2]
 `define CsrMST_WPRI1		1		// reserved part1 [6]
 `define CsrMST_WPRI2		2		// reserved part2 [10:9]
 `define CsrMST_WPRI3		9		// reserved part3 [31:23]
 `define CsrMST_WPRI4		27		// reserved part4 [62:36]
 `define CsrMST_UXL			2
 `define CsrMST_SXL			2
`else // 32bit cpu
 `define CsrMST_WPRI0		1		// reserved part0 [2]
 `define CsrMST_WPRI1		1		// reserved part1 [6]
 `define CsrMST_WPRI2		2		// reserved part2 [10:9]
 `define CsrMST_WPRI3		8		// reserved part3 [30:23]
`endif
//* ISA and extensions
`define CsrMISA				`CsrAddrWidth'h301
//* Machine exception delegation register
`define CsrMEDELEG			`CsrAddrWidth'h302
//* Machine interrupt delegation register
`define CsrMIDELEG			`CsrAddrWidth'h303
//* Machine interrupt-enable register
`define CsrMIE				`CsrAddrWidth'h304
//* Machine trap-handler base address
`define CsrMTVEC			`CsrAddrWidth'h305
//* Machine counter enable
`define CsrMCOUNTEREN		`CsrAddrWidth'h306

//*** Machine Trap Handling
//* Scratch register for machine trap handlers
`define CsrMSCRATCH			`CsrAddrWidth'h340
//* Machine exception program counter
`define CsrMEPC				`CsrAddrWidth'h341
//* Machine trap cause
`define CsrMCAUSE			`CsrAddrWidth'h342
//* Machine bad address or instruction
`define CsrMTVAL			`CsrAddrWidth'h343
//* Machine interrupt pending
`define CsrMIP				`CsrAddrWidth'h344

//*** Machine Protection and Translation
//* physical memory protection configuration
`define CsrPMPCFG0			`CsrAddrWidth'h3a0
`define CsrPMPCFG1			`CsrAddrWidth'h3a1	// RV32 only
`define CsrPMPCFG2			`CsrAddrWidth'h3a2
`define CsrPMPCFG3			`CsrAddrWidth'h3a3	// RV32 only
//* physical memory protection address register
`define CsrPMPADDR0			`CsrAddrWidth'h3b0
`define CsrPMPADDR1			`CsrAddrWidth'h3b1
`define CsrPMPADDR2			`CsrAddrWidth'h3b2
`define CsrPMPADDR3			`CsrAddrWidth'h3b3
`define CsrPMPADDR4			`CsrAddrWidth'h3b4
`define CsrPMPADDR5			`CsrAddrWidth'h3b5
`define CsrPMPADDR6			`CsrAddrWidth'h3b6
`define CsrPMPADDR7			`CsrAddrWidth'h3b7
`define CsrPMPADDR8			`CsrAddrWidth'h3b8
`define CsrPMPADDR9			`CsrAddrWidth'h3b9
`define CsrPMPADDR10		`CsrAddrWidth'h3ba
`define CsrPMPADDR11		`CsrAddrWidth'h3bb
`define CsrPMPADDR12		`CsrAddrWidth'h3bc
`define CsrPMPADDR13		`CsrAddrWidth'h3bd
`define CsrPMPADDR14		`CsrAddrWidth'h3be
`define CsrPMPADDR15		`CsrAddrWidth'h3bf

//*** Machine Counter/Times
`define CsrMCYCLE			`CsrAddrWidth'hb00
`define CsrMINSTRET			`CsrAddrWidth'hb02
//* Performance-monitoring Counter
`define CsrMHPMCOUNTER3		`CsrAddrWidth'hc03
`define CsrMHPMCOUNTER4		`CsrAddrWidth'hc04
`define CsrMHPMCOUNTER5		`CsrAddrWidth'hc05
`define CsrMHPMCOUNTER6		`CsrAddrWidth'hc06
`define CsrMHPMCOUNTER7		`CsrAddrWidth'hc07
`define CsrMHPMCOUNTER8		`CsrAddrWidth'hc08
`define CsrMHPMCOUNTER9		`CsrAddrWidth'hc09
`define CsrMHPMCOUNTER10	`CsrAddrWidth'hc0a
`define CsrMHPMCOUNTER11	`CsrAddrWidth'hc0b
`define CsrMHPMCOUNTER12	`CsrAddrWidth'hc0c
`define CsrMHPMCOUNTER13	`CsrAddrWidth'hc0d
`define CsrMHPMCOUNTER14	`CsrAddrWidth'hc0e
`define CsrMHPMCOUNTER15	`CsrAddrWidth'hc0f
`define CsrMHPMCOUNTER16	`CsrAddrWidth'hc10
`define CsrMHPMCOUNTER17	`CsrAddrWidth'hc11
`define CsrMHPMCOUNTER18	`CsrAddrWidth'hc12
`define CsrMHPMCOUNTER19	`CsrAddrWidth'hc13
`define CsrMHPMCOUNTER20	`CsrAddrWidth'hc14
`define CsrMHPMCOUNTER21	`CsrAddrWidth'hc15
`define CsrMHPMCOUNTER22	`CsrAddrWidth'hc16
`define CsrMHPMCOUNTER23	`CsrAddrWidth'hc17
`define CsrMHPMCOUNTER24	`CsrAddrWidth'hc18
`define CsrMHPMCOUNTER25	`CsrAddrWidth'hc19
`define CsrMHPMCOUNTER26	`CsrAddrWidth'hc1a
`define CsrMHPMCOUNTER27	`CsrAddrWidth'hc1b
`define CsrMHPMCOUNTER28	`CsrAddrWidth'hc1c
`define CsrMHPMCOUNTER29	`CsrAddrWidth'hc1d
`define CsrMHPMCOUNTER30	`CsrAddrWidth'hc1e
`define CsrMHPMCOUNTER31	`CsrAddrWidth'hc1f
`define CsrMHPMCOUNTER3H	`CsrAddrWidth'hc03	// only for RV32
`define CsrMHPMCOUNTER4H	`CsrAddrWidth'hc04
`define CsrMHPMCOUNTER5H	`CsrAddrWidth'hc05
`define CsrMHPMCOUNTER6H	`CsrAddrWidth'hc06
`define CsrMHPMCOUNTER7H	`CsrAddrWidth'hc07
`define CsrMHPMCOUNTER8H	`CsrAddrWidth'hc08
`define CsrMHPMCOUNTER9H	`CsrAddrWidth'hc09
`define CsrMHPMCOUNTER10H	`CsrAddrWidth'hc0a
`define CsrMHPMCOUNTER11H	`CsrAddrWidth'hc0b
`define CsrMHPMCOUNTER12H	`CsrAddrWidth'hc0c
`define CsrMHPMCOUNTER13H	`CsrAddrWidth'hc0d
`define CsrMHPMCOUNTER14H	`CsrAddrWidth'hc0e
`define CsrMHPMCOUNTER15H	`CsrAddrWidth'hc0f
`define CsrMHPMCOUNTER16H	`CsrAddrWidth'hc10
`define CsrMHPMCOUNTER17H	`CsrAddrWidth'hc11
`define CsrMHPMCOUNTER18H	`CsrAddrWidth'hc12
`define CsrMHPMCOUNTER19H	`CsrAddrWidth'hc13
`define CsrMHPMCOUNTER20H	`CsrAddrWidth'hc14
`define CsrMHPMCOUNTER21H	`CsrAddrWidth'hc15
`define CsrMHPMCOUNTER22H	`CsrAddrWidth'hc16
`define CsrMHPMCOUNTER23H	`CsrAddrWidth'hc17
`define CsrMHPMCOUNTER24H	`CsrAddrWidth'hc18
`define CsrMHPMCOUNTER25H	`CsrAddrWidth'hc19
`define CsrMHPMCOUNTER26H	`CsrAddrWidth'hc1a
`define CsrMHPMCOUNTER27H	`CsrAddrWidth'hc1b
`define CsrMHPMCOUNTER28H	`CsrAddrWidth'hc1c
`define CsrMHPMCOUNTER29H	`CsrAddrWidth'hc1d
`define CsrMHPMCOUNTER30H	`CsrAddrWidth'hc1e
`define CsrMHPMCOUNTER31H	`CsrAddrWidth'hc1f

//*** Machine Counter Setup
`define CsrMHPMEVENT3		`CsrAddrWidth'h323
`define CsrMHPMEVENT4		`CsrAddrWidth'h324
`define CsrMHPMEVENT5		`CsrAddrWidth'h325
`define CsrMHPMEVENT6		`CsrAddrWidth'h326
`define CsrMHPMEVENT7		`CsrAddrWidth'h327
`define CsrMHPMEVENT8		`CsrAddrWidth'h328
`define CsrMHPMEVENT9		`CsrAddrWidth'h329
`define CsrMHPMEVENT10		`CsrAddrWidth'h32a
`define CsrMHPMEVENT11		`CsrAddrWidth'h32b
`define CsrMHPMEVENT12		`CsrAddrWidth'h32c
`define CsrMHPMEVENT13		`CsrAddrWidth'h32d
`define CsrMHPMEVENT14		`CsrAddrWidth'h32e
`define CsrMHPMEVENT15		`CsrAddrWidth'h32f
`define CsrMHPMEVENT16		`CsrAddrWidth'h330
`define CsrMHPMEVENT17		`CsrAddrWidth'h331
`define CsrMHPMEVENT18		`CsrAddrWidth'h332
`define CsrMHPMEVENT19		`CsrAddrWidth'h333
`define CsrMHPMEVENT20		`CsrAddrWidth'h334
`define CsrMHPMEVENT21		`CsrAddrWidth'h335
`define CsrMHPMEVENT22		`CsrAddrWidth'h336
`define CsrMHPMEVENT23		`CsrAddrWidth'h337
`define CsrMHPMEVENT24		`CsrAddrWidth'h338
`define CsrMHPMEVENT25		`CsrAddrWidth'h339
`define CsrMHPMEVENT26		`CsrAddrWidth'h33a
`define CsrMHPMEVENT27		`CsrAddrWidth'h33b
`define CsrMHPMEVENT28		`CsrAddrWidth'h33c
`define CsrMHPMEVENT29		`CsrAddrWidth'h33d
`define CsrMHPMEVENT30		`CsrAddrWidth'h33e
`define CsrMHPMEVENT31		`CsrAddrWidth'h33f

//*** Debug/Trace Register
//* Debug/Trace trigger register select
`define CsrTSELECT			`CsrAddrWidth'h7a0
//* Debug/Trace trigger data register
`define CsrTDATA1			`CsrAddrWidth'h7a1
`define CsrTDATA2			`CsrAddrWidth'h7a2
`define CsrTDATA3			`CsrAddrWidth'h7a3

//*** Debug Mode Register
`define CsrDCSR				`CsrAddrWidth'h7b0
`define CsrDPC				`CsrAddrWidth'h7b1
`define CsrDSCRATCH			`CsrAddrWidth'h7b2



//***** Parameters Common for All privilege levels
//*** trap-handler base address and mode
`define TvecModeWidth	2
`define TvecMode		`TvecModeWidth-1:0
`define TvecBaseWidth	(`DataWidth-`TVEC_MODE)
`define TvecBase		`TvecBaseWidth-1:0

typedef enum logic[`TvecMode] {
	TVEC_DIRECT	= `TvecModeWidth'b00,
	TVEC_VECTOR = `TvecModeWidth'b01
} TvecMode_t;

`endif // _CSR_SVH_INCLUDED_
