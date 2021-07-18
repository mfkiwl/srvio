/*
* <decoder.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "decode.svh"
`include "rv_opcodes.svh"

module decoder  #(
	parameter DATA = `DataWidth
)(
	input union packed {
		RvRtype_t		r;
		RvItype_t		i;
		RvIS32type_t	is32;
		RvIS64type_t	is64;
		RvStype_t		s;
		RvUtype_t		u;
		RvJtype_t		j;
		RvBtype_t		b; }	inst,

	//output wire					dec_e_out_,
	output RegFile_t			rs1_out,
	output RegFile_t			rs2_out,
	output RegFile_t			rd_out,
	output wire					br_out_,
	output wire					jump_out_,
	output wire					invalid_out,
	output ImmData_t			imm_data_out,
	output ExeUnit_t			unit_out,
	output OpCommand_t			command_out
);

	//***** internal wires
	wire [`RvOpW-1:0]		opcode;

	//***** combinational cells
	RegFile_t				rs1;
	RegFile_t				rs2;
	RegFile_t				rd;
	logic					br_;
	logic					jump_;
	logic					invalid;
	ImmData_t				imm_data;
	ExeUnit_t				unit;
	OpCommand_t				command;
	string					inst_name;



	//***** assign output
	assign rs1_out = rs1;
	assign rs2_out = rs2;
	assign rd_out = rd;
	assign br_out_ = br_;
	assign jump_out_ = jump_;
	assign invalid_out = invalid;
	assign imm_data_out = imm_data;
	assign unit_out = unit;
	assign command_out = command;



	//***** assign internal
	assign opcode = inst[`RvOp];



	//***** combinational logics
	always_comb begin
		//*** default value
		rs1 = 0;
		rs2 = 0;
		rd = 0;
		br_ = `Disable_;
		jump_ = `Disable_;
		invalid = `Disable;
		imm_data = 0;
		unit = UNIT_NOP;
		command = 0;
		inst_name = "invalid";

		case ( opcode )
			`RvOpLoad : begin
				//* execution unit decode
				unit = UNIT_MEM;
				command.mem.op = MEM_LOAD;

				//* operand decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.i.rs1;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.i.rd;

				//* immediate encoding
				imm_data.sign = `Enable;
				imm_data.shift = IMM_NO_SHIFT;
				imm_data.size = IMM_SIZE12;
				imm_data.data = inst.i.imm;

				case ( inst.i.funct3 )
					`RvFunct3Byte : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeByte;
						inst_name = "lb";
					end

					`RvFunct3Half : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
						inst_name = "lh";
					end

					`RvFunct3Word : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeWord;
						inst_name = "lw";
					end

					`RvFunct3Double : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeDouble;
						inst_name = "ld";
					end

					`RvFunct3Ubyte : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeByte;
						inst_name = "lbu";
					end

					`RvFunct3Uhalf : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
						inst_name = "lhu";
					end

					`RvFunct3Uword : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeWord;
						inst_name = "lwu";
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
						inst_name = "invalid";
					end
				endcase
			end

			`RvOpStore: begin
				//* execution unit decode
				unit = UNIT_MEM;
				command.mem.op = MEM_STORE;

				//* operand decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.s.rs1;
				rs2.regtype = TYPE_GPR;
				rs2.addr = inst.s.rs2;

				//* immediate encoding
				imm_data.sign = `Enable;
				imm_data.shift = IMM_NO_SHIFT;
				imm_data.size = IMM_SIZE12;
				imm_data.data = {inst.s.imm1, inst.s.imm0};

				case ( inst.s.funct3 )
					`RvFunct3Byte : begin
						command.mem.sub_op[`MemSize] = `MemSizeByte;
						inst_name = "sb";
					end

					`RvFunct3Half : begin
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
						inst_name = "sh";
					end

					`RvFunct3Word : begin
						command.mem.sub_op[`MemSize] = `MemSizeWord;
						inst_name = "sw";
					end

					`RvFunct3Double : begin
						command.mem.sub_op[`MemSize] = `MemSizeDouble;
						inst_name = "sd";
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
						inst_name = "invalid";
					end
				endcase
			end

			`RvOpBranch : begin
				//* Important Note:
				//		Branch target is calculated at fetch_stage
				//		So. immediate is no used

				//* branch detected
				br_ = `Enable_;
				
				//* execution unit decode
				unit = UNIT_ALU;
				command.alu.op = ALU_COMP;
				command.alu.sub_op[`AluBranch] = `Enable;

				//* operands decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.b.rs1;
				rs2.regtype = TYPE_GPR;
				rs2.addr = inst.b.rs2;


				case ( inst.b.funct3 )
					`RvFunct3Beq : begin
						command.alu.sub_op[`AluCompLt] = `Disable;
						command.alu.sub_op[`AluCompNeg] = `Disable;
						inst_name = "beq";
					end

					`RvFunct3Bne : begin
						command.alu.sub_op[`AluCompLt] = `Disable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
						inst_name = "bne";
					end

					`RvFunct3Blt : begin
						command.alu.sub_op[`AluUnsigned] = `Disable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Disable;
						inst_name = "blt";
					end

					`RvFunct3Bge : begin
						command.alu.sub_op[`AluUnsigned] = `Disable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
						inst_name = "bge";
					end

					`RvFunct3Bltu : begin
						command.alu.sub_op[`AluUnsigned] = `Enable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Disable;
						inst_name = "bltu";
					end

					`RvFunct3Bgeu : begin
						command.alu.sub_op[`AluUnsigned] = `Enable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
						inst_name = "bgeu";
					end

					default : begin
						unit = UNIT_NOP;
						br_ = `Disable_;
						invalid = `Enable;
						inst_name = "invalid";
					end
				endcase
			end

			`RvOpJalr : begin
				//* jump detected
				jump_ = `Enable_;
				inst_name = "jalr";

				//* execution unit decode
				unit = UNIT_ALU;
				command.alu.op = ALU_ADD;
				command.alu.sub_op[`AluJump] = `Enable;

				//* operands decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.i.rs1;
				rs2.regtype = TYPE_PC;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.i.rd;

				//* immediate encode
				imm_data.sign = `Disable;
				imm_data.shift = IMM_NO_SHIFT;
				imm_data.size = IMM_SIZE12;
				imm_data.data = inst.i.imm;
			end

			`RvOpJal : begin
				//* (jump target is calculated at fetch_stage)
				//* jump detected
				jump_ = `Enable_;
				inst_name = "jal";

				//* execution unit decode
				unit = UNIT_ALU;
				command.alu.op = ALU_ADD;
				command.alu.sub_op[`AluJump] = `Enable;

				//* operands decode
				rs1.regtype = TYPE_PC;
				rs2.regtype = TYPE_IMM;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.i.rd;

				//* immediate encode
				imm_data.sign = `Disable;
				imm_data.shift = IMM_SHIFT1;
				imm_data.size = IMM_SIZE20;
				imm_data.data = {
					inst.j.imm3,
					inst.j.imm2,
					inst.j.imm1,
					inst.j.imm0
				};
			end

			`RvOpImm : begin
				//* execution unit decode
				unit = UNIT_ALU;

				//* operands decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.i.rs1;
				rs2.regtype = TYPE_IMM;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.i.rd;

				//* immediate encode
				imm_data.sign = `Disable;
				imm_data.shift = IMM_NO_SHIFT;
				imm_data.size = IMM_SIZE12;

				case ( inst.i.funct3 )
					`RvFunct3AddSub : begin
						command.alu.op = ALU_ADD;
						imm_data.data = inst.i.imm;
						inst_name = "addi";
					end

					`RvFunct3Sll : begin
						command.alu.op = ALU_SHIFT;
						command.alu.sub_op[`AluRight] = `Disable;
						command.alu.sub_op[`AluArith] = `Disable;
						inst_name = "slli";
						if ( DATA == 32 ) begin : RV32
							imm_data.data = inst.is32.shamt;
						end else begin : RV64
							imm_data.data = inst.is64.shamt;
						end
					end
				endcase
			end

			`RvOpR : begin
				//* operands decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.r.rs1;
				rs2.regtype = TYPE_GPR;
				rs2.addr = inst.r.rs2;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.r.rd;

				if ( inst.r.funct7 == `RvFunct7MulDiv ) begin
					//* Mul and Div

					case ( inst.r.funct3 )
						`RvFunct3Mul : begin
							unit = UNIT_ALU;
							command.alu.op = ALU_MULT;
							command.alu.sub_op[`AluMulHigh] = `Disable;
							command.alu.sub_op[`AluSrc1Sign] = `Disable;
							inst_name = "mul";
						end
						`RvFunct3Mulh : begin
							unit = UNIT_ALU;
							command.alu.op = ALU_MULT;
							command.alu.sub_op[`AluMulHigh] = `Enable;
							command.alu.sub_op[`AluSrc1Sign] = `Disable;
							inst_name = "mulh";
						end
						`RvFunct3Mulhsu : begin
							unit = UNIT_ALU;
							command.alu.op = ALU_MULT;
							command.alu.sub_op[`AluMulHigh] = `Enable;
							command.alu.sub_op[`AluSrc1Sign] = `Enable;
							inst_name = "mulhsu";
						end
						`RvFunct3Mulhu : begin
							unit = UNIT_ALU;
							command.alu.op = ALU_MULT;
							command.alu.sub_op[`AluMulHigh] = `Enable;
							command.alu.sub_op[`AluSrc1Sign] = `Disable;
							inst_name = "mulhu";
						end
						`RvFunct3Div : begin
							unit = UNIT_DIV;
							command.div.op = DIV_DIV;
							command.div.sub_op[`DivUnsigned] = `Disable;
							inst_name = "div";
						end
						`RvFunct3Divu : begin
							unit = UNIT_DIV;
							command.div.op = DIV_DIV;
							command.div.sub_op[`DivUnsigned] = `Enable;
							inst_name = "divu";
						end
						`RvFunct3Rem : begin
							unit = UNIT_DIV;
							command.div.op = DIV_REM;
							command.div.sub_op[`DivUnsigned] = `Disable;
							inst_name = "divu";
						end
						`RvFunct3Remu : begin
							unit = UNIT_DIV;
							command.div.op = DIV_REM;
							command.div.sub_op[`DivUnsigned] = `Enable;
							inst_name = "remu";
						end
					endcase
				end else begin
					//* simple operations

					//* execution unit decode
					unit = UNIT_ALU;


					case ( inst.r.funct3 )
						`RvFunct3AddSub : begin
							command.alu.op = ALU_ADD;
							unique if ( inst.r.funct7 == `RvFunct7Add ) begin
								command.alu.sub_op[`AluSub] = `Disable;
								inst_name = "add";
							end else if ( inst.r.funct7 == `RvFunct7Sub ) begin
								command.alu.sub_op[`AluSub] = `Enable;
								inst_name = "sub";
							end else begin
								//*** invalid funct7 code
								unit = UNIT_NOP;
								invalid = `Enable;
								inst_name = "invalid";
							end
						end

						`RvFunct3Sll : begin
							command.alu.op = ALU_SHIFT;
							command.alu.sub_op[`AluRight] = `Disable;
							command.alu.sub_op[`AluArith] = `Disable;
							inst_name = "sll";
						end

						`RvFunct3Slt : begin
							command.alu.op = ALU_COMP;
							command.alu.sub_op[`AluCompLt] = `Enable;
							inst_name = "slt";
						end

						`RvFunct3Sltu : begin
							command.alu.op = ALU_COMP;
							command.alu.sub_op[`AluUnsigned] = `Enable;
							command.alu.sub_op[`AluCompLt] = `Enable;
							inst_name = "sltu";
						end

						`RvFunct3Xor : begin
							command.alu.op = ALU_LOGIC;
							command.alu.sub_op[`AluLogicOp] = `AluLogicXor;
							inst_name = "xor";
						end

						`RvFunct3SraSrl : begin
							command.alu.op = ALU_SHIFT;
							command.alu.sub_op[`AluRight] = `Enable;
							unique if ( inst.r.funct7 == `RvFunct7Srl ) begin
								command.alu.sub_op[`AluArith] = `Disable;
								inst_name = "srl";
							end else if ( inst.r.funct7 == `RvFunct7Sra ) begin
								command.alu.sub_op[`AluArith] = `Enable;
								inst_name = "sra";
							end else begin
								//*** invalid funct7 code
								unit = UNIT_NOP;
								invalid = `Enable;
								inst_name = "invalid";
							end
						end

						`RvFunct3Or : begin
							command.alu.op = ALU_LOGIC;
							command.alu.sub_op[`AluLogicOp] = `AluLogicOr;
							inst_name = "or";
						end

						`RvFunct3And : begin
							command.alu.op = ALU_LOGIC;
							command.alu.sub_op[`AluLogicOp] = `AluLogicAnd;
							inst_name = "and";
						end
					endcase
				end
			end

			`RvOpAuipc : begin
				unit = UNIT_ALU;
				command.alu.op = ALU_ADD;
				command.alu.sub_op[`AluUnsigned] = `Enable;
				inst_name = "auipc";
				//* operands
				rd.regtype = TYPE_GPR;
				rd.addr = inst.u.rd;
				//* immediate
				imm_data.sign = `Disable;
				imm_data.shift = IMM_SHIFT12;
				imm_data.size = IMM_SIZE20;
				imm_data.data = inst.u.imm;
			end

			`RvOpLui : begin
				unit = UNIT_ALU;
				command.alu.op = ALU_ADD;
				inst_name = "lui";
				//* operands
				rd.regtype = TYPE_GPR;
				rd.addr = inst.u.rd;
				//* immediate encoding
				imm_data.sign = `Disable;
				imm_data.shift = IMM_SHIFT12;
				imm_data.size = IMM_SIZE20;
				imm_data.data = inst.u.imm;
			end

			`RvOpSystem : begin
				unit = UNIT_CSR;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.i.rd;

				case ( inst.i.funct3 )
					`RvFunct3Csrrw : begin
						command.csr.op = CSR_RW;
						inst_name = "csrrw";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE12;
						imm_data.data = inst.i.imm;
					end

					`RvFunct3Csrrs : begin
						command.csr.op = CSR_RS;
						inst_name = "csrrs";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE12;
						imm_data.data = inst.i.imm;
					end

					`RvFunct3Csrrc : begin
						command.csr.op = CSR_RC;
						inst_name = "csrrc";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE12;
						imm_data.data = inst.i.imm;
					end

					`RvFunct3Csrrwi : begin
						command.csr.op = CSR_RW;
						command.csr.sub_op[`CsrImmediate] = `Enable;
						inst_name = "csrrwi";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE5_12;
						imm_data.data = {inst.i.rs1, inst.i.imm};
					end

					`RvFunct3Csrrsi : begin
						command.csr.op = CSR_RS;
						command.csr.sub_op[`CsrImmediate] = `Enable;
						inst_name = "csrrsi";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE5_12;
						imm_data.data = {inst.i.rs1, inst.i.imm};
					end

					`RvFunct3Csrrci : begin
						command.csr.op = CSR_RC;
						command.csr.sub_op[`CsrImmediate] = `Enable;
						inst_name = "csrrci";

						imm_data.sign = `Disable;
						imm_data.shift = IMM_NO_SHIFT;
						imm_data.size = IMM_SIZE5_12;
						imm_data.data = {inst.i.rs1, inst.i.imm};
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
						inst_name = "invalid";
					end
				endcase
			end

			`RvOpFP : begin
			end

			`RvOpMadd : begin
			end

			`RvOpStoreFP : begin
			end

			`RvOpMsub : begin
			end

			`RvOpCustom0 : begin
			end

			`RvOpCustom1 : begin
			end

			`RvOpNmsub : begin
			end

			`RvOpMiscMem : begin
			end

			`RvOpAmo : begin
			end

			//*** invalid instructions
			default : begin
				invalid = `Enable;
			end
		endcase
	end

endmodule
