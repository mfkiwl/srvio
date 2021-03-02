/*
* <operand_mux.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"

module operand_mux #(
	parameter DATA = `DataWidth,
	parameter ROB_DEPTH = `RobDepth,
	// constant
	parameter ROB = $clog2(ROB_DEPTH)
)(
	input RegFile_t			issue_rs1,
	input RegFile_t			issue_rs2,
	input ImmData_t			issue_imm,
	input wire [ADDR-1:0]	issue_pc,

	input wire				wb_e_,
	input RegFile_t			wb_rd,
	input wire [DATA-1:0]	wb_data,

	input wire				commit_e_,
	input wire [ROB-1:0]	commit_rob_id,
	input wire [DATA-1:0]	commit_data,

	input wire [DATA-1:0]	gpr_data1,
	input wire [DATA-1:0]	gpr_data2,
	output wire [`GprAddr]	gpr_addr1,
	output wire [`GprAddr]	gpr_addr2,

	input wire [DATA-1:0]	fpr_data1,
	input wire [DATA-1:0]	fpr_data2,
	output wire [`FprAddr]	fpr_addr1,
	output wire [`FprAddr]	fpr_addr2,

	output wire [DATA-1:0]	data1,
	output wire				data1_e_,
	output wire [DATA-1:0]	data2,
	output wire				data2_e_
);

	//***** extention width
	localparam EXTEND5 = DATA - 5;
	localparam EXTEND12_S0 = DATA - 12;
	localparam EXTEND12_S1 = DATA - ( 12 + 1 );
	localparam EXTEND20_S1 = DATA - ( 20 + 1 );
	localparam EXTEND20_S12 = DATA - ( 20 + 12 );

	//***** internal types
	typedef struct packed {
		logic [`GprAddr]	gpr_addr;
		logic [`GprAddr]	fpr_addr;
		logic [DATA-1:0]	data;
		logic				data_e_;
	} PackedData_t;

	//***** internal wires
	wire [4:0]				imm5;
	wire [11:0]				imm12;
	wire [19:0]				imm20;
	wire [ROB-1:0]			rs1_rob_id;
	wire [ROB-1:0]			rs2_rob_id;
	PackedData_t			packed_data1;
	PackedData_t			packed_data2;

	//***** combinational cells
	logic					wb_match1;
	logic					wb_match2;
	logic					com_match1;
	logic					com_match2;
	logic [DATA-1:0]		bypass_data1;
	logic [DATA-1:0]		bypass1_e_;
	logic [DATA-1:0]		bypass_data2;
	logic [DATA-1:0]		bypass2_e_;
	logic [DATA-1:0]		imm_data;



	//***** assign output
	assign gpr_addr1 = packed_data1.gpr_addr;
	assign fpr_addr1 = packed_data1.fpr_addr;
	assign data1 = packed_data1.data;
	assign data1_e_ = packed_data1.data_e_;
	assign gpr_addr2 = packed_data2.gpr_addr;
	assign fpr_addr2 = packed_data2.fpr_addr;
	assign data2 = packed_data2.data;
	assign data2_e_ = packed_data2.data_e_;



	//***** assign internal
	assign imm5 = issue_imm.data[4:0];
	assign imm12 = issue_imm.data[11:0];
	assign imm20 = issue_imm.data;
	assign rs1_rob_id = issue_rs1.addr[ROB-1:0];
	assign rs2_rob_id = issue_rs2.addr[ROB-1:0];
	assign packed_data1 =
		sel_data(
			issue_rs1, bypass_data1, bypass1_e_,
			gpr_data1, fpr_data1, issue_pc, imm_data
		);
	assign packed_data2 =
		sel_data(
			issue_rs2, bypass_data2, bypass2_e_,
			gpr_data2, fpr_data2, issue_pc, imm_data
		);

	//*** select function
	function PackedData_t sel_data (
		input RegFile_t		issue_rs,
		input [DATA-1:0]	bypass_data,
		input [DATA-1:0]	bypass_e_,
		input [DATA-1:0]	gpr_data,
		input [DATA-1:0]	fpr_data,
		input [DATA-1:0]	pc,
		input [DATA-1:0]	imm_data
	);

		case ( issue_rs.regtype )
			TYPE_GPR : begin
				sel_data = '{
					gpr_addr	: issue_rs.addr[`GprAddr],
					fpr_addr 	: 0,
					data		: gpr_data,
					data_e_		: `Enable_
				};
			end
			TYPE_FPR : begin
				sel_data = '{
					gpr_addr	: 0,
					fpr_addr	: issue_rs.addr[`FprAddr],
					data		: fpr_data,
					data_e_		: `Enable_
				};
			end
			TYPE_IMM : begin
				sel_data = '{
					gpr_addr	: 0,
					fpr_addr	: 0,
					data		: imm_data,
					data_e_		: `Enable_
				};
			end
			TYPE_PC : begin
				sel_data = '{
					gpr_addr	: 0,
					fpr_addr	: 0,
					data		: pc,
					data_e_		: `Enable_
				};
			end
			TYPE_ROB : begin
				sel_data = '{
					gpr_addr	: 0,
					fpr_addr	: 0,
					data		: bypass_data,
					data_e_		: bypass_e_
				};
			end
			default : begin
				sel_data = '{
					gpr_addr	: 0,
					fpr_addr	: 0,
					data		: 0,
					data_e_		: `Enable_
				};
			end
		endcase
	endfunction



	//***** combinational logics
	always_comb begin
		//*** bypass data
		wb_match1 = !wb_e_ && ( rs1_rob_id == wb_rd.addr[ROB-1:0] );
		wb_match2 = !wb_e_ && ( rs2_rob_id == wb_rd.addr[ROB-1:0] );
		com_match1 = !commit_e_ && ( rs1_rob_id == commit_rob_id );
		com_match2 = !commit_e_ && ( rs2_rob_id == commit_rob_id );

		case ( {com_match1, wb_match} )
			{`Disable, `Enable} : begin
				bypass_data1 = wb_data;
				bypass1_e_ = `Enable_;
			end
			{`Enable, `Disable} : begin
				bypass_data1 = commit_data;
				bypass1_e_ = `Enable_;
			end
			default : begin
				// {`Enable, `Enable} is impossible -> don't care
				bypass_data1 = issue_rs1;
				bypass1_e_ = `Disable_;
			end
		endcase

		case ( {com_match2, wb_match} )
			{`Disable, `Enable} : begin
				bypass_data2 = wb_data;
				bypass2_e_ = `Enable_;
			end
			{`Enable, `Disable} : begin
				bypass_data2 = commit_data;
				bypass2_e_ = `Enable_;
			end
			default : begin
				// {`Enable, `Enable} is impossible -> don't care
				bypass_data2 = issue_rs2;
				bypass2_e_ = `Disable_;
			end
		endcase

		//*** immediate
		case ( issue_imm.size )
			IMM_SIZE5 : begin
				if ( issue_imm.sign )
					imm_data = {{EXTEND5{imm5[4]}}, imm5};
				end else begin
					imm_data = {{EXTEND5{1'b0}}, imm5};
				end
			end
			IMM_SIZE5_12 : begin
				// unpacked in csr_unit
				imm_data = issue_imm.data;
			end
			IMM_SIZE12 : begin
				if ( issue_imm.shift == IMM_SHIFT1 ) begin
					if ( issue_imm.sign )
						imm_data = {{EXTEND12_S1{imm12[11]}}, imm12, 1'b0};
					end else begin
						imm_data = {{EXTEND12_S1{1'b0}}, imm12, 1'b0};
					end
				end else begin
					// no shift
					if ( issue_imm.sign )
						imm_data = {{EXTEND12_S0{imm12[11]}}, imm12};
					end else begin
						imm_data = {{EXTEND12_S0{1'b0}}, imm12};
					end
				end
			end
			IMM_SIZE20 : begin
				if ( issue_imm.shift == IMM_SHIFT1 ) begin
					if ( issue_imm.sign )
						imm_data = {{EXTEND20_S1{imm20[19]}}, imm20, 1'b0};
					end else begin
						imm_data = {{EXTEND20_S1{1'b0}}, imm20, 1'b0};
					end
				end else begin
					// shift 12bit
					if ( issue_imm.sign )
						imm_data = {{EXTEND20_S12{imm20[19]}}, imm20, 12'b0};
					end else begin
						imm_data = {{EXTEND20_S12{1'b0}}, imm20, 12'b0};
					end
				end
			end
		endcase
	end

endmodule
