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
	PRIV_USER		= 'b00,		// user mode
	PRIV_SV			= 'b01,		// supervisor mode
	PRIV_MACHINE	= 'b11		// machine mode 
} PrivLw_t;



//***** List of Control & Status Registers
//*** User Trap Setup
//* User Status Register
`define CsrUSTATUS			'h000
//* User Interrupt Enable
`define CsrUIE				'h004
//* User Trap Handler Base Address
`define CsrUTVEC			'h005

//*** User Trap Handling
//* Scratch Register for User Trap Handlers
`define CsrUSCRATCH			'h040
//* User Exception Program Counter
`define CsrUEPC				'h041
//* User Trap Cause
`define CsrUCAUSE			'h042
//* User Bad Address or Instruction
`define CsrUTVAL			'h043
//* User Interrupt Pending
`define CsrUIP				'h044

//*** User Floating Point CSR
//* Floating-Point Accrued Exceptions
`define CsrFFLAGS			'h001
//* Floating-Point Dynamic Rounding Mode
`define CsrFRM				'h002
//* Floating-Point Control and Status Register
`define CsrFCSR				'h003

//*** User Counter/Timers
//* Cycle Counter for RDCYCLE instruction
`define CsrCYCLE			'hc00
`define CsrCYCLEH			'hc80	// RV32 only
//* Timer for RDTIME instruction
`define CsrTIME				'hc01
`define CsrTIMEH			'hc81	// RV32 only
//* Instruction-retired counter for RDINSTRET instruction
`define CsrINSTRET			'hc02
`define CsrINSTRETH			'hc82	// RV32 only
//* Performance-monitoring Counter
`define CsrHPMCOUNTER3		'hc03
`define CsrHPMCOUNTER4		'hc04
`define CsrHPMCOUNTER5		'hc05
`define CsrHPMCOUNTER6		'hc06
`define CsrHPMCOUNTER7		'hc07
`define CsrHPMCOUNTER8		'hc08
`define CsrHPMCOUNTER9		'hc09
`define CsrHPMCOUNTER10		'hc0a
`define CsrHPMCOUNTER11		'hc0b
`define CsrHPMCOUNTER12		'hc0c
`define CsrHPMCOUNTER13		'hc0d
`define CsrHPMCOUNTER14		'hc0e
`define CsrHPMCOUNTER15		'hc0f
`define CsrHPMCOUNTER16		'hc10
`define CsrHPMCOUNTER17		'hc11
`define CsrHPMCOUNTER18		'hc12
`define CsrHPMCOUNTER19		'hc13
`define CsrHPMCOUNTER20		'hc14
`define CsrHPMCOUNTER21		'hc15
`define CsrHPMCOUNTER22		'hc16
`define CsrHPMCOUNTER23		'hc17
`define CsrHPMCOUNTER24		'hc18
`define CsrHPMCOUNTER25		'hc19
`define CsrHPMCOUNTER26		'hc1a
`define CsrHPMCOUNTER27		'hc1b
`define CsrHPMCOUNTER28		'hc1c
`define CsrHPMCOUNTER29		'hc1d
`define CsrHPMCOUNTER30		'hc1e
`define CsrHPMCOUNTER31		'hc1f
`define CsrHPMCOUNTER3H		'hc03	// only for RV32
`define CsrHPMCOUNTER4H		'hc04
`define CsrHPMCOUNTER5H		'hc05
`define CsrHPMCOUNTER6H		'hc06
`define CsrHPMCOUNTER7H		'hc07
`define CsrHPMCOUNTER8H		'hc08
`define CsrHPMCOUNTER9H		'hc09
`define CsrHPMCOUNTER10H	'hc0a
`define CsrHPMCOUNTER11H	'hc0b
`define CsrHPMCOUNTER12H	'hc0c
`define CsrHPMCOUNTER13H	'hc0d
`define CsrHPMCOUNTER14H	'hc0e
`define CsrHPMCOUNTER15H	'hc0f
`define CsrHPMCOUNTER16H	'hc10
`define CsrHPMCOUNTER17H	'hc11
`define CsrHPMCOUNTER18H	'hc12
`define CsrHPMCOUNTER19H	'hc13
`define CsrHPMCOUNTER20H	'hc14
`define CsrHPMCOUNTER21H	'hc15
`define CsrHPMCOUNTER22H	'hc16
`define CsrHPMCOUNTER23H	'hc17
`define CsrHPMCOUNTER24H	'hc18
`define CsrHPMCOUNTER25H	'hc19
`define CsrHPMCOUNTER26H	'hc1a
`define CsrHPMCOUNTER27H	'hc1b
`define CsrHPMCOUNTER28H	'hc1c
`define CsrHPMCOUNTER29H	'hc1d
`define CsrHPMCOUNTER30H	'hc1e
`define CsrHPMCOUNTER31H	'hc1f

//*** Supervisor Trap Status
//* Supervisor status register
`define CsrSSTATUS			'h100
//* Supervisor exception delegation register
`define CsrSEDELEG			'h102
//* Supervisor interrupt delegation register
`define CsrSIDELEG			'h103
//* Supervisor interrupt-enable register
`define CsrSIE				'h104
//* Supervisor trap handler base address
`define CsrSTVEC			'h105
//* Supervisor counter enable
`define CsrSCOUNTEREN		'h106

//*** Supervisor Trap Handling
//* Scratch register for supervisor trap handlers
`define CsrSSCRATCH			'h140
//* Supervisor exception program counter
`define CsrSEPC				'h141
//* Supervisor trap cause
`define CsrSCAUSE			'h142
//* Supervisor bad address or instruction
`define CsrSTVAL			'h143
//* Supervisor interrupt pending
`define CsrSIP				'h144

