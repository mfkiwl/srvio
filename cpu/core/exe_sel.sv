/*
* <exe_sel.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "exe.svh"

module exe_sel (
	input wire			issue_e_,
	input ExeUnit_t		issue_unit,
	input wire			issue_miss,

	output logic		issue_alu_,
	output logic		issue_div_,
	output logic		issue_fpu_,
	output logic		issue_fdiv_,
	output logic		issue_csr_,
	output logic		issue_mem_,
	output logic		issue_invalid_
);

	//***** internal wires
	wire				issue_;



	//***** assign internal
	assign issue_grant_ = issue_e_  || issue_miss;

	//***** combinational logics
	always_comb begin
		issue_alu_ = `Disable_;
		issue_div_ = `Disable_;
		issue_fpu_ = `Disable_;
		issue_fdiv_ = `Disable_;
		issue_csr_ = `Disable_;
		issue_mem_ = `Disable_;
		issue_invalid_ = `Disable_;

		case ( issue_unit )
			UNIT_ALU : begin
				issue_alu_ = issue_grant_;
			end
			UNIT_DIV : begin
				issue_div_ = issue_grant_;
			end
			UNIT_FPU : begin
				issue_fpu_ = issue_grant_;
			end
			UNIT_FDIV : begin
				issue_fdiv_ = issue_grant_;
			end
			UNIT_CSR : begin
				issue_csr_ = issue_grant_;
			end
			UNIT_MEM : begin
				issue_mem_ = issue_grant_;
			end
			default : begin
				issue_invalid_ = issue_grant_;
			end
		endcase
	end

endmodule
