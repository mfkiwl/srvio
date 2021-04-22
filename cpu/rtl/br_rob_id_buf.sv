/*
* <br_rob_id_buf.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"

// based on ring_buf.sv
module br_rob_id_buf #(
	parameter ROB_DEPTH = `RobDepth,
	parameter DEPTH = 16,
	// constant
	parameter ADDR = $clog2(DEPTH),
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				we_,		// write enable
	input wire [ROB-1:0]	wd,			// write data
	input wire				re_,		// read enable
	output wire [ADDR-1:0]	ridx,		// read index

	input wire [ROB-1:0]	exe_rob_id,
	input wire [ROB-1:0]	wb_rob_id,
	input wire				wb_flush_,
	output logic [ADDR-1:0]	exe_idx,
	output wire				wb_match_,
	output logic [ADDR-1:0]	wb_idx
);

	//***** internal parameters
	localparam RNUM = 1;
	localparam WNUM = 1;

	//***** internal registers
	reg [DEPTH-1:0][ROB-1:0]	data;
	reg [ADDR-1:0]				head;
	reg [ADDR-1:0]				tail;
	reg [DEPTH-1:0]				valid;

	//***** internal wires
	wire						wb_tail_inverted;
	wire [ADDR-1:0]				wr_addr;
	wire [ADDR-1:0]				rd_addr;
	wire [ADDR-1:0]				check_ptr;
	wire [RNUM-1:0]				rnum;
	wire [WNUM-1:0]				wnum;
	wire [$clog2(DEPTH)-1:0]	depth;
	wire						wb_match;

	//***** combinational cells
	logic [ADDR-1:0]			next_head;
	logic [ADDR-1:0]			next_tail;
	logic [DEPTH-1:0]			exe_rob_match;
	logic [DEPTH-1:0]			wb_rob_match;
	logic [DEPTH-1:0]			next_valid;
	logic [DEPTH-1:0]			invalidate;
	logic [DEPTH-1:0]			invalidate_ordered;
	logic [DEPTH-1:0]			invalidate_inverted;
	logic [DEPTH-1:0]			wr_match;
	logic [DEPTH-1:0]			rd_match;



	//***** assign output
	assign check_ptr = head;
	assign ridx = rd_addr;
	assign wb_match_ = !wb_match;

	pri_enc #(
		.IN		( DEPTH ),
		.ACT	( `High )
	) pri_enc_exe (
		.in		( exe_rob_match ),
		.valid	(),
		.out	( exe_idx )
	);

	pri_enc #(
		.IN		( DEPTH ),
		.ACT	( `High )
	) pri_enc_wb (
		.in		( wb_rob_match ),
		.valid	( wb_match ),
		.out	( wb_idx )
	);



	//***** assign internal
	assign depth = DEPTH;
	assign wr_addr = head;
	assign rd_addr = tail;
	assign rd = data[rd_addr];
	assign wb_tail_inverted = wb_idx < tail;

	cnt_bits #(
		.IN			( 1 ),
		.ACT		( `Low )
	) cnt_read (
		.in			( re_ ),
		.out		( rnum )
	);

	cnt_bits #(
		.IN			( 1 ),
		.ACT		( `Low )
	) cnt_write (
		.in			( we_ ),
		.out		( wnum )
	);



	//***** combinational logics
	int ci;
	always_comb begin
		for ( ci = 0; ci < DEPTH; ci = ci + 1 ) begin
			exe_rob_match[ci] = valid[ci] && ( data[ci] == exe_rob_id );
			wb_rob_match[ci] = valid[ci] && ( data[ci] == wb_rob_id );
		end

		//*** invalidate entry after miss predicted branch
		for ( ci = 0; ci < DEPTH; ci = ci + 1 ) begin
			invalidate_ordered[ci] =
				( ( ci < tail ) || ( ci > wb_idx ) );
			invalidate_inverted[ci] =
				( ( ci < tail ) && ( ci > wb_idx ) );

			case ({wb_flush_, wb_tail_inverted})
				{`Enable_, `Disable} : begin
					invalidate = invalidate_ordered;
				end
				{`Enable_, `Enable} : begin
					invalidate = invalidate_inverted;
				end
				default : begin
					invalidate = {DEPTH{`Disable}};
				end
			endcase
		end

		//*** update
		for ( ci = 0; ci < DEPTH; ci = ci + 1 ) begin
			wr_match[ci] = ( wr_addr == ci ) && !we_;
			rd_match[ci] = ( rd_addr == ci ) && !re_;
			casex ( { invalidate[ci], wr_match[ci], rd_match[ci] } )
				{`Enable, 1'bx, 1'bx} : next_valid[ci] = `Disable;
				{`Disable, `Enable, `Disable} : next_valid[ci] = `Enable;
				{`Disable, `Disable, `Enable} : next_valid[ci] = `Disable;
				default : next_valid[ci] = valid[ci];
			endcase
		end

		//*** pointer
		if ( !wb_flush_ ) begin
			next_head =
				( wb_idx + 1 < depth )
					? wb_idx + 1
					: wb_idx + 1 - depth;
		end else begin
			next_head = 
				( head + wnum < depth ) 
					? head + wnum
					: head + wnum - depth;
		end

		next_tail = 
			( tail + rnum < depth )
				? tail + rnum
				: tail + rnum - depth;
	end



	//***** sequential logics
	int i;
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			head <= {ADDR{1'b0}};
			tail <= {ADDR{1'b0}};
			valid <= {DEPTH{`Disable}};
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				data[i] <= {ROB{1'b0}};
			end
		end else begin
			head <= next_head;
			tail <= next_tail;
			valid <= next_valid;
			if ( we_ == `Enable_ ) begin
				data[wr_addr] <= wd;
			end
			if ( re_ == `Enable_) begin
				data[rd_addr] <= {ROB{1'b0}};
			end
		end
	end

endmodule
