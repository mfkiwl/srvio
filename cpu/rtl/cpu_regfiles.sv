/*
* <cpu_regfiles.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "regfile.svh"
`include "exception.svh"

module cpu_regfiles #(
	parameter DATA = `DataWidth
)(
	input wire				clk,
	input wire				reset_,

	input wire [`GprAddr]	issue_gpr_addr1,
	input wire [`GprAddr]	issue_gpr_addr2,
	input wire [`GprAddr]	issue_gpr_data1,
	input wire [`GprAddr]	issue_gpr_data2,

	input wire [`FprAddr]	issue_fpr_addr1,
	input wire [`FprAddr]	issue_fpr_addr2,
	input wire [`FprAddr]	issue_fpr_data1,
	input wire [`FprAddr]	issue_fpr_data2,

	input wire				commit_e_,
	input wire RegFile_t	commit_rd,
	input wire [DATA-1:0]	commit_data
);

	//***** combinational cells
	logic					gpr_we_;
	logic [`GprAddr]		gpr_waddr;
	logic					fpr_we_;
	logic [`FprAddr]		fpr_waddr;



	//***** Register Files
	regfile #(
		.DATA		( DATA ),
		.ADDR		( `GprAddrWidth ),
		.READ		( 2 ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Enable )
	) gpr (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( {issue_gpr_addr2, issue_gpr_addr1} ),
		.waddr		( gpr_addr ),
		.we_		( gpr_we_ ),
		.wdata		( commit_data ),
		.rdata		( {issue_gpr_data2, issue_gpr_data1} )
	);

	regfile #(
		.READ		( 2 ),
		.ADDR		( `FprAddrWidth ),
		.WRITE		( 1 ),
		.ZERO_REG	( `Disable )
	) fpr (
		.clk		( clk ),
		.reset_		( reset_ ),
		.raddr		( {issue_fpr_addr2, issue_fpr_addr1} ),
		.waddr		( gpr_addr ),
		.we_		( fpr_we_ ),
		.wdata		( commit_data ),
		.rdata		( {issue_fpr_data2, issue_fpr_data1} )
	);



	//***** Control and Status Regsiters
	csr #(
	) csr (
	);



	//***** combinational logics
	always_comb begin
		case ( commit_rd.regtype )
			TYPE_GPR : begin
				gpr_we_ = commit_e_;
				gpr_waddr = commit_rd.addr;
				fpr_we_ = `Disable_;
				fpr_waddr = 0;
			end
			TYPE_FPR : begin
				gpr_we_ = `Disable_;
				gpr_waddr = 0;
				fpr_we_ = commit_e_;
				fpr_waddr = commit_rd.addr;
			end
			default : begin
				gpr_we_ = `Disable_;
				gpr_waddr = 0;
				fpr_we_ = `Disable_;
				fpr_waddr = 0;
			end
		endcase
	begin

endmodule
