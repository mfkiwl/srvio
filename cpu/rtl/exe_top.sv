/*
* <exe_top.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "decode.svh"
`include "exe.svh"

module exe_top #(
	parameter DATA = `DataWidth
)(
	input wire		clk,
	input wire		reset_,

	IsExeIf.exe		is_exe_if
);

	//***** internal wires
	ExeBusy_t		exe_busy;
	wire			alu_wb_req_;
	wire			alu_wb_ack_;
	RegFile_t		alu_pre_wb_rd;
	wire			div_wb_req_;
	wire			div_wb_ack_;
	RegFile_t		div_pre_wb_rd;
	wire			fpu_wb_req_;
	wire			fpu_wb_ack_;
	RegFile_t		fpu_pre_wb_rd;
	wire			fdiv_wb_req_;
	wire			fdiv_wb_ack_;
	RegFile_t		fdiv_pre_wb_rd;
	wire			csr_wb_req_;
	wire			csr_wb_ack_;
	RegFile_t		csr_pre_wb_rd;
	wire			mem_wb_req_;
	wire			mem_wb_ack_;
	RegFile_t		mem_pre_wb_rd;

	//***** combinational cells
	logic			alu_e_;
	logic			div_e_;
	logic			fpu_e_;
	logic			fdiv_e_;
	logic			csr_e_;
	logic			mem_e_;



	//***** Integer
	alu_top #(
		.DATA	( DATA )
	) alu (
		.clk	( clk ),
		.reset_	( reset_ )
	);



	//***** Integer Divider
	div_top #(
		.DATA	( DATA )
	) int_div (
		.clk	( clk ),
		.reset_	( reset_ )
	);



	//***** FPU



	//***** FP Divider



	//***** CSR Access
	csr_access_top #(
	) csr_access_top (
	);



	//***** Memory Access
	mem_access_top #(
	) mem_access_top (
	);



	//***** Common data bus
	cdb #(
		.DATA		( DATA )
	) cdb (
	);



	//***** combinational logics
	always_comb begin
		alu_e_ = `Disable_;
		div_e_ = `Disable_;
		fpu_e_ = `Disable_;
		fdiv_e_ = `Disable_;
		csr_e_ = `Disable_;
		mem_e_ = `Disable_;

		unique if ( is_exe_if.unit == UNIT_ALU ) begin
			alu_e_ = `Enable_;
		end else if ( is_exe_if.unit == UNIT_DIV ) begin
			div_e_ = `Enable_;
		end else if ( is_exe_if.unit == UNIT_FPU ) begin
			fpu_e_ = `Enable_;
		end else if ( is_exe_if.unit == UNIT_FDIV ) begin
			fdiv_e_ = `Enable_;
		end else if ( is_exe_if.unit == UNIT_CSR ) begin
			csr_e_ = `Enable_;
		end else if ( is_exe_if.unit == UNIT_MEM ) begin
			mem_e_ = `Enable_;
		end
	end

endmodule
