/*
* <decode_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "decode.svh"

module decode_top #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter INST = `InstWidth
)(
	input wire				clk,
	input wire				reset_,

	FetchDecIf.decode		fetch_dec_if
);

	//***** Simple RISC-V Decoder
	decoder #(
		.ADDR		( ADDR ),
		.DATA		( DATA ),
		.INST		( INST )
	) decoder (
		.clk		( clk ),
		.reset_		( reset_ ),
	);

	//***** TODO: Add Complex Macro Decoder

endmodule
