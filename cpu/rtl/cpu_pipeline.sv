/*
* <cpu_pipeline.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.vh"
`include "fetch.svh"

module cpu_pipeline #(
)(
	input wire				clk,
	input wire				reset_,

);

	fetch_top #(
	) fetch_top (
		.clk			( clk ),
		.reset_			( reset_ ),
	);

	decode_top #(
	) decode_top (
		.clk			( clk ),
		.reset_			( reset_ ),
	);

endmodule
