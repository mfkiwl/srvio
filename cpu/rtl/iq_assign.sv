/*
* <iq_assign.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "issue.svh"

module iq_assign #(
	parameter SB_DEPTH = `SbDepth,
	// constant
	parameter SB = $clog2(SB_DEPTH)
)(
	input wire			clk,
	input wire			reset_,
);

	reg [

endmodule
