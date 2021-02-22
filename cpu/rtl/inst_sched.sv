/*
* <inst_sched.sv>
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
`include "issue.svh"
`include "exe.svh"

module inst_sched #(
	parameter IQ_DEPTH = `IqDepth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter IQ = $clog2(IQ_DEPTH),
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				add_entry_,
	input ExeUnit_t			dec_unit,
	input RegFile_t			ren_rd,
	input RegFile_t			ren_rs1,
	input wire				ren_rs1_ready,	// rob entry is ready
	input RegFile_t			ren_rs2,
	input wire				ren_rs2_ready,	// rob entry is ready
	input wire [IQ-1:0]		dec_iq_id,

	input ExeBusy_t			exe_busy,
	input wire				wb_e_,
	input RegFile_t			wb_rd,

	input wire				commit_e_,
	input RegFile_t			commit_rd,
	input wire [ROB-1:0]	commit_rob_id,

	output wire				issue_e_,
	output wire [IQ-1:0]	issue_iq_id,
	output RegFile_t		issue_rd,
	output RegFile_t		issue_rs1,
	output RegFile_t		issue_rs2,
	output ExeUnit_t		issue_unit
);

	//***** internal types
	typedef struct packed {
		logic [IQ-1:0]	iq_id;
		RegFile_t		rd;
		RegFile_t		rs1;
		RegFile_t		rs2;
		ExeUnit_t		unit;
	} InstStat_t;

	//***** internal parameters
	localparam INST_STAT = $bits(InstStat_t);

	//***** internal registers
	InstStat_t [IQ_DEPTH-1:0]			stat_table;
	RegStat_t [IQ_DEPTH-1:0]			rs1_stat;
	reg [IQ_DEPTH-1:0][`ExeLatCnt]		rs1_cnt;
	RegStat_t [IQ_DEPTH-1:0]			rs2_stat;
	reg [IQ_DEPTH-1:0][`ExeLatCnt]		rs2_cnt;
	reg [IQ_DEPTH-1:0]					valid;

	//***** internal wires
	//*** new entry
	InstStat_t							new_stat_entry;
	//*** issue
	InstStat_t							issue_stat;
	wire [IQ_DEPTH-1:0]					issue_ready_;
	wire [IQ_DEPTH-1:0]					issue_vec_;
	//tmptmptmtpmptmp
	assign issue_vec_ = '1;

	//***** combinational cells
	logic [IQ_DEPTH-1:0]				q_tail;
	logic [IQ_DEPTH-1:0]				eq_head;	// empty queue head
	logic [IQ_DEPTH-1:0]				shift;
	//*** instruction status
	logic [IQ_DEPTH-1:0]				inst_busy;
	logic [IQ_DEPTH-1:0]				csr_inst;
	logic [IQ_DEPTH-1:0]				csr_stop;
	//*** new entry
	RegStat_t							new_rs1_stat;
	logic [`ExeLatCnt]					new_rs1_cnt;
	RegStat_t							new_rs2_stat;
	logic [`ExeLatCnt]					new_rs2_cnt;
	//*** update entry
	InstStat_t [IQ_DEPTH:0]				ext_stat_table;
	RegStat_t [IQ_DEPTH:0]				ext_rs1_stat;
	logic [IQ_DEPTH:0][`ExeLatCnt]		ext_rs1_cnt;
	RegStat_t [IQ_DEPTH:0]				ext_rs2_stat;
	logic [IQ_DEPTH:0][`ExeLatCnt]		ext_rs2_cnt;
	logic [IQ_DEPTH:0]					ext_valid;
	InstStat_t [IQ_DEPTH-1:0]			next_stat_table;
	RegStat_t [IQ_DEPTH-1:0]			next_rs1_stat;
	logic [IQ_DEPTH-1:0][`ExeLatCnt]	next_rs1_cnt;
	RegStat_t [IQ_DEPTH-1:0]			next_rs2_stat;
	logic [IQ_DEPTH-1:0][`ExeLatCnt]	next_rs2_cnt;
	logic [IQ_DEPTH-1:0]				next_valid;



	//***** assign output
	//assign issue_e_ = &issue_vec_;
	assign issue_e_ = &issue_ready_;
	assign issue_iq_id = issue_stat.iq_id;
	assign issue_rd = issue_stat.rd;
	assign issue_rs1 = issue_stat.rs1;
	assign issue_rs2 = issue_stat.rs2;
	assign issue_unit = issue_stat.unit;



	//***** assign internal
	assign new_stat_entry = '{
		iq_id	: dec_iq_id,
		rd		: ren_rd,
		rs1		: ren_rs1,
		rs2		: ren_rs2,
		unit	: dec_unit
	};
	//assign ext_stat_table = {{INST_STAT{1'b0}}, stat_table};
	assign ext_stat_table[IQ_DEPTH] = 0;
	assign ext_rs1_stat[IQ_DEPTH] = REG_READY;
	assign ext_rs1_cnt[IQ_DEPTH] = 0;
	assign ext_rs2_stat[IQ_DEPTH] = REG_READY;
	assign ext_rs2_cnt[IQ_DEPTH] = 0;
	assign ext_valid = {`Disable, valid};

	generate
		genvar gi;
		for ( gi = 0; gi < IQ_DEPTH; gi = gi + 1 ) begin : LP_shift
			wire [gi:0]		vec_;
			//assign vec_ = issue_vec_[gi:0];
			assign vec_ = issue_ready_[gi:0];
			assign shift[gi] = !( &vec_[gi:0] );
		end

		for ( gi = 0; gi < IQ_DEPTH; gi = gi + 1 ) begin : LP_csr
			assign csr_inst[gi] = ( issue_stat.unit == UNIT_CSR );

			if ( gi == 0 ) begin : IF_head
				assign csr_stop[gi] = `Disable;
			end else begin : IF_middle
				assign csr_stop[gi] = | csr_inst[gi-1:0];
			end
		end
	endgenerate

	//*** select instruction status
	wire				dummy_v;
	wire [IQ_DEPTH-1:0]	dummy_pos;
	selector #(
		.BIT_MAP	( `Enable ),
		.DATA		( INST_STAT ),
		.IN			( IQ_DEPTH ),
		.ACT		( `Low ),
		.MSB		( `Disable )
	) sel (
		.in			( stat_table ),
		//.sel		( issue_vec_ ),
		.sel		( issue_ready_ ),
		.valid		( dummy_v ),
		.pos		( dummy_pos ),
		.out		( issue_stat )
	);



	//***** combinational logics
	int ci;
	always_comb begin
		//*** check functional unit status
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			case ( stat_table[ci].unit )
				UNIT_ALU : inst_busy[ci] = exe_busy.alu;
				UNIT_DIV : inst_busy[ci] = exe_busy.div;
				UNIT_FPU : inst_busy[ci] = exe_busy.fpu;
				UNIT_FDIV : inst_busy[ci] = exe_busy.fdiv;
				UNIT_CSR : inst_busy[ci] = exe_busy.csr;
				UNIT_MEM : inst_busy[ci] = exe_busy.mem;
				default : inst_busy[ci] = `Disable;
			endcase
		end

		//*** source operand status for a new entry
		new_rs1_cnt = check_reg_cnt(dec_unit);
		new_rs2_cnt = check_reg_cnt(dec_unit);
		new_rs1_stat = check_reg_stat(
			ren_rs1, 
			ren_rs1_ready,
			new_rs1_cnt, 
			dec_unit,
			issue_e_,
			issue_rd,
			issue_unit,
			wb_e_,
			wb_rd
		);
		new_rs2_stat = check_reg_stat(
			ren_rs2, 
			ren_rs2_ready,
			new_rs2_cnt, 
			dec_unit,
			issue_e_,
			issue_rd,
			issue_unit,
			wb_e_,
			wb_rd
		);

		//*** source operand status for queued entries
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			ext_rs1_cnt[ci] =
				update_reg_cnt(
					stat_table[ci].rs1, 
					rs1_stat[ci],
					rs1_cnt[ci],
					stat_table[ci].unit,
					issue_e_,
					issue_rd,
					issue_unit,
					inst_busy[ci]
				);

			ext_rs2_cnt[ci] =
				update_reg_cnt(
					stat_table[ci].rs2, 
					rs2_stat[ci],
					rs2_cnt[ci],
					stat_table[ci].unit,
					issue_e_,
					issue_rd,
					issue_unit,
					inst_busy[ci]
				);

			ext_rs1_stat[ci] = 
				update_reg_stat(
					stat_table[ci].rs1, 
					rs1_stat[ci], 
					ext_rs1_cnt[ci],
					stat_table[ci].unit,
					issue_e_,
					issue_rd,
					issue_unit,
					wb_e_,
					wb_rd
				);

			ext_rs2_stat[ci] = 
				update_reg_stat(
					stat_table[ci].rs2, 
					rs2_stat[ci], 
					ext_rs2_cnt[ci],
					stat_table[ci].unit,
					issue_e_,
					issue_rd,
					issue_unit,
					wb_e_,
					wb_rd
				);
		end

		//*** check queue position
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			if ( ci == 0 ) begin
				eq_head[0] = !valid[0];
			end else begin
				eq_head[ci] = valid[ci] ^ valid[ci-1];
			end

			if ( ci == IQ_DEPTH - 1 ) begin
				q_tail[IQ_DEPTH-1] = valid[IQ_DEPTH-1];
			end else begin
				q_tail[ci] = valid[ci] ^ valid[ci+1];
			end
		end

		//*** update rs1 and rs2 on instruction commits
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			ext_stat_table[ci] = stat_table[ci];
			if ( !commit_e_ && 
				( stat_table[ci].rs1.regtype == TYPE_ROB ) &&
				( stat_table[ci].rs1.addr[ROB-1:0] == commit_rob_id ) ) begin
				ext_stat_table[ci].rs1 = commit_rd;
			end
			if ( !commit_e_ && 
				( stat_table[ci].rs2.regtype == TYPE_ROB ) &&
				( stat_table[ci].rs2.addr[ROB-1:0] == commit_rob_id ) ) begin
				ext_stat_table[ci].rs2 = commit_rd;
			end
		end

		//*** update new entries
		for ( ci = 0; ci < IQ_DEPTH; ci = ci + 1 ) begin
			case ( {eq_head[ci], q_tail[ci]} )
				{`Disable, `Enable} : begin
					case ( {add_entry_, shift[ci]} )
						{`Disable_, `Enable} : begin
							next_stat_table[ci] = ext_stat_table[ci+1];
							next_rs1_stat[ci] = ext_rs1_stat[ci+1];
							next_rs1_cnt[ci] = ext_rs1_cnt[ci+1];
							next_rs2_stat[ci] = ext_rs2_stat[ci+1];
							next_rs2_cnt[ci] = ext_rs2_cnt[ci+1];
							next_valid[ci] = ext_valid[ci+1];
						end
						{`Enable_, `Enable} : begin
							next_stat_table[ci] = new_stat_entry;
							next_rs1_stat[ci] = new_rs1_stat;
							next_rs1_cnt[ci] = new_rs1_cnt;
							next_rs2_stat[ci] = new_rs2_stat;
							next_rs2_cnt[ci] = new_rs2_cnt;
							next_valid[ci] = `Enable;
						end
						default : begin
							// {Enable_, Disable}, {Disable_, Disable}
							next_stat_table[ci] = ext_stat_table[ci];
							next_rs1_stat[ci] = ext_rs1_stat[ci];
							next_rs1_cnt[ci] = ext_rs1_cnt[ci];
							next_rs2_stat[ci] = ext_rs2_stat[ci];
							next_rs2_cnt[ci] = ext_rs2_cnt[ci];
							next_valid[ci] = ext_valid[ci];
						end
					endcase
				end

				{`Enable, `Disable} : begin
					case ( {add_entry_, shift[ci]} )
						{`Enable_, `Disable} : begin
							next_stat_table[ci] = new_stat_entry;
							next_rs1_stat[ci] = new_rs1_stat;
							next_rs1_cnt[ci] = new_rs1_cnt;
							next_rs2_stat[ci] = new_rs2_stat;
							next_rs2_cnt[ci] = new_rs2_cnt;
							next_valid[ci] = `Enable;
						end
						default : begin
							// {`Disable_, *}, {`Enable_, `Enable_}
							next_stat_table[ci] = ext_stat_table[ci];
							next_rs1_stat[ci] = ext_rs1_stat[ci];
							next_rs1_cnt[ci] = ext_rs1_cnt[ci];
							next_rs2_stat[ci] = ext_rs2_stat[ci];
							next_rs2_cnt[ci] = ext_rs2_cnt[ci];
							next_valid[ci] = ext_valid[ci];
						end
					endcase
				end

				default : begin
					if ( shift[ci] ) begin
						next_stat_table[ci] = ext_stat_table[ci+1];
						next_rs1_stat[ci] = ext_rs1_stat[ci+1];
						next_rs1_cnt[ci] = ext_rs1_cnt[ci+1];
						next_rs2_stat[ci] = ext_rs2_stat[ci+1];
						next_rs2_cnt[ci] = ext_rs2_cnt[ci+1];
						next_valid[ci] = ext_valid[ci+1];
					end else begin
						next_stat_table[ci] = ext_stat_table[ci];
						next_rs1_stat[ci] = ext_rs1_stat[ci];
						next_rs1_cnt[ci] = ext_rs1_cnt[ci];
						next_rs2_stat[ci] = ext_rs2_stat[ci];
						next_rs2_cnt[ci] = ext_rs2_cnt[ci];
						next_valid[ci] = ext_valid[ci];
					end
				end
			endcase
		end
	end

	//*** check register count
	function [`ExeLatCnt] check_reg_cnt (
		input ExeUnit_t		unit
	);
		case ( unit )
			UNIT_ALU : check_reg_cnt = `ALU_LATENCY;
			UNIT_DIV : check_reg_cnt = `DIV_LATENCY;
			UNIT_FPU : check_reg_cnt = `FPU_LATENCY;
			UNIT_FDIV : check_reg_cnt = `FDIV_LATENCY;
			UNIT_CSR : check_reg_cnt = `CSR_LATENCY;
			UNIT_MEM : check_reg_cnt = `MEM_LATENCY;
			default : check_reg_cnt = 0;
		endcase
	endfunction

	//*** update register count
	function [`ExeLatCnt] update_reg_cnt (
		input RegFile_t		rs,
		input RegStat_t		rs_stat,
		input [`ExeLatCnt]	rs_cnt,
		input ExeUnit_t		unit,
		input				issue_e_,
		input RegFile_t		issue_rd,
		input ExeUnit_t		issue_unit,
		input				inst_busy
	);

		//* internal variables
		RegType_t			rs_type;
		reg [ROB-1:0]		rs_addr;
		RegType_t			i_rd_type;
		reg [ROB-1:0]		i_rd_addr;
		reg					issue_match;
		reg					same_unit;
		reg					cnt0;
		reg [`ExeLatCnt]	next_cnt;

		rs_type = rs.regtype;
		rs_addr = rs.addr[ROB-1:0];
		i_rd_type = issue_rd.regtype;
		i_rd_addr = issue_rd.addr[ROB-1:0];
		issue_match = 
			!issue_e_ &&
			( rs_type == i_rd_type ) &&
			( rs_addr == i_rd_addr );
		same_unit = ( unit == issue_unit );
		cnt0 = ( rs_cnt == 0 );
		next_cnt = ( cnt0 || inst_busy ) ? rs_cnt : rs_cnt - 1;

		if ( rs_stat == REG_WAIT_EXE ) begin
			update_reg_cnt = next_cnt;
		end else begin
			update_reg_cnt = rs_cnt;
		end

	endfunction

	//*** check register status
	function RegStat_t check_reg_stat (
		input RegFile_t		rs,
		input				rs_ready,
		input [`ExeLatCnt]	rs_cnt,
		input ExeUnit_t		unit,
		input				issue_e_,
		input RegFile_t		issue_rd,
		input ExeUnit_t		issue_unit,
		input				wb_e_,
		input RegFile_t		wb_rd
	);

		//* internal variables
		RegType_t			rs_type;
		reg [ROB-1:0]		rs_addr;
		RegType_t			i_rd_type;
		reg [ROB-1:0]		i_rd_addr;
		reg					issue_match;
		reg					same_unit;
		RegType_t			wb_rd_type;
		reg [ROB-1:0]		wb_rd_addr;
		reg					wb_match;
		reg					reg_ready;
		reg					cnt0;

		rs_type = rs.regtype;
		rs_addr = rs.addr[ROB-1:0];
		i_rd_type = issue_rd.regtype;
		i_rd_addr = issue_rd.addr[ROB-1:0];
		issue_match = 
			!issue_e_ &&
			same_unit &&
			( rs_type == i_rd_type ) &&
			( rs_addr == i_rd_addr );
		same_unit = ( unit == issue_unit );
		wb_rd_type = wb_rd.regtype;
		wb_rd_addr = wb_rd.addr[ROB-1:0];
		wb_match =
			!wb_e_ &&
			( rs_type == wb_rd_type ) &&
			( rs_addr == wb_rd_addr );
		reg_ready = rs_ready || wb_match;
		cnt0 = ( rs_cnt == 0 );


		if ( rs.regtype == TYPE_ROB ) begin
			case ( {issue_match, reg_ready} )
				{`Disable, `Disable} : begin
					check_reg_stat = REG_WAIT;
				end
				{`Enable, `Disable} : begin
					if ( cnt0 ) begin
						check_reg_stat = REG_WAIT_WB;
					end else begin
						check_reg_stat = REG_WAIT_EXE;
					end
				end
				default : begin
					check_reg_stat = REG_READY;
				end
			endcase
		end else begin
			check_reg_stat = REG_READY;
		end
	endfunction

	//*** update register status
	function RegStat_t update_reg_stat (
		input RegFile_t		rs,
		input RegStat_t		rs_stat,
		input [`ExeLatCnt]	rs_cnt,
		input ExeUnit_t		unit,
		input				issue_e_,
		input RegFile_t		issue_rd,
		input ExeUnit_t		issue_unit,
		input				wb_e_,
		input RegFile_t		wb_rd
	);

		//* internal variables
		RegType_t			rs_type;
		reg [ROB-1:0]		rs_addr;
		RegType_t			i_rd_type;
		reg [ROB-1:0]		i_rd_addr;
		reg					issue_match;
		reg					same_unit;
		RegType_t			wb_rd_type;
		reg [ROB-1:0]		wb_rd_addr;
		reg					wb_match;
		reg					cnt0;

		rs_type = rs.regtype;
		rs_addr = rs.addr[ROB-1:0];
		i_rd_type = issue_rd.regtype;
		i_rd_addr = issue_rd.addr[ROB-1:0];
		issue_match =
			!issue_e_ &&
			same_unit &&
			( rs_type == i_rd_type ) &&
			( rs_addr == i_rd_addr );
		same_unit = ( unit == issue_unit );
		wb_rd_type = wb_rd.regtype;
		wb_rd_addr = wb_rd.addr[ROB-1:0];
		wb_match =
			!wb_e_ &&
			( rs_type == wb_rd_type ) &&
			( rs_addr == wb_rd_addr );
		cnt0 = ( rs_cnt == 0 );

		case ( rs_stat )
			REG_READY : begin
				update_reg_stat = rs_stat;
			end

			REG_WAIT : begin
				case ( {wb_match, issue_match} )
					{`Disable, `Enable} : begin
						// issue
						if ( cnt0 ) begin
							update_reg_stat = REG_WAIT_WB;
						end else begin
							update_reg_stat = REG_WAIT_EXE;
						end
					end
					{`Disable, `Disable} : begin
						// no event occured
						update_reg_stat = rs_stat;
					end
					default : begin
						// writeback
						update_reg_stat = REG_READY;
					end
				endcase
			end

			REG_WAIT_EXE : begin
				case ( {cnt0, wb_match} )
					{`Enable, `Disable} : begin
						// issue
						update_reg_stat = REG_WAIT_WB;
					end
					{`Disable, `Disable} : begin
						// no event occured
						update_reg_stat = rs_stat;
					end
					default : begin
						// writeback
						update_reg_stat = REG_READY;
					end
				endcase
			end

			REG_WAIT_WB : begin
				if ( !wb_e_ && wb_match ) begin
					update_reg_stat = REG_READY;
				end else begin
					update_reg_stat = rs_stat;
				end
			end
		endcase
	endfunction



	//***** issue instruction select
	issue_select #(
		.IQ_DEPTH	( IQ_DEPTH )
	) issue_select (
		.inst_busy		( inst_busy ),
		.rs1_stat		( rs1_stat ),
		.rs2_stat		( rs2_stat ),
		.valid			( valid ),
		.issue_ready_	( issue_ready_ )
	);



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			stat_table <= 0;
			rs1_stat <= 0;
			rs1_cnt <= 0;
			rs2_stat <= 0;
			rs2_cnt <= 0;
			valid <= 0;
		end else begin
			if ( flush_ == `Enable_ ) begin
`ifdef DEBUG
				stat_table <= 0;
				rs1_stat <= 0;
				rs1_cnt <= 0;
				rs2_stat <= 0;
				rs2_cnt <= 0;
`endif
				valid <= 0;
			end else begin
				stat_table <= next_stat_table;
				rs1_stat <= next_rs1_stat;
				rs1_cnt <= next_rs1_cnt;
				rs2_stat <= next_rs2_stat;
				rs2_cnt <= next_rs2_cnt;
				valid <= next_valid;
			end
		end
	end

endmodule
