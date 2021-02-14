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
`include "alu.svh"
`include "mem.svh"
`include "decode.svh"
`include "rv_opcodes.svh"

module decoder  #(
	parameter ADDR = `AddrWidth,
	parameter DATA = `DataWidth
)(
	input wire					clk,
	input wire					reset_,

	input wire					inst_e_,
	input wire					is_full,
	input wire [ADDR-1:0]		inst_pc,
	input union packed {
		RvRtype_t		r;
		RvItype_t		i;
		RvIS32type_t	is32;
		RvIS64type_t	is64;
		RvStype_t		s;
		RvUtype_t		u;
		RvJtype_t		j;
		RvBtype_t		b; }	inst,

	output wire					stall,
	output wire					dec_e_out_,
	output RegFile_t			rs1_out,
	output RegFile_t			rs2_out,
	output RegFile_t			rd_out,
	output wire					invalid_out,
	output ImmData_t			imm_data_out,
	output ExeUnit_t			unit_out,
	output OpCommand_t			command_out
);

	//***** internal wires
	wire [`RvOpW-1:0]		opcode;

	//***** pipeline register
	RegFile_t				rs1_p;
	RegFile_t				rs2_p;
	RegFile_t				rd_p;
	reg						invalid_p;
	ImmData_t				imm_data_p;
	ExeUnit_t				unit_p;
	OpCommand_t				command_p;
	reg						inst_e_p_;

	//***** combinational cells
	RegFile_t				rs1;
	RegFile_t				rs2;
	RegFile_t				rd;
	logic					invalid;
	ImmData_t				imm_data;
	ExeUnit_t				unit;
	OpCommand_t				command;



	//***** assign output
	assign stall = is_full && !inst_e_p_;
	assign dec_e_out_ = inst_e_p_;
	assign rs1_out = rs1_p;
	assign rs2_out = rs2_p;
	assign rd_out = rd_p;
	assign invalid_out = invalid_p;
	assign imm_data_out = imm_data_p;
	assign unit_out = unit_p;
	assign command_out = command_p;



	//***** assign internal
	assign opcode = inst[`RvOp];



	//***** combinational logics
	always_comb begin
		//*** default value
		rs1 = 0;
		rs2 = 0;
		rd = 0;
		invalid = `Disable;
		imm_data = 0;
		unit = UNIT_NOP;
		command = 0;

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
					end

					`RvFunct3Half : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
					end

					`RvFunct3Word : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeWord;
					end

					`RvFunct3Double : begin
						command.mem.sub_op[`MemUnsigned] = `Disable;
						command.mem.sub_op[`MemSize] = `MemSizeDouble;
					end

					`RvFunct3Ubyte : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeByte;
					end

					`RvFunct3Uhalf : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
					end

					`RvFunct3Uword : begin
						command.mem.sub_op[`MemUnsigned] = `Enable;
						command.mem.sub_op[`MemSize] = `MemSizeWord;
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
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
					end

					`RvFunct3Half : begin
						command.mem.sub_op[`MemSize] = `MemSizeHalf;
					end

					`RvFunct3Word : begin
						command.mem.sub_op[`MemSize] = `MemSizeWord;
					end

					`RvFunct3Double : begin
						command.mem.sub_op[`MemSize] = `MemSizeDouble;
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
					end
				endcase
			end

			`RvOpBranch : begin
				//* (branch target is calculated at fetch_stage)

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
					end

					`RvFunct3Bne : begin
						command.alu.sub_op[`AluCompLt] = `Disable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
					end

					`RvFunct3Blt : begin
						command.alu.sub_op[`AluUnsigned] = `Disable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Disable;
					end

					`RvFunct3Bge : begin
						command.alu.sub_op[`AluUnsigned] = `Disable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
					end

					`RvFunct3Bltu : begin
						command.alu.sub_op[`AluUnsigned] = `Enable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Disable;
					end

					`RvFunct3Bgeu : begin
						command.alu.sub_op[`AluUnsigned] = `Enable;
						command.alu.sub_op[`AluCompLt] = `Enable;
						command.alu.sub_op[`AluCompNeg] = `Enable;
					end

					default : begin
						unit = UNIT_NOP;
						invalid = `Enable;
					end
				endcase
			end

			`RvOpJalr : begin
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
					end

					`RvFunct3Sll : begin
						command.alu.op = ALU_SHIFT;
						command.alu.sub_op[`AluRight] = `Disable;
						command.alu.sub_op[`AluArith] = `Disable;
						if ( DATA == 32 ) begin : RV32
							imm_data.data = inst.is32.shamt;
						end else begin : RV64
							imm_data.data = inst.is64.shamt;
						end
					end
				endcase
			end

			`RvOpR : begin
				//* execution unit decode
				unit = UNIT_ALU;

				//* operands decode
				rs1.regtype = TYPE_GPR;
				rs1.addr = inst.r.rs1;
				rs2.regtype = TYPE_GPR;
				rs2.addr = inst.r.rs2;
				rd.regtype = TYPE_GPR;
				rd.addr = inst.r.rd;

				case ( inst.r.funct3 )
					`RvFunct3AddSub : begin
						command.alu.op = ALU_ADD;
						unique if ( inst.r.funct7 == `RvFunct7Add ) begin
							command.alu.sub_op[`AluSub] = `Disable;
						end else if ( inst.r.funct7 == `RvFunct7Sub ) begin
							command.alu.sub_op[`AluSub] = `Enable;
						end else begin
							//*** invalid funct7 code
							unit = UNIT_NOP;
							invalid = `Enable;
						end
					end

					`RvFunct3Sll : begin
						command.alu.op = ALU_SHIFT;
						command.alu.sub_op[`AluRight] = `Disable;
						command.alu.sub_op[`AluArith] = `Disable;
					end

					`RvFunct3Slt : begin
						command.alu.op = ALU_COMP;
						command.alu.sub_op[`AluCompLt] = `Enable;
					end

					`RvFunct3Sltu : begin
						command.alu.op = ALU_COMP;
						command.alu.sub_op[`AluUnsigned] = `Enable;
						command.alu.sub_op[`AluCompLt] = `Enable;
					end

					`RvFunct3Xor : begin
						command.alu.op = ALU_LOGIC;
						command.alu.sub_op[`AluLogicOp] = `AluLogicXor;
					end

					`RvFunct3SraSrl : begin
						command.alu.op = ALU_SHIFT;
						command.alu.sub_op[`AluRight] = `Enable;
						unique if ( inst.r.funct7 == `RvFunct7Srl ) begin
							command.alu.sub_op[`AluArith] = `Disable;
						end else if ( inst.r.funct7 == `RvFunct7Sra ) begin
							command.alu.sub_op[`AluArith] = `Enable;
						end else begin
							//*** invalid funct7 code
							unit = UNIT_NOP;
							invalid = `Enable;
						end
					end

					`RvFunct3Or : begin
						command.alu.op = ALU_LOGIC;
						command.alu.sub_op[`AluLogicOp] = `AluLogicOr;
					end

					`RvFunct3And : begin
						command.alu.op = ALU_LOGIC;
						command.alu.sub_op[`AluLogicOp] = `AluLogicAnd;
					end
				endcase
			end

			`RvOpAuipc : begin
				unit = UNIT_ALU;
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



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			inst_e_p_ <= `Disable_;
			rs1_p <= 0;
			rs2_p <= 0;
			rd_p <= 0;
			invalid_p <= `Disable;
			imm_data_p <= 0;
			unit_p <= UNIT_NOP;
			command_p <= 0;
		end else begin
			if ( stall == `Disable ) begin
				inst_e_p_ <= inst_e_;
				rs1_p <= rs1;
				rs2_p <= rs2;
				rd_p <= rd;
				invalid_p <= invalid;
				imm_data_p <= imm_data;
				unit_p <= unit;
				command_p <= command;
			end
		end
	end

endmodule
