/*
* <br_pred_gshare.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"

module br_pred_gshare #(
	parameter ADDR = `AddrWidth,
	parameter CNT = `PredCntWidth,
	parameter DEPTH = `PredTableDepth,
	parameter PRED_MAX = `PredMaxDepth
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire [ADDR-1:0]	br_pc,
	output wire				br_pred,

	input wire [ADDR-1:0]	commit_pc,
	input wire				br_commit_,
	input wire				br_result,		// taken/not takne
	input wire				br_pred_miss_
);

endmodule
