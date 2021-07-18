/*
* <br_status_buf.sv>
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
module br_status_buf #(
	parameter DATA = 64,
	parameter DEPTH = `PredMaxDepth,
	// constant
	parameter ADDR = $clog2(DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				we_,		// write enable
	input wire [DATA-1:0]	wd,			// write data

	input wire				re_,		// read enable
	output wire [DATA-1:0]	rd,			// read data

	input wire [ADDR-1:0]	exe_st_idx,
	output wire [DATA-1:0]	exe_status,
	input wire [ADDR-1:0]	wb_st_idx,
	input wire				wb_flush_,
	output wire [DATA-1:0]	wb_status,

	output wire				busy		// some entry may no be accepted
);

	//***** internal parameters
	localparam RNUM = 1;
	localparam WNUM = 1;

	//***** registers
	reg [DEPTH-1:0][DATA-1:0]	data;
	reg [ADDR-1:0]				head;
	reg [ADDR-1:0]				tail;
	reg [DEPTH-1:0]				valid;

	//***** wires
	wire						wb_tail_inverted;
	wire [ADDR-1:0]				wr_addr;
	wire [ADDR-1:0]				rd_addr;
	wire [ADDR-1:0]				check_ptr;
	wire [RNUM-1:0]				rnum;
	wire [WNUM-1:0]				wnum;
	wire [$clog2(DEPTH)-1:0]	depth;

	//***** combinational cells
	logic [ADDR-1:0]			next_head;
	logic [ADDR-1:0]			next_tail;
	logic [DEPTH-1:0]			next_valid;
	logic [DEPTH-1:0]			wr_match;
	logic [DEPTH-1:0]			rd_match;
	logic [DEPTH-1:0]			invalidate;
	logic [DEPTH-1:0]			invalidate_ordered;
	logic [DEPTH-1:0]			invalidate_inverted;



	//***** assign output
	assign busy = valid[check_ptr];
	assign check_ptr = next_head;	// TODO: check if this is OK 
									//	in term of critical path.
	//assign check_ptr = head;
	assign exe_status = data[exe_st_idx];
	assign wb_status = data[wb_st_idx];



	//***** assign internal
	assign depth = DEPTH;
	assign wr_addr = head;
	assign rd_addr = tail;
	assign rd = data[rd_addr];
	assign wb_tail_inverted = wb_st_idx < tail;

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
		//*** invalidate entry after miss predicted branch
		for ( ci = 0; ci < DEPTH; ci = ci + 1 ) begin
			invalidate_ordered[ci] =
				( ( ci < tail ) || ( ci > wb_st_idx ) );
			invalidate_inverted[ci] =
				( ( ci < tail ) && ( ci > wb_st_idx ) );

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
				( wb_st_idx + 1 < depth )
					? wb_st_idx + 1
					: wb_st_idx + 1 - depth;
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
	integer i;
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			head <= {ADDR{1'b0}};
			tail <= {ADDR{1'b0}};
			valid <= {DEPTH{`Disable}};
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				data[i] <= {DATA{1'b0}};
			end
		end else begin
			head <= next_head;
			tail <= next_tail;
			valid <= next_valid;
			if ( we_ == `Enable_ ) begin
				data[wr_addr] <= wd;
				//valid[wr_addr] <= `Enable;
			end
			if ( re_ == `Enable_ ) begin
				data[rd_addr] <= {DATA{1'b0}};
				//valid[rd_addr] <= `Disable;
			end
		end
	end

endmodule
