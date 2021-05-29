/*
* <exp_manage_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exception.svh"
`include "csr.svh"

module exp_manage_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter DATA = `DataWidth;

	reg				commit_exp_;
	ExpCode_t		commit_exp_code;
	reg				creg_exp_mask;
	reg [DATA-1:0]	creg_tvec;
	wire [ADDR-1:0]	exp_handler_pc;

	exp_manage #(
		.ADDR	( ADDR ),
		.DATA	( DATA )
	) exp_manage (
		.*
	);

`ifndef VERILATOR
	initial begin
		// direct
		commit_exp_ = `Disable_;
		commit_exp_code = EXP_BREAK;
		creg_exp_mask = `Disable;
		creg_tvec = {30'hcafe<<2,2'b00};
		#(STEP);

		// vector
		creg_tvec[1:0] = 2'b01;

		#(STEP);

		$finish;
	end
`endif

	`include "waves.vh"

endmodule
