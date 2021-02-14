/*
* <rename.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module rename #(
	parameter ROB_DEPTH = `RobDepth,
	// config
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input wire				clk,
	input wire				reset_,

	input wire				flush_,

	input wire				dec_e_,
	input wire				dec_invalid,
	input RegFile_t			dec_rd,
	input RegFile_t			dec_rs1,
	input RegFile_t			dec_rs2,
	input wire [ROB-1:0]	dec_rob_id,
	output RegFile_t		ren_rs1,
	output RegFile_t		ren_rs2,
	output RegFile_t		ren_rd,

	input wire				commit_e_,
	input wire [ROB-1:0]	com_rob_id
);

	//***** internal parameters
	localparam REGFILE = $bits(RegFile_t);
	localparam bit [REGFILE-1:0] INVALID_REG = 0;

	//***** internal registers
	reg [ROB_DEPTH-1:0]		valid;

	//***** internal wires
	//*** destination operands
	wire					dec_zero_reg;
	wire					dec_dst_gpr;
	wire					dec_dst_fpr;
	wire					dec_rd_valid;
	wire					dec_rename_req;
	//*** source operands
	//* rs1
	wire					rs1_valid;
	wire					rs1_zero_reg;
	wire					rs1_dst_gpr;
	wire					rs1_dst_fpr;
	wire					rs1_rename_req;
	wire					rs1_cam_valid;
	wire [ROB-1:0] 			rs1_cam_addr;
	wire					rs1_commit;
	RegFile_t				rob_rs1;
	//* rs2
	wire					rs2_valid;
	wire					rs2_zero_reg;
	wire					rs2_dst_gpr;
	wire					rs2_dst_fpr;
	wire					rs2_rename_req;
	wire					rs2_cam_valid;
	wire [ROB-1:0] 			rs2_cam_addr;
	wire					rs2_commit;
	RegFile_t				rob_rs2;

	//***** combinational cells
	logic [ROB-1:0]			next_valid;



	//***** assign output
	assign ren_rd =
		( dec_rename_req )
			? '{regtype: TYPE_ROB, addr: dec_rob_id}
			: '{regtype: TYPE_NONE, addr: dec_rob_id};
	assign ren_rs1 = 
		( rs1_cam_valid && rs1_rename_req && !rs1_commit )
			? rob_rs1 
			: dec_rs1;
	assign ren_rs2 = 
		( rs2_cam_valid && rs2_rename_req && !rs2_commit )
			? rob_rs2 
			: dec_rs2;



	//***** assign internal
	//*** destination operands
	assign dec_dst_gpr = ( dec_rd.regtype == TYPE_GPR );
	assign dec_dst_fpr = ( dec_rd.regtype == TYPE_FPR );
	assign dec_zero_reg = ( dec_rd.addr == {`GprAddrWidth{1'b0}} );
	assign dec_rename_req =
		( ( dec_dst_gpr && !dec_zero_reg ) || dec_dst_fpr );
	assign dec_rd_valid = !dec_invalid && dec_rename_req;
	//*** source operands
	//* rs1
	assign rs1_valid = valid[dec_rs1.addr];
	assign rs1_dst_gpr = ( dec_rs1.regtype == TYPE_GPR );
	assign rs1_dst_fpr = ( dec_rs1.regtype == TYPE_FPR );
	assign rs1_zero_reg = ( dec_rs1.addr == {`GprAddrWidth{1'b0}} );
	assign rs1_rename_req =
		( ( rs1_dst_gpr && !rs1_zero_reg ) || rs1_dst_fpr );
	assign rob_rs1 = '{regtype: TYPE_ROB, addr: rs1_cam_addr};
	assign rs1_commit = ( rs1_cam_addr == com_rob_id ) && !commit_e_;
	//* rs2
	assign rs2_valid = valid[dec_rs2.addr];
	assign rs2_dst_gpr = ( dec_rs2.regtype == TYPE_GPR );
	assign rs2_dst_fpr = ( dec_rs2.regtype == TYPE_FPR );
	assign rs2_zero_reg = ( dec_rs2.addr == {`GprAddrWidth{1'b0}} );
	assign rs2_rename_req =
		( ( rs2_dst_gpr && !rs2_zero_reg ) || rs2_dst_fpr );
	assign rob_rs2 = '{regtype: TYPE_ROB, addr: rs2_cam_addr};
	assign rs2_commit = ( rs2_cam_addr == com_rob_id ) && !commit_e_;


	//***** rename source operands
	rename_map #(
		.DATA		( REGFILE ),
		.DEPTH		( ROB_DEPTH ),
		.WRITE		( 1 ),
		.READ		( 2 )
	) rename_map (
		.clk		( clk ),
		.reset_		( reset_ ),
		.we_		( dec_e_ ),
		.wv			( dec_rd_valid ),
		.wd			( dec_rd ),
		.waddr		( dec_rob_id ),

		.flush_		( flush_ ),
		.inve_		( commit_e_ ),
		.invaddr	( com_rob_id ),

		.re_		( {2{dec_e_}} ),
		.rd			( {dec_rs2, dec_rs1} ),
		.match		( {rs2_cam_valid, rs1_cam_valid} ),
		.raddr		( {rs2_cam_addr, rs1_cam_addr} )
	);



	//***** combinational logics
	int ci;
	always_comb begin
		for ( ci = 0; ci < ROB; ci = ci + 1 ) begin
			unique if ( !dec_e_ && ( dec_rob_id == ci ) ) begin
				next_valid[ci] = dec_rd_valid;
			end else if ( !commit_e_ && ( com_rob_id == ci ) ) begin
				next_valid[ci] = `Disable;
			end else begin
				next_valid[ci] = valid[ci];
			end
		end
	end



	//***** sequential logics
	always_ff @( posedge clk or negedge reset_ ) begin
		if ( reset_ == `Enable_ ) begin
			valid <= `Disable;
		end else begin
			valid <= next_valid;
		end
	end

endmodule
