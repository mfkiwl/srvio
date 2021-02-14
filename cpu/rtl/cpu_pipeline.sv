/*
* <cpu_pipeline.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"

module cpu_pipeline #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter INST = `InstWidth
)(
	input wire				clk,
	input wire				reset_
);

	//***** interfaces
	ICacheFetchIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) ic_fetch_if();

	FetchDecIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) fetch_dec_if();

	DecIsIf #(
		.ADDR		( ADDR ),
		.INST		( INST )
	) dec_is_if();



	//***** fetch stage 
	fetch_top #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_top (
		.clk			( clk ),
		.reset_			( reset_ ),
		.ic_fetch_if	( ic_fetch_if ),
		.fetch_dec_if	( fetch_dec_if )
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



	//***** instruction scheduler
	inst_sched #(
		.ADDR			( ADDR ),
		.DATA			( DATA )
	) inst_sched (
	);



	//***** execution units
	exe_top #(
		.ADDR			( ADDR ),
		.DATA			( DATA )
	) exe_top (
	);



endmodule
