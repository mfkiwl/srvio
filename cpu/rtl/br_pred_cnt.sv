/*
* <br_pred_cnt.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.h"

module br_pred_cnt #(
	parameter ADDR = `AddrWidth,
	parameter CNTW = `PredCntWidth,
	parameter PRED_D = `PredMaxDepth,
	parameter PRT_D = `PredTableDepth,
	parameter SIMBRF = `SimBrFetch,
	parameter SIMBRCOM = `SimBrCommit,
	parameter OUTREG = `Enable
)(
	input wire						clk,
	input wire						reset_,
	input wire						flush_,

	/***** prediction *****/
	input wire [SIMBRF-1:0]			br_,
	input wire [SIMBRF*ADDR-1:0]	br_addr,
	output wire [SIMBRF-1:0]		pred_taken,

	/***** feedback and train *****/
	input wire [SIMBRCOM-1:0]		br_commit_,
	input wire [SIMBRCOM-1:0]		br_taken_,
	input wire [SIMBRCOM-1:0]		br_pred_miss_

	/***** status *****/
	//,output wire						busy
);

	/***** internal parameter *****/
	localparam TBL_IDX = $clog2(PRT_D);			// table index
	localparam HISTORY = TBL_IDX + 1;			// prediction history
	localparam CNT_MAX = {CNTW{1'b1}};
	localparam CNT_MIN = {CNTW{1'b0}};
	localparam CNT_DEF = ( CNT_MAX / 2 ) + 1;	// weakly taken
	localparam INCR = $clog2(SIMBRCOM) + 1;		// increment value of counter
	localparam BYTE = `ByteBitWidth;			// just an alias...
	localparam ADDR_OFS = $clog2(`InstWidth/BYTE); // # of lower bits ignored
	/***** registers *****/
	reg [CNTW-1:0]				cnt [PRT_D-1:0];
	reg	[SIMBRF-1:0]			reg_pred;
	/***** wires *****/
	/* prediction */
	wire [HISTORY*SIMBRF-1:0]	wr_hist;				// write history
	wire [TBL_IDX-1:0]			pred_idx [SIMBRF-1:0];	// idx for prediction
	wire [SIMBRF-1:0]			pred_taken_wire;		// Prediction result
	/* train */
	wire [HISTORY*SIMBRCOM-1:0]	rd_hist;				// read history
	wire [TBL_IDX-1:0]			tr_idx [SIMBRCOM-1:0];	// idx for train
	wire [SIMBRCOM-1:0]			tr_pred_taken;			// prediction for train
	wire [TBL_IDX*SIMBRCOM-1:0]	tr_idx_conc;			// concatenated
	wire [SIMBRCOM-1:0]			taken;					// result is taken


	/***** output *****/
	//assign pred_taken = OUTREG ? reg_pred : pred_taken_wire;
	generate
		if ( OUTREG ) begin : outreg
			assign pred_taken = reg_pred;
		end else begin : no_outreg
			assign pred_taken = pred_taken_wire;
		end
	endgenerate


	/***** generate index for prediciton *****/
	generate
		genvar gp;
		for ( gp = 0; gp < SIMBRF; gp = gp + 1 ) begin : Loop_idx
			wire [ADDR-1:0]		addr_each;
			wire [TBL_IDX-1:0]	idx_each;
			wire [CNTW-1:0]		cnt_each;
			// address to index
			assign addr_each = br_addr[`RangeG(gp,ADDR)];
			assign idx_each = addr_each[TBL_IDX+ADDR_OFS-1:ADDR_OFS];
			assign cnt_each = cnt[idx_each];

			// output
			assign pred_idx[gp] = idx_each;
			assign pred_taken_wire[gp] = cnt_each[CNTW-1];
		end
	endgenerate


	/***** read/write prediction history for train *****/
	/* warning: saved prediction in pred_history is not actually used. 
				It still remains in this code just in case.  */
	generate
		genvar gi, gj;
		/* on prediction */
		for ( gi = 0; gi < SIMBRF; gi = gi + 1 ) begin : Loop_pred
			wire				pred_each;
			wire [TBL_IDX-1:0]	idx_each;
			assign pred_each = pred_taken_wire[gi];
			assign idx_each = pred_idx[gi];
			assign wr_hist[`RangeG(gi,HISTORY)] = {pred_each, idx_each};
		end

		/* on training */
		for ( gj = 0; gj < SIMBRCOM; gj = gj + 1 ) begin : Loop_Tr
			wire				pred_each;
			wire [TBL_IDX-1:0]	idx_each;
			assign tr_idx[gj] = idx_each;
			assign tr_pred_taken[gj] = pred_each;
			assign tr_idx_conc[`RangeG(gj,TBL_IDX)] = idx_each;
			assign {pred_each, idx_each} = rd_hist[`RangeG(gj,HISTORY)];
		end
	endgenerate

	/* history buffer */
	wire [SIMBRCOM-1:0]	dummy_v;
	wire				dummy_busy;
	fifo #(
		.DATA		( HISTORY ),
		.DEPTH		( PRED_D ),
		.BUF_EXT	( `Disable ),
		.READ		( SIMBRCOM ),
		.WRITE		( SIMBRF ),
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
		//.busy		( busy )
	);


	/***** update prediction counter *****/
	//assign taken = tr_pred_taken ^ ~br_pred_miss_;
	function [CNTW-1:0] update_cnt;
		input [TBL_IDX-1:0]				idx;
		input [CNTW-1:0]				current;
		input [SIMBRCOM-1:0]			br_;
		input [SIMBRCOM-1:0]			taken_;
		input [SIMBRCOM*TBL_IDX-1:0]	tr_idx;
		reg [CNTW-1:0]					cnt;
		integer i;
		begin
			cnt = current;
			for ( i = 0; i < SIMBRCOM; i = i + 1 ) begin
				if ( ( idx == tr_idx[`RangeF(i,TBL_IDX)] ) && !br_[i] ) begin
					if ( taken_[i] == `Enable_ ) begin
						//cnt = ( cnt == CNT_MAX ) ? CNT_MAX : cnt + 1'b1;
						cnt = `CntUp(cnt,CNT_MAX,1'b1);
					end else begin
						//cnt = ( cnt == CNT_MIN ) ? CNT_MIN : cnt - 1'b1;
						cnt = `CntDwn(cnt,CNT_MIN,1'b1);
					end
				end
			end
			update_cnt = cnt;
		end
	endfunction


	/***** Sequential logics *****/
	integer i;
	always @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			reg_pred <= {SIMBRF{`Disable_}};
			for ( i = 0; i < PRT_D; i = i + 1 ) begin
				cnt[i] <= CNT_DEF;
			end
		end else begin
			reg_pred <= pred_taken_wire;
			for ( i = 0; i < PRT_D; i = i + 1 ) begin
				cnt[i] <= update_cnt(i, cnt[i], 
							br_commit_, br_taken_, tr_idx_conc);
			end
		end
	end

endmodule
