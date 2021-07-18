/*
* <csr.sv>
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
`include "csr.svh"

module csr #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_,
);

endmodule