//*** Supervisor Protection and Translatoin
//* Supervisor address translation and protection
`define CsrSATP				'h180
`ifdef CPU64 //64bit cpu
 `define CsrSATP_MODE		4
 `define CsrSATP_ASID		16
 `define CsrSATP_PPN		44
 `define CsrSATP_MODE_BARE	'b0000
 `define CsrSATP_MODE_SV37	'b1000
 `define CsrSATP_MODE_SV48	'b1001
 `define CsrSATP_MODE_SV57	'b1010
 `define CsrSATP_MODE_SV64	'b1011
`else // 32bit cpu
 `define CsrSATP_MODE		1
 `define CsrSATP_ASID		9
 `define CsrSATP_PPN		22
 `define CsrSATP_MODE_BARE	`SATP_MODE'b0
 `define CsrSATP_MODE_SV32	`SATP_MODE'b1
`endif

//*** Machine Information Register
//* Vendor ID
`define CsrMVENDORID		'hf11
//* Architecture ID
`define CsrMARCHID			'hf12
//* Implementation ID
`define CsrMIMPID			'hf13
//* Hardware thread ID
`define CsrMHARTID			'hf14

//*** Machine Trap Setup
//* Machine status register (also read from
`define CsrMSTATUS			'h300
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
`define CsrMISA				'h301
//* Machine exception delegation register
`define CsrMEDELEG			'h302
//* Machine interrupt delegation register
`define CsrMIDELEG			'h303
//* Machine interrupt-enable register
`define CsrMIE				'h304
//* Machine trap-handler base address
`define CsrMTVEC			'h305
//* Machine counter enable
`define CsrMCOUNTEREN		'h306

