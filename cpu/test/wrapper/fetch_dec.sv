/*
* <fetch_dec.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module fetch_dec #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter INST = `InstWidth,
	parameter L1_CACHE = `L1_ICacheSize,
	parameter PRED_MAX = `PredMaxDepth,
	parameter BP_DEPTH = `PredTableDepth,
	parameter BrPredType_t PREDICTOR = `PredType,
	parameter BTB_DEPTH = `BtbDepth,
	parameter RA_DEPTH = `RaStackDepth,
	parameter ROB_DEPTH = `RobDepth
)(
	input wire				clk,
	input wire				reset_,

	PcInstIf				pc_inst_if,
	DecIsIf					dec_is_if
);

	//***** internal interfaces
	ICacheFetchIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) ic_fetch_if();

	FetchDecIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_dec_if();



	//***** modules
	inst_rom #(
		.L1_CACHE		( L1_CACHE ),
		.INST			( INST )
	) inst_rom (
		.clk			( clk ),
		.reset_			( reset_ ),

		.ic_fetch_if	( ic_fetch_if )
	);

	fetch_top #(
		.ADDR			( ADDR ),
		.INST			( INST ),
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

endmodule
