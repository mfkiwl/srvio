/*
* <br_pred_cnt.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "branch.svh"

module br_pred_cnt #(
	parameter ADDR = `AddrWidth,
	parameter CNT = `PredCntWidth,
	parameter DEPTH = `PredTableDepth,
	parameter PRED_MAX = `PredMaxDepth
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				br_,
	input wire [ADDR-1:0]	br_pc,
	output wire				br_pred,

	input wire				br_commit_,
	input wire				br_result,
	input wire				br_pred_miss_
);

	//***** internal parameters
	localparam PTR = $clog2(DEPTH);
	localparam HISTROY = PTR + 1;			// prediction + index
	localparam CNT_MAX = {CNTW{1'b1}};
	localparam CNT_MIN = {CNTW{1'b0}};
	localparam CNT_DEF = ( CNT_MAX / 2 );	// weakly taken
	localparam BYTE = `ByteBitWidth;
	localparam ADDR_OFS = $clog2(`InstWidth/BYTE);

	//***** internal registers
	reg [CNT-1:0]			cnt [DEPTH-1:0];

	//***** internal wires
	//*** prediction
	wire [PTR-1:0]			pred_ptr;
	wire [CNT-1:0]			pred_cnt;
	wire [HISTORY-1:0]		wr_hist;
	//*** update
	wire					tr_pred;
	wire [PTR-1:0]			tr_ptr;
	wire [HISTORY-1:0]		rd_hist;

	//***** combinational cells
	logic [CNT-1:0]			next_cnt [DEPTH-1:0];



	//***** assign output
	assign br_pred = pred_cnt[CNT-1];



	//***** assign interanl 
	assign pred_ptr = br_pc[PTR+ADDR_OFS-1:ADDR_OFS];
	assign pred_cnt = cnt[pred_ptr];
	assign wr_hist = {br_pred, pred_ptr};
	assign {tr_pred, tr_ptr} = rd_hist;



	//***** History buffer
	wire				dummy_v;
	wire				dummy_busy;
	fifo #(
		.DATA		( HISTORY ),
		.DEPTH		( DEPTH ),
		.BUF_EXT	( `Disable ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ACT		( `Low )
	) pred_history (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ), 
		.we			( br_ ),
		.wd			( wr_hist ),
		.re			( br_commit_ ),
		.rd			( rd_hist ),
		.v			( dummy_v ),
		.busy		( dummy_busy )
	);



	//***** combinational logics
	int ci;
	always_comb begin
		for ( ci = 0; ci < DEPTH; ci = ci + 1 ) begin
			if ( !br_commit_ && ( ci == tr_ptr ) ) begin
				if ( br_result == `BrTaken ) begin
					// branch taken
					next_cnt =
						( cnt[ci] == CNT_MIN ) ? CNT_MIN : cnt[ci] - 1'b1;
				end else begin
					// branch not taken
					next_cnt =
						( cnt[ci] == CNT_MAX ) ? CNT_MAX : cnt[ci] + 1'b1;
				end
			end else begin
				next_cnt[ci] = cnt[ci];
			end
		end
	end



	//***** sequential Logics
	int i;
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				cnt[i] <= CNT_DEF;
			end
		end else begin
			for ( i = 0; i < DEPTH; i = i + 1 ) begin
				cnt[i] <= next_cnt[i];
			end
		end
	end

endmodule
