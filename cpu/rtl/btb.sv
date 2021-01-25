/*
* <btb.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.vh"

module btb #(
	parameter ADDR = `AddrWidth,
	parameter INST = `InstWidth,
	parameter BTB_D = `BtbTableDepth,
	parameter FETCH = 1,
	parameter SIMBRCOM = 1,
	parameter CNT = `BtbCntWidth
)(
	input wire						clk,
	input wire						reset_,

	/* prediction */
	input wire [FETCH*ADDR-1:0]		btb_addr,
	output wire [FETCH-1:0]			target_valid,	// target is valid
	output wire [FETCH*ADDR-1:0]	target_addr,	// target address

	/* train */
	input wire [SIMBRCOM-1:0]		target_miss_,	// indirect jump target miss
	input wire [SIMBRCOM-1:0]		pc_chg_com_,	// br/jump commit
	input wire [SIMBRCOM-1:0]		chg_taken_,		// taken
	input wire [SIMBRCOM*ADDR-1:0]	com_addr,		// commit pc
	input wire [SIMBRCOM*ADDR-1:0]	com_tar_addr	// target address of commited inst
);

	/***** internal parameters *****/
	localparam INST_OFS = $clog2(INST/`ByteBitWidth);
	localparam BTB_ADDR = $clog2(BTB_D);
	localparam BTB_TAG = ADDR - BTB_ADDR - INST_OFS;
	localparam CNT_MAX = {CNT{1'b1}};
	localparam CNT_MIN = {CNT{1'b0}};
	localparam CNT_DEF = CNT_MAX;
	/***** register *****/
	reg [ADDR-1:0]					addr_buf [BTB_D-1:0];
	reg [BTB_TAG-1:0]				tag [BTB_D-1:0];
	reg [CNT-1:0]					cnt [BTB_D-1:0];
	/***** internal wires *****/
	/* for train */
	wire [BTB_TAG*SIMBRCOM-1:0]		tr_tag;
	wire [BTB_ADDR*SIMBRCOM-1:0]	tr_idx;
	wire [ADDR-1:0]					next_addr_buf [BTB_D-1:0];
	wire [BTB_TAG-1:0]				next_tag [BTB_D-1:0];
	wire [CNT-1:0]					next_cnt [BTB_D-1:0];


	/***** prediction *****/
	generate
		genvar gi;
		for ( gi = 0; gi < FETCH; gi = gi + 1 ) begin : Loop_pred
			wire [BTB_ADDR-1:0]		pred_idx;
			wire [ADDR-1:0]			addr_each;
			wire [BTB_TAG-1:0]		tag_each;
			wire					tag_match;
			wire [CNT-1:0]			cnt_each;
			wire					valid_tmp;
			/* entry setup */
			assign addr_each = btb_addr[`RangeG(gi,ADDR)];
			assign pred_idx = addr_each[BTB_ADDR+INST_OFS-1:INST_OFS];

			/* tag check */
			assign tag_each = addr_each[ADDR-1:BTB_ADDR+INST_OFS];
			assign tag_match = ( tag_each == tag[pred_idx] );

			/* prediction */
			assign cnt_each = cnt[pred_idx];
			assign valid_tmp = cnt_each[CNT-1];
			assign target_valid[gi] = tag_match & valid_tmp;
			assign target_addr[`RangeG(gi,ADDR)] = addr_buf[pred_idx];
		end
	endgenerate


	/***** train *****/
	/* generte index */
	generate
		genvar gj;
		for ( gj = 0; gj < SIMBRCOM; gj = gj + 1 ) begin : Loop_com
			wire [ADDR-1:0]			addr_each;
			wire [BTB_TAG-1:0]		tag_each;
			wire [BTB_ADDR-1:0]		idx_each;
			/* entry setup */
			assign addr_each = com_addr[`RangeG(gj,ADDR)];
			assign idx_each = addr_each[BTB_ADDR+INST_OFS-1:INST_OFS];
			assign tr_idx[`RangeG(gj,BTB_ADDR)] = idx_each;

			/* tag check */
			assign tag_each = addr_each[ADDR-1:BTB_ADDR+INST_OFS];
			assign tr_tag[`RangeG(gj,BTB_TAG)] = tag_each;
		end
	endgenerate

	/* update data */
	generate
		genvar gk;
		for ( gk = 0; gk < BTB_D; gk = gk + 1 ) begin : Loop_train
			assign {next_addr_buf[gk], next_tag[gk], next_cnt[gk]}
				= update_table(gk, pc_chg_com_, tr_idx, tr_tag, 
					com_tar_addr, chg_taken_, addr_buf[gk], tag[gk], cnt[gk]);
		end
	endgenerate

	/* update functions */
	localparam UPDATE_TABLE = ADDR + BTB_TAG + CNT;
	function [UPDATE_TABLE-1:0] update_table;
		input [BTB_ADDR-1:0]			idx;			// index
		input [SIMBRCOM-1:0]			commit_;		// br inst commited
		input [BTB_ADDR*SIMBRCOM-1:0]	tr_idx;			// training data
		input [BTB_TAG*SIMBRCOM-1:0]	tr_tag;			//
		input [SIMBRCOM*ADDR-1:0]		tr_target;		//
		input [SIMBRCOM-1:0]			tr_taken_;		//
		input [ADDR-1:0]				cur_addr_buf;	// current data
		input [BTB_TAG-1:0]				cur_tag;		//
		input [CNT-1:0]					cur_cnt;		//
		reg [SIMBRCOM-1:0]				idx_match;
		reg [SIMBRCOM-1:0]				tag_match;
		reg [BTB_TAG-1:0]				tr_tag_sep [SIMBRCOM-1:0];
		reg [ADDR-1:0]					tr_target_sep [SIMBRCOM-1:0];
		reg								confident;
		reg [ADDR-1:0]					out_addr_buf;
		reg [BTB_TAG-1:0]				out_tag;
		reg [CNT-1:0]					out_cnt;
		integer i;
		begin
			confident = cur_cnt[CNT-1];
			out_addr_buf = cur_addr_buf;
			out_tag = cur_tag;
			out_cnt = cur_cnt;
			/* tag matching */
			for ( i = 0; i < SIMBRCOM; i = i + 1 ) begin
				/* separate */
				tr_tag_sep[i] = tr_tag[`RangeF(i,BTB_TAG)];
				tr_target_sep[i] = tr_target[`RangeF(i,ADDR)];
				/* matching */
				idx_match[i] = ( tr_idx[`RangeF(i,BTB_ADDR)] == idx );
				tag_match[i] = ( tr_tag[`RangeF(i,BTB_TAG)] == cur_tag );
			end

			/* select slot */
			for ( i = 0; i < SIMBRCOM; i = i + 1 ) begin
				if ( idx_match[i] && !commit_[i] ) begin
					if ( tag_match[i] ) begin
						/* for tag matched branch/jump */
						if ( tr_taken_[i] == `Enable_ ) begin
							out_cnt = `CntUp(out_cnt,CNT_MAX,1'b1);
						end else begin
							out_cnt = `CntDwn(out_cnt,CNT_MIN,1'b1);
						end
					end else begin
						/* for other branch/jump */
						if ( tr_taken_[i] == `Enable_ ) begin
							out_cnt = confident ? out_cnt - 1 : CNT_DEF;
							out_addr_buf 
								= confident ? cur_addr_buf : tr_target_sep[i];
							out_tag = confident ? cur_tag : tr_tag_sep[i];
						end
					end
				end
			end
			update_table = {out_addr_buf, out_tag, out_cnt};
		end
	endfunction


	/***** sequential logics *****/
	integer i;
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			for ( i = 0; i < BTB_D; i = i + 1 ) begin
				addr_buf[i] <= {BTB_TAG{1'b0}};
				tag[i] <= {BTB_TAG{1'b0}};
				cnt[i] <= {CNT{1'b0}};
			end
		end else begin
			for ( i = 0; i < BTB_D; i = i + 1 ) begin
				addr_buf[i] <= next_addr_buf[i];
				tag[i] <= next_tag[i];
				cnt[i] <= next_cnt[i];
			end
		end
	end

endmodule
