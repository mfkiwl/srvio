/*
* <issue_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module issue_top #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth,
	parameter SB_DEPTH = `SBDepth,
	parameter ROB_DEPTH = `RobDepth
)(
	input wire				clk,
	input wire				reset_,

	DecIsIf.inst_sched		dec_is_if
);

	//***** internal parameters
	localparam ROB = $clog2(ROB_DEPTH);



	//***** instruction scheduler
	inst_sched #(
	) inst_sched (
	);



	//***** Reorder buffer
	reorder_buffer #(
		.DATA		( DATA ),
		.ADDR		( ADDR ),
		.ROB_DEPTH	( ROB_DEPTH ),
		.ROB		( ROB )
	) reorder_buffer (
		.clk		( clk ),
		.reset_		( reset_ )
	);



	//***** operand select
	operand_mux #(
	) operand_mux (
	);



	//***** register files
	cpu_regfiles #(
		.DATA		( DATA ),
	) cpu_regfiles (
	);

endmodule
