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
`include "decode.svh"

module decode_top #(
)(
	input wire				clk,
	input wire				reset_,

	output Decode_t			dec_out
);

	decoder #(
	) decoder (
	);

endmodule
