/*
* <issue_select.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "issue.svh"

module issue_select #(
	parameter IQ_DEPTH = `IqDepth
)(
	input wire [IQ_DEPTH-1:0]		inst_busy,
	input RegStat_t [IQ_DEPTH-1:0]	rs1_stat,
	input RegStat_t [IQ_DEPTH-1:0]	rs2_stat,
	input wire [IQ_DEPTH-1:0]		valid,
	output wire [IQ_DEPTH-1:0]		issue_ready_
);

	//***** combinatioanl cells
	logic [IQ_DEPTH-1:0]			ready_;



	//***** assign output
	assign issue_ready_ = ready_;



	//***** assign internal
`ifdef DEBUG
	wire [IQ_DEPTH-1:0]			issue_vec_;
	wire						valid_;
	wire [$clog2(IQ_DEPTH)-1:0]	issue_pos;
	wire						dummy_out;

	selector #(
		.BIT_MAP	( `Enable ), 
		.DATA		( 1 ),
		.IN			( IQ_DEPTH ),
		.ACT		( `Low ),
		.MSB		( `Disable )
	) sel (
		.in			( {IQ_DEPTH{1'b0}} ),
		.sel		( ready_ ),
		.valid		( valid_ ),
		.pos		( issue_vec_ ),
		.out		( dummy_out )
	);
`endif


	//***** combinational logics
	int ci;
	always_comb begin
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			ready_[ci] =
				inst_busy[ci] || 
				!valid[ci] ||
				rs1_stat[ci][`RegStatReady_] ||
				rs2_stat[ci][`RegStatReady_];
		end
	end

endmodule
