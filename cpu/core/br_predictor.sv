/*
* <br_predictor.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module br_predictor #(
	parameter ADDR = `AddrWidth,
	parameter CNT = `PredCntWidth,
	parameter DEPTH = `PredTableDepth, 
	parameter PRED_MAX = `PredMaxDepth,
	parameter BrPredType_t PREDICTOR = BR_PRED_CNT
)(
	input wire						clk,
	input wire						reset_,

	input wire						flush_,

	// prediction
	input wire						br_,
	input wire [ADDR-1:0]			br_pc,
	output wire						br_pred,

	// feedback and train
	input wire [ADDR-1:0]			commit_pc,
	input wire						br_commit_,
	input wire 						br_result,
	input wire 						br_pred_miss_
);

	//***** select branch predictor
	generate
		case ( PREDICTOR )
			BR_PRED_CNT : begin : cnt
				br_pred_cnt #(
					.ADDR		( ADDR ),
					.CNT		( CNT ),
					.DEPTH		( DEPTH ),
					.PRED_MAX	( PRED_MAX )
				) predictor (
					.clk			( clk ),
					.reset_			( reset_ ),

					.flush_			( flush_ ),

					.br_pc			( br_pc ),
					.br_pred		( br_pred ),

					.commit_pc		( commit_pc ),
					.br_commit_		( br_commit_ ),
					.br_result		( br_result ),
					.br_pred_miss_	( br_pred_miss_ )
				);
			end

			BR_PRED_CORRELATE : begin : correlating
			end
			BR_PRED_GSHARE : begin : tournament
			end
			BR_PRED_PERCEPTRON : begin : gshare
			end
			BR_PRED_TAGE : begin : TAGE
			end
		endcase
	endgenerate

endmodule
