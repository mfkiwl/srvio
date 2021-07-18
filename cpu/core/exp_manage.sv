/*
* <exp_manage.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "exception.svh"
`include "csr.svh"

module exp_manage #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth
)(
	input wire				commit_exp_,
	input ExpCode_t			commit_exp_code,

	input wire				creg_exp_mask,
	input [DATA-1:0]		creg_tvec,

	output logic [ADDR-1:0]	exp_handler_pc
);

	//***** internal parameters
	localparam VEC = DATA - $bits(TvecMode_t);

	//***** internal types
	typedef struct packed {
		logic [VEC-1:0]		handler;
		TvecMode_t			mode;
	} Tvec_t;

	//***** internal wires
	Tvec_t					tvec;



	//***** assign internal
	assign tvec = creg_tvec;

	wire [10:0] tmp = {commit_exp_code,2'b00};



	//***** sequentila logics
	always_comb begin
		case ( tvec.mode )
			TVEC_VECTOR : begin
				exp_handler_pc = 
					{tvec.handler, 2'b00} + {commit_exp_code, 2'b00};
			end
			default : begin
				// TVEC_DIRECT, and invalid patterns
				exp_handler_pc = {tvec.handler, 2'b00};
			end
		endcase
	end

endmodule
