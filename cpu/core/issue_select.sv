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

	//***** internal wires
	wire							no_rs_ready;
	wire							no_half_rs_ready;

	//***** combinatioanl cells
	logic [IQ_DEPTH-1:0]			rs1_ready_;
	logic [IQ_DEPTH-1:0]			rs2_ready_;
	logic [IQ_DEPTH-1:0]			rs1_may_ready_;	// maybe ready in next cycle
	logic [IQ_DEPTH-1:0]			rs2_may_ready_;
	logic [IQ_DEPTH-1:0]			rs_ready_;		// both operands are ready
	logic [IQ_DEPTH-1:0]			half_rs_ready_;	// half operands are ready
	logic [IQ_DEPTH-1:0]			rs_may_ready_;	// half operands maybe 
													//		ready in next cycle
	logic [IQ_DEPTH-1:0]			ready_;



	//***** assign output
	assign issue_ready_ = ready_;



	//***** assign internal
	assign no_rs_ready = &rs_ready_;
	assign no_half_rs_ready = &half_rs_ready_;
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
		//*** check operand
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			rs1_ready_[ci] = !( rs1_stat[ci] == REG_READY );
			rs2_ready_[ci] = !( rs2_stat[ci] == REG_READY );
			rs1_may_ready_[ci] = rs1_stat[ci][`RegStatReady_];
			rs2_may_ready_[ci] = rs2_stat[ci][`RegStatReady_];
			rs_ready_[ci] = rs1_ready_[ci] || rs2_ready_[ci];
			half_rs_ready_[ci] =
				( rs1_ready_[ci] || rs2_may_ready_[ci] ) &&
				( rs1_may_ready_[ci] || rs1_ready_[ci] );
			rs_may_ready_[ci] = rs1_may_ready_[ci] || rs2_may_ready_[ci];
		end

		//*** select ready instructions
		//	Scheduling priority is A > B > C.
		//	A. Insts. with both operands of any instructions are ready
		//	B. Insts. with either operands of any instructions are ready,
		//		and the other may be ready in a few clock cycles
		//	C. Insts. with both operands may be ready in a few clock cycles
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			case ( {no_half_rs_ready, no_rs_ready} )
				{`Disable, `Disable} : begin
					ready_[ci] =
						inst_busy[ci] || !valid[ci] || rs_may_ready_[ci];
				end
				{`Enable, `Disable} : begin
					ready_[ci] =
						inst_busy[ci] || !valid[ci] || half_rs_ready_[ci];
				end
				default : begin
					ready_[ci] =
						inst_busy[ci] || !valid[ci] || rs_ready_[ci];
				end
			endcase
		end
	end

endmodule
