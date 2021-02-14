/*
* <cpu_regfiles.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exception.svh"

module cpu_regfiles #(
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_
);

	regfile #(
		.DATA		( DATA ),
		.ADDR		( `GprAddrWidth ),
		.READ		( 2 ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Enable )
	) gpr (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		(),
		.waddr		(),
		.we_		(),
		.wdata		(),
		.rdata		()
	);

	regfile #(
		.READ		( 2 ),
		.ADDR		( `FprAddrWidth ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Disable )
	) fpr (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		(),
		.waddr		(),
		.we_		(),
		.wdata		(),
		.rdata		()
	);

	csr #(
	) csr (
	);

endmodule
