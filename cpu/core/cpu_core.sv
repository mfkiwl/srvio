/*
* <cpu_core.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module cpu_core #(
)(
	input wire			clk,
	input wire			reset_
);

	//***** interfaces
	ICacheFetchIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) ic_fetch_if();

	cpu_pipeline #(
	) cpu_pipeline (
		.clk			( clk ),
		.reset_			( reset_ ),
		.ic_fetch_if	(
	);

endmodule
