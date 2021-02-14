/*
* <rename_map.sv>
* 
* Copyright (c) 2021 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module rename_map #(
	parameter DATA = $bits(RegFile_t),
	parameter DEPTH = `RobDepth,
	parameter WRITE = 2,
	parameter READ = 2,
	// constant
	parameter ADDR = $clog2(DEPTH)
)(
	input  wire							clk,
	input  wire							reset_,

	// write ports
	input  wire [WRITE-1:0]				we_,	// write enable
	input  wire [WRITE-1:0]				wv,		//       valid
	input  wire [WRITE-1:0][DATA-1:0]	wd,		//       data
	input  wire [WRITE-1:0][ADDR-1:0]	waddr,	//       addr

	// invalidate
	input  wire							flush_,
	input  wire							inve_,
	input  wire [ADDR-1:0]				invaddr,

	// read ports
	input  wire [READ-1:0]				re_,	// read enable
	input  wire [READ-1:0][DATA-1:0]	rd,		//      data
	output wire [READ-1:0]				match,	// matched
	output wire [READ-1:0][ADDR-1:0]	raddr	// matched address
);

	//***** internal registers
	reg [DATA-1:0]					cam_cell [DEPTH-1:0];

	//***** internal wires
	wire [WRITE-1:0]				we;
	wire [READ-1:0]					re;
	wire [DATA-1:0]					next_cam_cell [DEPTH-1:0];



	//***** assign internal
	assign we = ~we_;
	assign re = ~re_;



	//***** entry update
	generate
		genvar gi, gj, gk;
		for ( gi = 0; gi < DEPTH; gi = gi + 1 ) begin : LP_ent
			wire [WRITE-1:0]	wmatch;				// address match
			wire [DATA-1:0]		cell_each;			// current cell
			wor				 	invalidate;			// invalidate entry
			wor [DATA-1:0]		next_cell_each;		// next cell data ( wired-or )

			//*** this entry
			assign cell_each = cam_cell[gi];
			assign invalidate = !inve_ && (gi == invaddr);


			//*** update
			for ( gj = 0; gj < WRITE; gj = gj + 1 ) begin : LP_cell
				//* separate
				wire [DATA-1:0]					wr_each;
				wire [DATA-1:0]					wr_each_;
				wire [DATA-1:0]					inv_each;
				wire [DATA-1:0]					inv_each_;

				//* Address check
				assign wmatch[gj] = we[gj] && (waddr[gj] == gi) && wv[gj];
				assign invalidate =
					( ( wd[gj] == cell_each ) && we[gj] ) || !flush_;

				//* data select
				assign wr_each = {DATA{wmatch[gj]}};
				assign wr_each_ = {DATA{!wmatch[gj]}};
				assign inv_each = {DATA{invalidate}};
				assign inv_each_ = {DATA{!invalidate}};
				assign next_cell_each
					= ( wr_each & wd[gj] )
						| ( cell_each & wr_each_ & inv_each_ );
			end

			//*** concat
			assign next_cam_cell[gi] = next_cell_each;
		end
	endgenerate



	//***** read logic
	generate
		genvar gr, gs;
		for ( gr = 0; gr < READ; gr = gr + 1 ) begin : LP_rd
			wire [DEPTH-1:0]		rmatch;
			wor [ADDR-1:0]			raddr_each;		// read address

			//*** read address check
			for ( gs = 0; gs < DEPTH; gs = gs + 1 ) begin : LP_ent
				wire [DATA-1:0]		cell_each;
				wire [DATA-1:0]		cmp;
				wire				rdct_cmp;
				assign cell_each = cam_cell[gs];

				assign cmp = ~(cam_cell[gs] ^ rd[gr]);
				assign rdct_cmp = &cmp;
				assign rmatch[gs] = re[gr] && rdct_cmp;
			end


			//*** read data select
			for ( gs = 0; gs < DEPTH; gs = gs + 1 ) begin : LP_sel
				wire [ADDR-1:0]		idx;
				assign idx = gs;
				assign raddr_each = {DATA{rmatch[gs]}} & idx;
			end


			//*** concat
			assign match[gr] = |rmatch;
			assign raddr[gr] = raddr_each;
		end
	endgenerate



	//***** sequential logics
	int i;
	always @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				cam_cell[i] <= {DATA{1'b0}};
			end
		end else begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				cam_cell[i] <= next_cam_cell[i]; 
			end
		end
	end

endmodule 
