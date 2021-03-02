/*
* <alu_exe.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "decode.svh"
`include "regfile.svh"
`include "exe.svh"
`include "exception.svh"

module alu_exe #(
	parameter DATA = `DataWidth
)(
	input AluCommand_t		command,
	input wire [DATA-1:0]	data1,
	input wire [DATA-1:0]	data2,

	output logic [DATA-1:0]	res,
	output wire				exp_,
	output ExpCode_t		exp_code
);

	//***** internal parameters
	localparam DATA_SFT = $clog2(DATA);
	localparam WORD = `WordBitWidth;
	localparam WORD_SFT = $clog2(`WordBitWidth);

	//***** internal wires
	wire					op_unsigned;
	wire					op_word;
	wire					op_sub;
	wire [DATA-1:0]			add_data1;
	wire [DATA-1:0]			add_data2;
	wire [DATA-1:0]			mult_data1;
	wire [DATA-1:0]			mult_data2;
	wire [DATA-1:0]			comp_data1;
	wire [DATA-1:0]			comp_data2;
	wire [DATA-1:0]			sft_data1;
	wire [DATA_SFT-1:0]		sft_data2;
	wire [DATA-1:0]			logic_data1;
	wire [DATA-1:0]			logic_data2;
	wire [DATA-1:0]			sft_ext;
	wire					sft_large;
	wire					sft_right;
	wire					sft_arith;
	wire [DATA-1:0]			sft_arith_sign;
	wire					comp_lt;
	wire					comp_neg;

	//***** combinational cells
	logic [DATA-1:0]		res_add;
	logic [DATA-1:0]		res_mult;
	logic					res_comp;
	logic [DATA-1:0]		res_sft;
	logic [DATA-1:0]		res_logic;


	//***** assign output
	//*** currently integer exception is not supported...
	assign exp_ = `Disable_;
	assign exp_code = EXP_I_MISS_ALIGN;



	//***** assign internal
	//*** operations
	assign op_unsigned = command.sub_op[`AluUnsigned];
	assign op_word = command.sub_op[`AluWord];
	assign op_sub = command.sub_op[`AluSub];
	//*** operands
	assign add_data1 = ( command.op == ALU_ADD ) ? data1 : 0;
	assign add_data2 = ( command.op == ALU_ADD ) ? data2 : 0;
	assign mult_data1 = ( command.op == ALU_MULT ) ? data1 : 0;
	assign mult_data2 = ( command.op == ALU_MULT ) ? data2 : 0;
	assign comp_data1 = ( command.op == ALU_COMP ) ? data1 : 0;
	assign comp_data2 = ( command.op == ALU_COMP ) ? data2 : 0;
	assign sft_data1 = ( command.op == ALU_SHIFT ) ? data1 : 0;
	assign sft_data2 = ( command.op == ALU_SHIFT ) ? data2 : 0;
	assign logic_data1 = ( command.op == ALU_LOGIC ) ? data1 : 0;
	assign logic_data2 = ( command.op == ALU_LOGIC ) ? data2 : 0;
	//*** shift
	assign sft_ext =
		( op_word )
			? {{DATA-WORD{1'b0}}, {WORD{sft_data1[`WordBitWidth-1]}}}
			: {DATA{sft_data1[DATA-1]}};
	assign sft_large =
		( op_word )
			? | data2[DATA-1:WORD_SFT]
			: | data2[DATA-1:DATA_SFT];
	assign sft_right = command.sub_op[`AluRight];
	assign sft_arith = command.sub_op[`AluArith];
	assign sft_arith_sign = 
		( op_word )
			? sft_ext << ( WORD - sft_data2[WORD_SFT-1:0] )
			: sft_ext << ( DATA - sft_data2 );



	//***** sequential logics
	always_comb begin
		//*** calculation
		//* Add/Subtract
		//		Currently overflow check is not implemented...
		if ( op_sub ) begin
			res_add = add_data1 - add_data2;
		end else begin
			res_add = add_data1 + add_data2;
		end


		//*** Multiply

		//*** Compare
		case ( {op_unsigned, command.sub_op[`AluCompLt]} )
			{`Disable, `Enable} : begin
				// less than
				res_comp = ( $signed(comp_data1) < $signed(comp_data2) );
			end
			{`Enable, `Enable} : begin
				// less than unsigned
				res_comp = ( comp_data1 < comp_data2 );
			end
			default : begin
				// equal
				res_comp = ( comp_data1 == comp_data2 );
			end
		endcase

		//*** Shift
		case ( {sft_arith, sft_right} )
			{`Disable, `Enable} : begin
				// shift right logical
				res_sft =
					sft_large
						? {DATA{1'b0}}
						: sft_data1 >> sft_data2;
			end
			{`Enable, `Enable} : begin
				// shift right arithmetic
				res_sft =
					sft_large
						? sft_ext
						: ( sft_data1 >> sft_data2 ) | sft_arith_sign;
			end
			default : begin
				// shift left
				res_sft =
					sft_large
						? {DATA{1'b0}}
						: sft_data1 << sft_data2;
			end
		endcase

		//*** Logical Operation
		case ( command.sub_op[`AluLogicOp] )
			`AluLogicAnd : res_logic = logic_data1 & logic_data2;
			`AluLogicOr : res_logic = logic_data1 | logic_data2;
			`AluLogicXor : res_logic = logic_data1 ^ logic_data2;
			default : res_logic = 0;
		endcase

		//*** Output selection
		case ( command.op )
			ALU_ADD : begin
				if ( op_word ) begin
					res = {{DATA-WORD{1'b0}}, res_add[`Word]};
				end else begin
					res = res_add;
				end
			end
			ALU_MULT : begin
				res = res_mult;
			end
			ALU_COMP : begin
				if ( command.sub_op[`AluCompNeg] ) begin
					res = {{DATA-1{1'b0}}, !res_comp};
				end else begin
					res = {{DATA-1{1'b0}}, res_comp};
				end
			end
			ALU_SHIFT : begin
				res = res_sft;
			end
			ALU_LOGIC : begin
				if ( command.sub_op[`AluLogicNeg] ) begin
					res = ~res_logic;
				end else begin
					res = res_logic;
				end
			end
			default : begin
				res = 0;
			end
		endcase
	end

endmodule
