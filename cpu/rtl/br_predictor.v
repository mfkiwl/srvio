/*
* <br_predictor.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.h"
`include "cpu_config.h"

module br_predictor #(
	parameter ADDR = `AddrWidth,
	parameter PRED_D = `PredMaxDepth,
	parameter PRT_D = `PredTableDepth, 
	parameter PREDICTOR = `PredType
)(
	input wire						clk,
	input wire						reset_,
	input wire						flush_,

	// prediction
	input wire [SIMBRF-1:0]			br_,
	input wire [SIMBRF*ADDR-1:0]	br_addr,
	output wire [SIMBRF-1:0]		pred_taken,

	// feedback and train
	input wire [SIMBRCOM-1:0]		br_commit_,
	input wire [SIMBRCOM-1:0]		br_taken_,
	input wire [SIMBRCOM-1:0]		br_pred_miss_
);

	//***** select branch predictor
	generate
		case ( PREDICTOR )
			`PredSatCnt : begin : cnt
				br_pred_cnt #(
					.ADDR		( ADDR ),
					.PRED_D		( PRED_D ),
					.PRT_D		( PRT_D ),
					.SIMBRF		( SIMBRF ),
					.SIMBRCOM	( SIMBRCOM ),
					.OUTREG		( `Enable )
				) predictor (
					.clk			( clk ),
					.reset_			( reset_ ),
					.flush_			( flush_ ),
					.br_			( br_ ),
					.br_addr		( br_addr ),
					.pred_taken		( pred_taken ),
					.br_commit_		( br_commit_ ),
					.br_taken_		( br_taken_ ),
					.br_pred_miss_	( br_pred_miss_ )
					//,.busy			( busy )	// may be managed by upper layer
				);
			end
			`PredCorrelate : begin : correlating
			end
			`PredTournament : begin : tournament
			end
			`PredGshare : begin : gshare
			end
			`PredPerceptron : begin : Perceptron
			end
			`PredTage : begin : TAGE
			end
		endcase
	endgenerate

endmodule
