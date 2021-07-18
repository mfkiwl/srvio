/*
* <rob_status.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "rob.svh"
`include "exception.svh"

module rob_status #(
	parameter byte DATA = `DataWidth,
	parameter byte ADDR = `AddrWidth,
	parameter byte ROB_DEPTH = `RobDepth,
	// constant
	parameter byte ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				dec_e_,
	input wire [ADDR-1:0]	dec_pc,
	input RegFile_t			dec_rd,
	input wire				dec_br_,
	input wire				dec_br_pred,
	input wire				dec_jump_,
	input wire				dec_invalid,
	output wire [ROB-1:0]	dec_rob_id,

	input RegFile_t			ren_rs1,
	input RegFile_t			ren_rs2,
	output wire				ren_rs1_ready,
	output wire				ren_rs2_ready,

	input wire [ROB-1:0]	issue_rob_id,
	output wire [ADDR-1:0]	issue_pc,

	input wire				wb_e_,
	input wire [ROB-1:0]	wb_rob_id,
	input wire				wb_exp_,
	input ExpCode_t			wb_exp_code,
	input wire				wb_pred_miss_,
	input wire				wb_jump_miss_,

	output wire				commit_e_,
	output wire				com_jump_,
	output wire				com_miss_pred_,
	output wire				flush_,
	output wire [ADDR-1:0]	com_pc,
	output RegFile_t		com_rd,
	output wire				com_exp_,
	output ExpCode_t		com_exp_code,
	output wire [ROB-1:0]	com_rob_id,

	output wire				rob_busy
);

	//***** internal types
	typedef struct packed {
		//logic [ADDR-1:0]	pc;
		RegFile_t			rd;
		logic				br_inst_;
		logic				br_pred;
		logic				jump_inst_;
	} RobInfo_t;

	typedef struct packed {
		logic				br_miss_;
		logic				jump_miss_;
		logic				exp_;
		ExpCode_t			exp_code;
	} RobStat_t;

	//***** internal parameters
	localparam ROB_INFO = $bits(RobInfo_t);
	localparam ROB_STAT = $bits(RobStat_t);

	//***** internal registers
	reg [ROB_DEPTH-1:0]		entry_valid;
	reg [ROB_DEPTH-1:0]		com_ready_;

	//***** internal wires
	wire					busy_;
	//*** decode
	RobInfo_t				dec_rob_info;
	//*** writeback
	RobStat_t				wb_rob_stat;
	//*** commit
	wire					com_br_;
	wire [ADDR-1:0]			com_pc_out;
	wire					com_br_miss_;
	wire					com_jump_miss_;
	RobInfo_t				com_rob_info;
	RobStat_t				com_rob_stat;

	//***** combinational logics
	logic [ROB_DEPTH-1:0]	next_valid;
	logic [ROB_DEPTH-1:0]	next_ready_;
	logic [ROB_DEPTH-1:0]	dec_match;
	logic [ROB_DEPTH-1:0]	wb_match;
	logic [ROB_DEPTH-1:0]	com_match;



	//***** assign output
	assign commit_e_ = com_ready_[com_rob_id];
	assign com_miss_pred_ = com_br_miss_ && com_jump_miss_;
	assign flush_ = commit_e_ || ( com_miss_pred_ && com_exp_ );
`ifdef DEBUG
	assign com_pc = 
		( commit_e_ )
			? 0
			: com_pc_out;
	assign com_rd = 
		( commit_e_ )
			? 0
			: com_rob_info.rd;
	assign com_exp_code = 
		( commit_e_ )
			? EXP_I_MISS_ALIGN
			: com_rob_stat.exp_code;
`else
	//assign com_pc = com_rob_info.pc;
	assign com_pc = com_pc_out;
	assign com_rd = com_rob_info.rd;
	assign com_exp_code = com_rob_stat.exp_code;
`endif
	assign com_exp_ = commit_e_ || com_rob_stat.exp_;
	assign ren_rs1_ready = !com_ready_[ren_rs1.addr[ROB-1:0]];
	assign ren_rs2_ready = !com_ready_[ren_rs2.addr[ROB-1:0]];
	assign rob_busy = !busy_;



	//***** internal assign
	//*** decode
	assign dec_rob_info = '{
		//pc : dec_pc,
		rd : dec_rd,
		br_inst_ : dec_br_,
		br_pred: dec_br_pred,
		jump_inst_ : dec_jump_
	};
	//*** write back
	assign wb_rob_stat = '{
		br_miss_ : wb_pred_miss_,
		jump_miss_ : wb_jump_miss_,
		exp_ : wb_exp_,
		exp_code : wb_exp_code
	};
	//*** commit (status check for debugging)
	assign com_br_ = com_rob_info.br_inst_ || commit_e_;
	assign com_jump_ = com_rob_info.jump_inst_ || commit_e_;
	assign com_br_miss_ = com_rob_stat.br_miss_ || commit_e_;
	assign com_jump_miss_ = com_rob_stat.jump_miss_ || commit_e_;



	//***** instruction information
	pc_buf #(
		.DATA		( ADDR ),
		.DEPTH		( ROB_DEPTH ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ACT		( `Low )
	) pc_buf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ),

		.we			( dec_e_ ),
		.wd			( dec_pc ),
		.re			( commit_e_ ),
		.rd			( com_pc_out ),

		.issue_id	( issue_rob_id ),
		.issue_pc	( issue_pc )
	);

	ring_buf #(
		.DATA		( ROB_INFO ),
		.DEPTH		( ROB_DEPTH ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ACT		( `Low )
	) inst_buf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( flush_ ),
		.we			( dec_e_ ),
		.wd			( dec_rob_info ),
		.widx		( dec_rob_id ),
		.wv			(),

		.re			( commit_e_ ),
		.rd			( com_rob_info ),
		.ridx		( com_rob_id ),
		.rv			(),

		.busy		( busy_ )
	);



	//***** status buffer
	regfile #(
		.DATA		( ROB_STAT ),
		.ADDR		( ROB ),
		.READ		( 1 ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Disable )
	) status_buf (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( com_rob_id ),
		.waddr		( wb_rob_id ),
		.we_		( wb_e_ ),
		.wdata		( wb_rob_stat ),
		.rdata		( com_rob_stat )
	);



	//***** combinational logics
	int ci;
	always_comb begin
		for ( ci = 0; ci < ROB_DEPTH; ci = ci + 1 ) begin
			dec_match[ci] = !dec_e_ && ( dec_rob_id == ci );
			wb_match[ci] = !wb_e_ && ( wb_rob_id == ci );
			com_match[ci] = !commit_e_ && ( com_rob_id == ci );

			//*** entry
			case ( { com_match[ci], wb_match[ci] } )
				{`Disable, `Enable} : begin
					next_valid[ci] = `Enable;
				end
				{`Enable, `Disable} : begin
					next_valid[ci] = `Disable;
				end
				default: begin
					next_valid[ci] = entry_valid[ci];
				end
			endcase

			//*** ready to commit
			case ( { com_match[ci], wb_match[ci], dec_match[ci] } )
				{`Disable, `Disable, `Enable} : begin
					next_ready_[ci] = !dec_invalid;
				end
				{`Disable, `Enable, `Disable} : begin
					next_ready_[ci] = `Enable_;
				end
				{`Enable, `Disable, `Disable} : begin
					next_ready_[ci] = `Disable_;
				end
				default : begin
					next_ready_[ci] = com_ready_[ci];
				end
			endcase
		end
	end



	//***** sequential logcis
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			entry_valid <= {ROB_DEPTH{`Disable}};
			com_ready_ <= {ROB_DEPTH{`Disable_}};
		end else begin
			if ( flush_ == `Enable_ ) begin
				entry_valid <= {ROB_DEPTH{`Disable}};
				com_ready_ <= {ROB_DEPTH{`Disable_}};
			end else begin
				entry_valid <= next_valid;
				com_ready_ <= next_ready_;
			end
		end
	end

endmodule
