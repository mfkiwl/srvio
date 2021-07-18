/*
* <pseudo_cpu.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module pseudo_cpu #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter INST = `InstWidth,
	parameter PRED_MAX = `PredMaxDepth,
	parameter BP_DEPTH = `PredTableDepth,
	parameter BTB_DEPTH = `BtbDepth,
	parameter RA_DEPTH = `RaStackDepth,
	parameter ROB_DEPTH = `RobDepth
)(
	input wire				clk,
	input wire				reset_,

	ICacheFetchIf.fetch		ic_fetch_if
);

	//***** interfaces
	ICacheFetchIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) ic_fetch_if ();

	FetchDecIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) fetch_dec_if();

	DecIsIf #(
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH )
	) dec_is_if();

	IsExeIf #(
		.DATA		( DATA )
	) is_exe_if();

	ExeDCacheIf #(
		.ADDR		( ADDR ),
		.DATA		( DATA )
	) exe_dc_if();



	//***** fetch stage 
	fetch_top #(
		.PRED_MAX		( PRED_MAX ),
		.BP_DEPTH		( BP_DEPTH ),
		.PREDICTOR		( PREDICTOR ),
		.BTB_DEPTH		( BTB_DEPTH ),
		.RA_DEPTH		( RA_DEPTH ),
		.ROB_DEPTH		( ROB_DEPTH )
	) fetch_top (
		.clk			( clk ),
		.reset_			( reset_ ),
		.ic_fetch_if	( ic_fetch_if ),
		.fetch_dec_if	( fetch_dec_if ),
		.pc_inst_if		( pc_inst_if )
	);



	//***** decode stage
	decode_top #(
		.ADDR			( ADDR ),
		.DATA			( DATA ),
		.INST			( INST )
	) decode_top (
		.clk			( clk ),
		.reset_			( reset_ ),

		.fetch_dec_if	( fetch_dec_if ),
		.dec_is_if		( dec_is_if ) 
	);



	//***** instruction issue
	issue_top #(
		.ADDR			( ADDR ),
		.DATA			( DATA ),
		.IQ_DEPTH		( IQ_DEPTH ),
		.ROB_DEPTH		( ROB_DEPTH )
	) issue_top (
		.clk			( clk ),
		.reset_			( reset_ ),

		.dec_is_if		( dec_is_if ),
		.is_exe_if		( is_exe_if ),
		.pc_inst_if		( pc_inst_if )
	);



	//***** execution units
	exe_top #(
		.ADDR			( ADDR ),
		.DATA			( DATA )
	) exe_top (
		.clk			( clk ),
		.reset_			( reset_ ),

		.is_exe_if		( is_exe_if ),
		.pc_inst_if		( pc_inst_if )
	);



	//***** test model for caches
	pseudo_ic #(
	) pseudo_ic (
		.clk			( clk ),
		.reset_			( reset_ ),

		.ic_fetch_if	( ic_fetch_if )
	);

	pseudo_dc #(
	) pseudo_dc (
		.clk			( clk ),
		.reset_			( reset_ ),

		.exe_dc_if		( exe_dc_if )
	);

endmodule