//*** Machine Trap Handling
//* Scratch register for machine trap handlers
`define CsrMSCRATCH			'h340
//* Machine exception program counter
`define CsrMEPC				'h341
//* Machine trap cause
`define CsrMCAUSE			'h342
//* Machine bad address or instruction
`define CsrMTVAL			'h343
//* Machine interrupt pending
`define CsrMIP				'h344

//*** Machine Protection and Translation
//* physical memory protection configuration
`define CsrPMPCFG0			'h3a0
`define CsrPMPCFG1			'h3a1	// RV32 only
`define CsrPMPCFG2			'h3a2
`define CsrPMPCFG3			'h3a3	// RV32 only
//* physical memory protection address register
`define CsrPMPADDR0			'h3b0
`define CsrPMPADDR1			'h3b1
`define CsrPMPADDR2			'h3b2
`define CsrPMPADDR3			'h3b3
`define CsrPMPADDR4			'h3b4
`define CsrPMPADDR5			'h3b5
`define CsrPMPADDR6			'h3b6
`define CsrPMPADDR7			'h3b7
`define CsrPMPADDR8			'h3b8
`define CsrPMPADDR9			'h3b9
`define CsrPMPADDR10		'h3ba
`define CsrPMPADDR11		'h3bb
`define CsrPMPADDR12		'h3bc
`define CsrPMPADDR13		'h3bd
`define CsrPMPADDR14		'h3be
`define CsrPMPADDR15		'h3bf

//*** Machine Counter/Times
`define CsrMCYCLE			'hb00
`define CsrMINSTRET			'hb02
//* Performance-monitoring Counter
`define CsrMHPMCOUNTER3		'hc03
`define CsrMHPMCOUNTER4		'hc04
`define CsrMHPMCOUNTER5		'hc05
`define CsrMHPMCOUNTER6		'hc06
`define CsrMHPMCOUNTER7		'hc07
`define CsrMHPMCOUNTER8		'hc08
`define CsrMHPMCOUNTER9		'hc09
`define CsrMHPMCOUNTER10	'hc0a
`define CsrMHPMCOUNTER11	'hc0b
`define CsrMHPMCOUNTER12	'hc0c
`define CsrMHPMCOUNTER13	'hc0d
`define CsrMHPMCOUNTER14	'hc0e
`define CsrMHPMCOUNTER15	'hc0f
`define CsrMHPMCOUNTER16	'hc10
`define CsrMHPMCOUNTER17	'hc11
`define CsrMHPMCOUNTER18	'hc12
`define CsrMHPMCOUNTER19	'hc13
`define CsrMHPMCOUNTER20	'hc14
`define CsrMHPMCOUNTER21	'hc15
`define CsrMHPMCOUNTER22	'hc16
`define CsrMHPMCOUNTER23	'hc17
`define CsrMHPMCOUNTER24	'hc18
`define CsrMHPMCOUNTER25	'hc19
`define CsrMHPMCOUNTER26	'hc1a
`define CsrMHPMCOUNTER27	'hc1b
`define CsrMHPMCOUNTER28	'hc1c
`define CsrMHPMCOUNTER29	'hc1d
`define CsrMHPMCOUNTER30	'hc1e
`define CsrMHPMCOUNTER31	'hc1f
`define CsrMHPMCOUNTER3H	'hc03	// only for RV32
`define CsrMHPMCOUNTER4H	'hc04
`define CsrMHPMCOUNTER5H	'hc05
`define CsrMHPMCOUNTER6H	'hc06
`define CsrMHPMCOUNTER7H	'hc07
`define CsrMHPMCOUNTER8H	'hc08
`define CsrMHPMCOUNTER9H	'hc09
`define CsrMHPMCOUNTER10H	'hc0a
`define CsrMHPMCOUNTER11H	'hc0b
`define CsrMHPMCOUNTER12H	'hc0c
`define CsrMHPMCOUNTER13H	'hc0d
`define CsrMHPMCOUNTER14H	'hc0e
`define CsrMHPMCOUNTER15H	'hc0f
`define CsrMHPMCOUNTER16H	'hc10
`define CsrMHPMCOUNTER17H	'hc11
`define CsrMHPMCOUNTER18H	'hc12
`define CsrMHPMCOUNTER19H	'hc13
`define CsrMHPMCOUNTER20H	'hc14
`define CsrMHPMCOUNTER21H	'hc15
`define CsrMHPMCOUNTER22H	'hc16
`define CsrMHPMCOUNTER23H	'hc17
`define CsrMHPMCOUNTER24H	'hc18
`define CsrMHPMCOUNTER25H	'hc19
`define CsrMHPMCOUNTER26H	'hc1a
`define CsrMHPMCOUNTER27H	'hc1b
`define CsrMHPMCOUNTER28H	'hc1c
`define CsrMHPMCOUNTER29H	'hc1d
`define CsrMHPMCOUNTER30H	'hc1e
`define CsrMHPMCOUNTER31H	'hc1f

//*** Machine Counter Setup
`define CsrMHPMEVENT3		'h323
`define CsrMHPMEVENT4		'h324
`define CsrMHPMEVENT5		'h325
`define CsrMHPMEVENT6		'h326
`define CsrMHPMEVENT7		'h327
`define CsrMHPMEVENT8		'h328
`define CsrMHPMEVENT9		'h329
`define CsrMHPMEVENT10		'h32a
`define CsrMHPMEVENT11		'h32b
`define CsrMHPMEVENT12		'h32c
`define CsrMHPMEVENT13		'h32d
`define CsrMHPMEVENT14		'h32e
`define CsrMHPMEVENT15		'h32f
`define CsrMHPMEVENT16		'h330
`define CsrMHPMEVENT17		'h331
`define CsrMHPMEVENT18		'h332
`define CsrMHPMEVENT19		'h333
`define CsrMHPMEVENT20		'h334
`define CsrMHPMEVENT21		'h335
`define CsrMHPMEVENT22		'h336
`define CsrMHPMEVENT23		'h337
`define CsrMHPMEVENT24		'h338
`define CsrMHPMEVENT25		'h339
`define CsrMHPMEVENT26		'h33a
`define CsrMHPMEVENT27		'h33b
`define CsrMHPMEVENT28		'h33c
`define CsrMHPMEVENT29		'h33d
`define CsrMHPMEVENT30		'h33e
`define CsrMHPMEVENT31		'h33f

//*** Debug/Trace Register
//* Debug/Trace trigger register select
`define CsrTSELECT			'h7a0
//* Debug/Trace trigger data register
`define CsrTDATA1			'h7a1
`define CsrTDATA2			'h7a2
`define CsrTDATA3			'h7a3

//*** Debug Mode Register
`define CsrDCSR				'h7b0
`define CsrDPC				'h7b1
`define CsrDSCRATCH			'h7b2



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
