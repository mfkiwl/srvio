/*
* <fpu_ctrl.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "decode.svh"
`include "exe.svh"

module fpu_ctrl #(
	parameter DATA = `DataWidth
)(
	input wire					clk,
	input wire					reset_,

	input wire					flush_,

	input wire					issue_e_,
	input RegFile_t				rd,

	input wire					exp_,
	input ExpCode_t				exp_code,
	input wire [DATA-1:0]		fpu_res,

	input wire					wb_ack_,
	output wire					wb_req_,
	output RegFile_t			pre_wb_rd,

	output wire					wb_e_,
	output RegFile_t			wb_rd,
	output wire [DATA-1:0]		wb_data,
	output wire					wb_exp_,
	output ExpCode_t			wb_exp_code,

	output wire					busy
);

endmodule
