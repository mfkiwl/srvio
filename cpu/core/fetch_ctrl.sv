/*
* <fetch_ctrl.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module fetch_ctrl #(
	parameter ADDR = `AddrWidth
)(
	input wire				clk,
	input wire				reset_,

	// fetch request
	input wire				ic_stall,
	input wire [ADDR-1:0]	next_fetch_pc,
	input wire				iag_busy,
	output wire				fetch_e_,
	output wire [ADDR-1:0]	fetch_pc,
	output wire				fetch_stall,

	// fetch
	input wire				inst_invalid,
	output wire				inst_e_,
	output wire [ADDR-1:0]	inst_pc,

	// decode
	input wire				dec_stall,
	output wire				dec_stop,

	// exe
	input wire				wb_flush_,
	input wire				wb_exp_,

	// commit
	input wire				flush_,		// - backend pipeline flush 
										//		on branch miss commit, or
										// - entire pipeline flush
										//		on exception commit
	input wire				commit_exp_,
	output wire				exp_flush_
);

	//***** internal type
	typedef enum logic [1:0] {
		ST_NORMAL = 2'b00,		// normal execution
		ST_MISS_WAIT = 2'b01,	// wait jump/branch miss prediction commit
		ST_EXP_WAIT = 2'b11		// wait exception commit
	} FetchStat_t;

	//***** internal wires
	wire					br_flush;

	//***** internal registers
	reg						fetch_e_reg_;
	reg [ADDR-1:0]			fetch_pc_reg;
	reg						ic_access_e_;
	reg [ADDR-1:0]			ic_access_addr;
	FetchStat_t				fetch_stat;

	//***** combinational cells
	logic					next_fetch_e_;
	logic					next_ic_access_e_;
	logic [ADDR-1:0]		next_ic_access_addr;



	//***** assign output
	assign fetch_e_ = fetch_e_reg_;
	assign fetch_pc = fetch_pc_reg;
	assign inst_e_ = ic_access_e_;
	assign inst_pc = ic_access_addr;
	assign fetch_stall =
		ic_stall || ( dec_stall && !ic_access_e_ ) || iag_busy;
	assign dec_stop = ( fetch_stat != ST_NORMAL );
	assign exp_flush_ = commit_exp_;



	//***** assign internal
	assign br_flush = 
		!wb_flush_ || 
		inst_invalid ||
		( !flush_ && fetch_stat != ST_NORMAL );



	//***** combinational logics
	always_comb begin
		case ( fetch_stat )
			ST_EXP_WAIT : begin
				next_fetch_e_ = `Disable_;
			end

			default : begin
				next_fetch_e_ = fetch_stall;
			end
		endcase

		// TODO: Optimize logic to reduce redundunt logics
		//			co-optimize with fetch_iag/br_status.v
		case ( {br_flush, dec_stall, ic_stall} )
			{`Disable, `Disable, `Disable} : begin
				// no event occur
				next_ic_access_e_ = fetch_e_;
				next_ic_access_addr = fetch_pc;
			end

			{`Disable, `Disable, `Enable} : begin
				// i-cache miss occured (stall fetch)
				next_ic_access_e_ = `Disable_;
				next_ic_access_addr = ic_access_addr;
			end

			{`Disable, `Enable, `Disable}, 
				{`Disable_, `Enable, `Enable_} : begin
				// decoder pipeline is stalled
				// TODO: support instruction fetch,
				//		while decode stage is stopping
				next_ic_access_e_ = ic_access_e_;
				next_ic_access_addr = ic_access_addr;
			end

			default : begin // ( br_flush == `Enable )
				// frontend pipeline is flushed
				next_ic_access_e_ = `Disable_;
				next_ic_access_addr = ic_access_addr; // don't care
			end
		endcase
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			fetch_e_reg_ <= `Enable_;
			fetch_pc_reg <= `InitialPC;
			ic_access_e_ <= `Disable_;
			ic_access_addr <= 0;
			fetch_stat <= ST_NORMAL;
		end else begin
			fetch_e_reg_ <= next_fetch_e_;
			fetch_pc_reg <= next_fetch_pc;
			ic_access_e_ <= next_ic_access_e_;
			ic_access_addr <= next_ic_access_addr;

			case ( fetch_stat )
				ST_NORMAL : begin
					if ( wb_flush_ == `Enable_ ) begin
						fetch_stat <= ST_MISS_WAIT;
					end else if ( wb_exp_ == `Enable_ ) begin
						fetch_stat <= ST_EXP_WAIT;
					end
				end

				ST_MISS_WAIT : begin
					if ( wb_exp_ == `Enable_ ) begin
						fetch_stat <= ST_EXP_WAIT;
					end else if ( flush_ == `Enable_ ) begin
						fetch_stat <= ST_NORMAL;
					end
				end

				ST_EXP_WAIT : begin
					if ( flush_ == `Enable_ ) begin
						fetch_stat <= ST_NORMAL;
					end
				end

				default : begin
					fetch_stat <= ST_NORMAL;
				end
			endcase
		end
	end

endmodule
