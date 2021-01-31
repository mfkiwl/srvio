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
	parameter CNT = `BtbCntWidth
)(
	input wire						clk,
	input wire						reset_,

	// prediction
	input wire [ADDR-1:0]			pc,
	output wire						btb_hit,		// target is valid
	output wire [ADDR-1:0]			btb_addr,		// target address

	// train
	input wire						br_commit_,		// branch commit
	input wire 						br_taken_,		// branch taken
	input wire						br_miss_,		// branch prediction miss
	input wire 						jump_commit_,	// br/jump commit
	input wire						jump_miss_,		// indirect jump target miss
	input wire [ADDR-1:0]			com_addr,		// commit pc
	input wire [ADDR-1:0]			com_tar_addr	// target address of commited inst
);

	//***** internal parameters
	localparam INST_OFS = $clog2(INST/`ByteBitWidth);
	localparam BTB_ADDR = $clog2(BTB_D);
	localparam BTB_TAG = ADDR - BTB_ADDR - INST_OFS;
	localparam CNT_MAX = {CNT{1'b1}};
	localparam CNT_MIN = {CNT{1'b0}};
	localparam CNT_DEF = CNT_MAX;

	//***** internal register
	reg [ADDR-1:0]					addr_buf [BTB_D-1:0];
	reg [BTB_TAG-1:0]				tag [BTB_D-1:0];
	reg [CNT-1:0]					cnt [BTB_D-1:0];

	//***** internal wires
	//*** input pc
	wire [BTB_ADDR-1:0]				btb_idx;
	wire [BTB_TAG-1:0]				in_pc_tag;
	//*** prediction
	wire [BTB_TAG-1:0]				pred_tag;
	wire [CNT-1:0]					pred_cnt;
	wire							tag_match;
	wire							entry_valid;
	//*** training
	wire [BTB_ADDR-1:0]				com_idx;
	wire [BTB_TAG-1:0]				com_tag;
	wire [CNT-1:0]					com_cnt;
	wire							com_tag_match;
	wire							com_confident;

	//***** combinational cells 
	logic							buf_we_;
	logic							cnt_we_;
	logic [CNT-1:0]					next_cnt;



	//***** output assign
	assign btb_addr = addr_buf[btb_idx];
	assign btb_hit = tag_match && entry_valid;



	//***** internal assign
	//*** prediction
	assign btb_idx = pc[BTB_ADDR+INST_OFS-1:INST_OFS];
	assign in_pc_tag = pc[ADDR-1:BTB_ADDR+INST_OFS];
	assign pred_tag = tag[btb_idx];
	assign tag_match = ( in_pc_tag == pred_tag );
	assign pred_cnt = cnt[btb_idx];
	assign entry_valid = ( pred_cnt != CNT_MIN );
	//*** table update
	assign com_idx = com_addr[BTB_ADDR+INST_OFS-1:INST_OFS];
	assign com_tag = com_addr[ADDR-1:BTB_ADDR+INST_OFS];
	assign com_cnt = cnt[com_idx];
	assign com_tag_match = ( com_tag == tag[com_idx] );
	assign com_confident = com_cnt[CNT-1];



	//***** combinational logics
	always_comb begin
		//*** btb update
		unique if ( br_commit_ == `Enable_ ) begin
			if ( tag_match ) begin
				// when a commited branch is tracked
				buf_we_ = `Disable_;
				cnt_we_ = `Enable_;
				case ( { br_taken_, br_miss_ } )
					{`Enable_, `Disable_} : begin
						next_cnt = CNT_MAX;
						cnt_we_ = `Enable_;
					end
					{`Enable_, `Enable_ } : begin
						next_cnt = `CntUp(com_cnt,CNT_MAX,1'b1);
						cnt_we_ = `Enable_;
					end
					default : begin
						next_cnt = `CntDwn(com_cnt,CNT_MIN,1'b1);
					end
				endcase
			end else begin
				// when a commited branch is not tracked
				case ( { br_taken_, br_miss_ } )
					{`Enable_, `Disable_} : begin
						next_cnt = CNT_MAX;
						cnt_we_ = `Enable_;
						buf_we_ = `Enable_;
					end
					{`Enable_, `Enable_ } : begin
						// conservatively replace entry,
						//		if old entry is unconfident
						next_cnt = CNT_MIN + 1'b1;
						cnt_we_ = com_confident;
						buf_we_ = com_confident;
					end
					default : begin
						next_cnt = {CNT{1'b0}};
						cnt_we_ = `Disable_;
						buf_we_ = `Disable_; 
					end
				endcase
			end
		end else if ( jump_commit_ == `Enable_ ) begin
			next_cnt = CNT_MAX;
			cnt_we_ = `Enable_;
			if ( jump_miss_ == `Enable_ ) begin
				buf_we_ = `Enable_;
			end else begin
				buf_we_ = `Disable_;
			end
		end else begin
			buf_we_ = `Disable_;
			cnt_we_ = `Disable_;
			next_cnt = {CNT{1'b0}};
		end
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		int i;
		if ( reset_ == `Enable_ ) begin
			for ( i = 0; i < BTB_D; i = i + 1 ) begin
				addr_buf[i] = {ADDR{1'b0}};
				tag[i] = {BTB_TAG{1'b0}};
				cnt[i] = {CNT{1'b0}};
			end
		end else begin
			if ( buf_we_ == `Enable_ ) begin
				addr_buf[com_idx] <= com_tar_addr;
				tag[com_idx] <= com_tag;
			end
			if ( cnt_we_ == `Enable_ ) begin
				cnt[com_idx] <= next_cnt;
			end
		end
	end

endmodule
