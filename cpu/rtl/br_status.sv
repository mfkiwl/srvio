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
`include "branch.svh"

module br_status #(
	parameter ADDR = `AddrWidth,
	parameter ROB_DEPTH = `RobDepth,
	parameter PRED_MAX = `PredMaxDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire					clk,
	input wire					reset_, 

	// fetch request
	input wire					fetch_stall_,
	input wire [ADDR-1:0]		fetch_pc,
	input wire					btb_hit,
	input wire [ADDR-1:0]		btb_addr,
	input BrInstType_t			btb_type,
	input wire					br_pred,
	input wire					ret_v,
	input wire [ADDR-1:0]		ret_pc,
	output wire [ADDR-1:0]		next_fetch_pc

	// fetch
	input wire					inst_e_,
	input wire [ADDR-1:0]		inst_pc,
	input union packed {
		RvJtype_t	jump;
		RvItype_t	jr;
		RvBtype_t	branch;	}	inst,
	output logic				inst_br_,
	output logic				inst_call_,
	output logic				inst_return_,

	// commit
	input wire					commit_e_,
	input wire [ROB-1:0]		com_rob_id,
	output wire					br_commit_,
	output wire					br_result,
	output wire					br_pred_miss_,
	output wire					jump_commit_,
	output wire					jump_call_,
	output wire					jump_return_,
	output wire					jump_miss_,
	output wire [ADDR-1:0]		com_tar_addr
);

	// TODO: クリティカルパスの解析を行い、
	//			BTBやBr Predictorのパイプライン化を考慮
	// missにはdirection/destination missと
	//		entry missの2パターンで区別しておく
	//		(commit時にはOrとって学習)
	// クリティカルパスがまずい場合
	//		immediateの算出のみ、前のサイクルに行うように調整

	//***** internal parameters
	localparam BR_STATUS = $bits(BrStatus_t);

	//***** internal registers
	//*** pipeline registers (ICache Access)
	reg [ADDR-1:0]			ic_tar_addr;
	BrInstType_t			ic_br_type;
	reg						ic_br_pred;

	//***** internal wires
	//*** fetch request
	wire [ADDR-1:0]			fetch_pc_p4;
	//*** fetch
	wire [`RvOpW-1:0]		opcode;
	wire					jump_rd_ra;
	wire					jr_rd_ra;
	wire					jr_rs1_ra;
	wire					jr_rd_rs1;
	wire [ADDR-1:0]			inst_br_target;
	wire					untracked_inst;

	//***** combinational cells
	//*** fetch request
	logic [ADDR-1:0]		pred_pc;
	logic [ADDR-1:0]		fetch_req_pc;
	//*** fetch
	//logic					inst_br_;		// output
	logic					inst_jump_;
	logic					inst_jr_;
	//logic					inst_call_;		// output
	//logic					inst_return_;	// output
	logic [`RvImmW_J-1:0]	inst_imm;
	BrInstType_t			inst_type;



	//***** assign internal
	//*** fetch request
	assign fetch_pc_p4 = fetch_pc + 4;
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
	assign untracked_inst = ( ic_br_type != inst_type );



	//***** Branch Status Buffer
	br_status_buf #(
		.ADDR		( ADDR ),
		.PRED_MAX	( PRED_MAX )
	) br_status_buf (
		.clk		( clk ),
		.reset_		( reset_ )
	);



	//***** combinational logics
	//*** select next fetch pc
	always_comb begin
		//*** select next fetch pc
		if ( btb_hit ) begin
			fetch_req_pc = pred_pc;
		end else begin
			fetch_req_pc = fetch_pc_p4;
		end

		case ( btb_type )
			BRTYPE_NONE : begin
				pred_pc = fetch_pc_p4;
			end
			BRTYPE_BRANCH : begin
				if ( br_pred == `BrTakne ) begin
					pred_pc = btb_addr;
				end else begin
					pred_pc = fetch_pc_p4;
				end
			end
			BRTYPE_JUMP, BRTYPE_CALL : begin
				pred_pc = btb_addr;
			end
			BRTYPE_RET : begin
				// ret_v is not checked ...
				pred_pc = ret_pc;
			end
		endcase
	end

	//*** branch instruction detect from fetched instruction
	always_comb begin
		inst_br_ = `Disable_;
		inst_jump_ = `Disable_;
		inst_jr_ = `Disable_;
		inst_call_ = `Disable_;
		inst_return_ = `Disable_;

		case ( opcode )
			`RvOpBranch : begin
				inst_type = BRTYPE_BRANCH;
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
					inst_type = BRTYPE_CALL;
					inst_call_ = `Enable_;
				end else begin
					inst_type = BRTYPE_JUMP;
				end
			end

			`RvOpJalr : begin
				inst_jr_ = `Enable_;
				inst_imm = 0;
				case ( {jr_rs1_ra, jr_rd_ra} )
					{`Disable, `Enable} : begin
						inst_type = BRTYPE_CALL;
						inst_call_ = `Enable_;
					end
					{`Enable, `Disable} : begin
						inst_type = BRTYPE_RET;
						inst_ret_ = `Enable_;
					end
					{`Enable, `Enable} : begin
						if ( jump_rd_rs1 ) begin
							inst_type = BRTYPE_RET;
							inst_ret_ = `Enable_;
						end else begin
							inst_type = BRTYPE_CALL;
							inst_ret_ = `Disable_;
						end
						inst_call_ = `Enable_;
					end
					default : begin
						inst_type = BRTYPE_JUMP;
					end
				endcase
			end

			default : begin
				inst_imm = 0;
				inst_type = BRTYPE_NONE;
			end
		endcase

		case ( inst_type )
		endcase
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			ic_tar_addr <= {ADDR{1'b0}};
			ic_br_type <= BRTYPE_NONE:
			ic_tar_addr <= `BrTaken;
		end else begin
			if ( fetch_stall_ == `Disable_ ) begin
				ic_tar_addr <= next_fetch_pc;
				ic_br_type <= btb_hit ? BRTYPE_NONE : btb_type;
				ic_tar_addr <= br_pred;
			end
		end
	end

endmodule
