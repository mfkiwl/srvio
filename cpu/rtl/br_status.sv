/*
* <br_status.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "rv_opcodes.svh"
`include "rv_regs.svh"

module br_status #(
	parameter ADDR = `AddrWidth 
)(
	input wire					clk,
	input wire					reset_, 

	// fetch request
	input wire [ADDR-1:0]		fetch_pc,

	// fetch
	input wire					inst_e_,
	input wire [ADDR-1:0]		inst_pc,
	input union packed {
		RvJtype_t	jump;
		RvItype_t	jr;
		RvBtype_t	branch;	}	inst,
);
	//TODO: Fetch時に検出できなかったbranchの検出を行う
	//TODO: BTBに入れ込んだ命令フィールドを見て、
	//		Branch Predictionの使用するか、
	//		Return Address StackのPush/Popをするか等判断

	//***** internal wires
	//*** fetch
	wire [`RvOpW-1:0]		opcode;
	wire					jump_rd_ra;
	wire					jr_rd_ra;
	wire					jr_rs1_ra;
	wire					jr_rd_rs1;
	wire [ADDR-1:0]			inst_br_target;

	//***** combinational cells
	logic					inst_br_;
	logic					inst_jump_;
	logic					inst_jr_;
	logic					inst_call_;
	logic					inst_return_;
	logic [`RvImmW_J-1:0]	inst_imm;



	//***** assign internal
	//*** fetch
	assign opcode = inst[`RvOp];
	assign jump_rd_ra = 
		( inst.jump.rd == `RvRaReg || inst.jump.rd == `RvT0Reg );
	assign jr_rd_ra = 
		( inst.jr.rd == `RvRaReg || inst.jr.rd == `RvT0Reg );
	assign jr_rs1_ra = 
		( inst.jr.rs1 == `RvRaReg || inst.jr.rs1 == `RvT0Reg );
	assign jr_rd_rs1 = ( inst.jr.rd == inst.jr.rs1 );
	assign inst_br_target = inst_pc + ( inst_imm << 1 );



	//***** combinational logics
	always_comb begin
		inst_br_ = `Disable_;
		inst_jump_ = `Disable_;
		inst_jr_ = `Disable_;
		inst_call_ = `Disable_;
		inst_return_ = `Disable_;

		case ( opcode )
			`RvOpBranch : begin
				inst_br_ = `Enable_;
				inst_imm = {
					{`RvImmW_J-`RvImmW_B{1'b0}},
					inst.branch.imm3,
					inst.branch.imm2,
					inst.branch.imm1,
					inst.branch.imm0
				};
			end

			`RvOpJal : begin
				inst_jump_ = `Enable_;
				inst_imm = {
					inst.jump.imm3,
					inst.jump.imm2,
					inst.jump.imm1,
					inst.jump.imm0
				};
				if ( inst.jump.rd == `RvRaReg ||
						inst.jump.rd == `RvT0Reg ) begin
					inst_call_ = `Enable_;
				end
			end

			`RvOpJalr : begin
				inst_jr_ = `Enable_;
				inst_imm = 0;
				case ( {jr_rs1_ra, jr_rd_ra} )
					{`Disable, `Enable} : begin
						inst_call_ = `Enable_;
					end
					{`Enable, `Disable} : begin
						inst_ret_ = `Enable_;
					end
					{`Enable, `Enable} : begin
						inst_ret_ = !jump_rd_rs1;
						inst_call_ = `Enable_;
					end
				endcase
			end

			default : begin
				inst_imm = 0;
			end
		endcase
	end

endmodule
