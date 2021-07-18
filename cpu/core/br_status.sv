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
	output logic [ADDR-1:0]		next_fetch_pc,

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
	output wire					inst_invalid,

	// decode
	input wire					dec_br_,
	input wire [ROB-1:0]		dec_rob_id,

	// exe
	input wire [ROB-1:0]		exe_rob_id,
	output wire					exe_br_pred,
	output wire [ADDR-1:0]		exe_target,

	// writeback
	input wire					wb_e_,
	input wire [ROB-1:0]		wb_rob_id,
	input wire					wb_pred_miss_,
	input wire					wb_jump_miss_,
	input wire					wb_br_result,
	input wire [ADDR-1:0]		wb_tar_addr,
	output wire					wb_flush_,

	// commit
	input wire					commit_e_,
	input wire [ROB-1:0]		commit_rob_id,
	output wire					br_result,
	output wire					br_pred_miss_,
	output wire					jump_miss_,
	output logic				br_commit_,
	output logic				jump_commit_,
	output logic				jump_call_,
	output logic				jump_return_,
	output logic [ADDR-1:0]		com_tar_addr,

	output wire					pred_busy
);

	// TODO: クリティカルパスの解析を行い、
	//			BTBやBr Predictorのパイプライン化を考慮
	// TODO: クリティカルパスがまずい場合
	//		immediateの算出のみ、前のサイクルに行うように調整
	// TODO: JALRのように、ターゲットを解決できない場合、
	//	ストールするように改変

	//***** internal types
	typedef struct packed {
		logic				br_pred;
		logic [ADDR-1:0]	ft_addr;	// fall through
		logic [ADDR-1:0]	target;		// branch target
		BrInstType_t		inst_type;
	} BrStatus_t;

	typedef struct packed {
		logic				pred_miss_;
		logic				jump_miss_;
		logic				br_result;
		logic [ADDR-1:0]	target;
	} BrResult_t;

	//***** internal parameters
	localparam BR_STATUS = $bits(BrStatus_t);
	localparam BR_RESULT = $bits(BrResult_t);
	localparam IDX = $clog2(PRED_MAX);

	//***** internal registers
	//*** pipeline register (Fetch Request)
	reg [ADDR-1:0]			fetch_tar_addr;
	BrInstType_t			fetch_br_type;
	reg						fetch_br_pred;
	//*** pipeline registers (ICache Access)
	reg [ADDR-1:0]			ic_tar_addr;
	BrInstType_t			ic_br_type;
	reg						ic_br_pred;

	//***** internal wires
	//*** fetch request
	wire [ADDR-1:0]			fetch_pc_p4;
	//*** fetch
	wire [`RvOpW-1:0]		opcode;
	wire [ADDR-1:0]			inst_pc_p4;
	wire					jump_rd_ra;
	wire					jr_rd_ra;
	wire					jr_rs1_ra;
	wire					jr_rd_rs1;
	wire					inst_br_pred;
	wire [`RvImmW_J:0]		inst_br_offset;
	wire [ADDR-1:0]			inst_br_target;
	wire					inst_valid;
	wire					untracked_branch;
	wire					status_add_;
	BrStatus_t				inst_br_status;
	//*** exe
	wire [IDX-1:0]			exe_st_idx;
	BrStatus_t				exe_status;
	//*** writeback
	wire					wb_br_jump_;
	wire					wb_match_;
	wire [IDX-1:0]			wb_st_idx;
	BrStatus_t				wb_status;
	BrResult_t				wb_result;
	//*** commit
	wire					status_del_;
	BrStatus_t				com_status;
	wire [IDX-1:0]			com_st_idx;
	BrResult_t				com_result;

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
	logic [ADDR-1:0]		target_addr;
	//*** commit
	BrInstType_t			com_type;



	//***** assign output
	assign br_result = com_result.br_result;
	assign br_pred_miss_ = com_result.pred_miss_;
	assign jump_miss_ = com_result.jump_miss_;
	//assign wb_flush_ = wb_pred_miss_ && wb_jump_miss_;
	//assign wb_flush_ = wb_match_;
	assign wb_flush_ = wb_match_ || ( wb_pred_miss_ && wb_jump_miss_ ); 
	assign inst_invalid = untracked_branch;



	//***** assign internal
	//*** fetch request
	assign fetch_pc_p4 = fetch_pc + 4;
	assign inst_pc_p4 = inst_pc + 4;

	//*** fetch
	assign opcode = inst[`RvOp];
	assign jump_rd_ra = 
		( inst.jump.rd == `RvRaReg || inst.jump.rd == `RvT0Reg );
	assign jr_rd_ra = 
		( inst.jr.rd == `RvRaReg || inst.jr.rd == `RvT0Reg );
	assign jr_rs1_ra = 
		( inst.jr.rs1 == `RvRaReg || inst.jr.rs1 == `RvT0Reg );
	assign jr_rd_rs1 = ( inst.jr.rd == inst.jr.rs1 );
	assign inst_br_offset = {inst_imm, 1'b0};
	assign inst_br_target = inst_pc + `SignExt(ADDR, inst_br_offset);
	assign status_add_ = ( inst_br_ && inst_jump_ && inst_jr_ );
	assign inst_br_pred = ( untracked_branch ) ? `DefaultPred : ic_br_pred;
	assign inst_br_status = '{ 
		br_pred : inst_br_pred,
		ft_addr : inst_pc_p4,
		target : target_addr,
		inst_type : inst_type
	};
	//* validate prediction
	assign inst_valid = ( ic_br_type == inst_type );
	assign untracked_branch =
		( ic_br_type != inst_type ) && ( inst_type != BRTYPE_NONE );

	//*** exe
	assign exe_br_pred = exe_status.br_pred;
	assign exe_target = exe_status.target;

	//*** writeback
	assign wb_match_ = wb_br_jump_ || wb_e_;
	assign wb_result = '{
		pred_miss_ : wb_pred_miss_,
		jump_miss_ : wb_jump_miss_,
		br_result : wb_br_result,
		target : wb_tar_addr
	};

	//*** commit
	//assign status_del_ = commit_e_ || ( br_commit_ && jump_commit_ );
	assign status_del_ = br_commit_ && jump_commit_;
	assign com_type = com_status.inst_type;



	//***** Branch Status Buffer
	br_status_buf #(
		.DATA		( BR_STATUS ),
		.DEPTH		( PRED_MAX )
	) br_status_buf (
		.clk		( clk ),
		.reset_		( reset_ ),

		.we_		( status_add_ ),
		.wd			( inst_br_status ),

		.re_		( status_del_ ),
		.rd			( com_status ),

		.exe_st_idx	( exe_st_idx ),
		.exe_status	( exe_status ),
		.wb_st_idx	( wb_st_idx ),
		.wb_flush_	( wb_flush_ ),
		.wb_status	( wb_status ),

		.busy		( pred_busy )
	);

	br_rob_id_buf #(
		.ROB_DEPTH	( ROB_DEPTH ),
		.DEPTH		( PRED_MAX )
	) br_rob_id_buf (
		.clk		( clk ),
		.reset_		( reset_ ),

		.we_		( dec_br_ ),
		.wd			( dec_rob_id ),
		.re_		( status_del_ ),
		.ridx		( com_st_idx ),

		.exe_rob_id	( exe_rob_id ),
		.wb_rob_id	( wb_rob_id ),
		.wb_flush_	( wb_flush_ ),
		.exe_idx	( exe_st_idx ),
		.wb_match_	( wb_br_jump_ ),
		.wb_idx		( wb_st_idx )
	);

	regfile #(
		.DATA	( BR_RESULT ),
		.ADDR	( IDX ),
		.READ	( 1 ),
		.WRITE	( 1 )
	) br_result_reg (
		.clk	( clk ),
		.reset_	( reset_ ),
		.raddr	( com_st_idx ),
		.waddr	( wb_st_idx ),
		.we_	( wb_match_ ),
		.wdata	( wb_result ),
		.rdata	( com_result )
	);



	//***** combinational logics
	//*** select next fetch pc
	always_comb begin
		//*** select next fetch pc
		case ( btb_type )
			BRTYPE_NONE : begin
				pred_pc = fetch_pc_p4;
			end
			BRTYPE_BRANCH : begin
				if ( br_pred == `BrTaken ) begin
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
			default : begin
				pred_pc = 0;
			end
		endcase

		if ( btb_hit ) begin
			fetch_req_pc = pred_pc;
		end else begin
			fetch_req_pc = fetch_pc_p4;
		end
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
					{`RvImmW_J-`RvImmW_B{inst.branch.imm3}},
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
						inst_return_ = `Enable_;
					end
					{`Enable, `Enable} : begin
						if ( jr_rd_rs1 ) begin
							inst_type = BRTYPE_CALLRET;
							inst_return_ = `Enable_;
						end else begin
							inst_type = BRTYPE_CALL;
							inst_return_ = `Disable_;
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

		//*** Branch target address
		case ( opcode )
			`RvOpJal, `RvOpBranch : begin
				target_addr = inst_br_target;
			end

			`RvOpJalr : begin
				if ( ic_br_type == BRTYPE_NONE ) begin
					// execute fall-through path on BTB miss
					//	( prefetch fall-through path )
					target_addr = inst_pc_p4;
				end else begin
					// record jump target read from BTB
					//target_addr = ic_tar_addr; ( TODO: maybe inst_pc is enough ?? )
					target_addr = inst_pc;
				end
			end

			default : begin
				target_addr = 0;
			end
		endcase

		//*** Next fetch pc
		if ( ( wb_match_ || wb_jump_miss_ ) == `Enable_ ) begin
			next_fetch_pc = wb_tar_addr;
		end else if ( ( wb_match_ || wb_pred_miss_ ) == `Enable_ ) begin
			if ( wb_br_result == `BrTaken ) begin
				next_fetch_pc = wb_status.target;
			end else begin
				next_fetch_pc = wb_status.ft_addr;
			end
		end else if ( fetch_stall_ == `Enable_ ) begin
			next_fetch_pc = fetch_pc;
		end else if ( untracked_branch ) begin
			// branch : restart fetch from taken path (`DefaultPred)
			// jump : restart fech from target
			// jumpr : stall
			next_fetch_pc = inst_br_target;
		end else begin
			next_fetch_pc = fetch_req_pc;
		end
	end

	//*** instruction commit
	always_comb begin
		//* commit
		br_commit_ = `Disable_;
		jump_commit_ = `Disable_;
		jump_call_ = `Disable_;
		jump_return_ = `Disable_;
		com_tar_addr = 0;

		case ( com_type )
			BRTYPE_BRANCH : begin
				br_commit_ = commit_e_;
				com_tar_addr = com_status.target;
			end

			BRTYPE_JUMP : begin
				jump_commit_ = commit_e_;
				com_tar_addr = com_result.target;
			end

			BRTYPE_CALL : begin
				jump_commit_ = commit_e_;
				jump_call_ = commit_e_;
				com_tar_addr = com_result.target;
			end

			BRTYPE_RET : begin
				jump_commit_ = commit_e_;
				jump_return_ = commit_e_;
				com_tar_addr = com_result.target;
			end

			BRTYPE_CALLRET : begin
				jump_commit_ = commit_e_;
				jump_call_ = commit_e_;
				jump_return_ = commit_e_;
				com_tar_addr = com_result.target;
			end
		endcase
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			fetch_tar_addr <= {ADDR{1'b0}};
			fetch_br_type <= BRTYPE_NONE;
			fetch_br_pred <= `BrTaken;
			ic_tar_addr <= {ADDR{1'b0}};
			ic_br_type <= BRTYPE_NONE;
			ic_br_pred <= `BrTaken;
		end else begin
			if ( fetch_stall_ == `Disable_ ) begin
				fetch_tar_addr <= next_fetch_pc;
				fetch_br_type <= btb_hit ? btb_type : BRTYPE_NONE;
				fetch_br_pred <= br_pred;
				ic_tar_addr <= fetch_tar_addr;
				ic_br_type <= fetch_br_type;
				ic_br_pred <= fetch_br_pred;
			end
		end
	end

endmodule
