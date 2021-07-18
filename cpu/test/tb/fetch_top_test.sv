/*
* <fetch_top_test.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"
`include "cpu_if.svh"
`include "rv_opcodes.svh"
`include "rv_verif.svh"
`include "sim.vh"

`define WriteRom(addr,inst)		ic_fetch_if.write_debug_rom(addr,inst)

module fetch_top_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter INST = `InstWidth;
	parameter PRED_MAX = `PredMaxDepth;
	parameter BP_DEPTH = `PredTableDepth;
	parameter BrPredType_t PREDICTOR = `PredType;
	parameter BTB_DEPTH = `BtbDepth;
	parameter RA_DEPTH = `RaStackDepth;
	parameter ROB_DEPTH = `RobDepth;

	//***** signal generation
	logic				clk ;
	logic				reset_;

	//***** instruction
	reg [INST-1:0]		inst;

	//***** iterator
	int		i;

	ICacheFetchIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) ic_fetch_if();

	FetchDecIf #(
		.ADDR			( ADDR ),
		.INST			( INST )
	) fetch_dec_if();

	PcInstIf #(
		.ADDR			( ADDR ),
		.INST			( INST ),
		.ROB_DEPTH		( ROB_DEPTH )
	) pc_inst_if();

	fetch_top #(
		.ADDR			( ADDR ),
		.INST			( INST ),
		.PRED_MAX		( PRED_MAX ),
		.BP_DEPTH		( BP_DEPTH ),
		.PREDICTOR		( PREDICTOR ),
		.BTB_DEPTH		( BTB_DEPTH ),
		.RA_DEPTH		( RA_DEPTH ),
		.ROB_DEPTH		( ROB_DEPTH )
	) fetch_top (
		.clk			( clk ),
		.reset_			( reset_ ),
		.*
	);

`ifdef VERILATOR
`else
	always #( STEP/2 ) begin
		clk <= ~clk;
	end

	always @( posedge clk ) begin
		inst = ic_fetch_if.read_debug_rom;
		#(STEP/2);
		ic_fetch_if.ic_inst = inst;
	end

	always @( posedge clk ) begin
		if ( fetch_top.inst_e_ == `Enable_ ) begin
			`SetCharGreenBold
			$display("Fetched from I-Cache");
			`ResetCharSetting
			$display("    PC: %x", fetch_top.inst_pc);
			$display("    Instruction: %x", fetch_top.inst);
		end
	end

	//***** Initalize Debug rom
	//    0:	addi $2, $0, 5
	//    4:	addi $3, $0, 10
	//    8:	addi $4, $0, 15
	//    c:	addi $5, $0, 20
	//   10:	addi $6, $0, 25
	//   14:	addi $6, $0, 30
	//   18:	addi $6, $0, 35
	//   1c:	jal  $0, -14
	//   20:	addi $2, $0, 5
	//   24:	addi $3, $0, 10
	//   28:	addi $4, $0, 15
	//   2c:	addi $5, $0, 20
	//   30:	addi $6, $0, 25
	//   34:	addi $6, $0, 30
	//   38:	addi $6, $0, 35
	//   3c:	jal $0, -14
	task set_debug_rom_case1;
		//ic_fetch_if.write_debug_rom('h0, rv_verif::alu_i_inst("addi", 2, 0, 5));
		//ic_fetch_if.write_debug_rom('h4, rv_verif::alu_i_inst("addi", 2, 0, 10));
		//ic_fetch_if.write_debug_rom('h4, rv_verif::alu_i_inst("addi", 2, 0, 10));
		`WriteRom('h0, rv_verif::alu_i_inst("addi", 2, 0, 5));
		`WriteRom('h1, rv_verif::alu_i_inst("addi", 3, 0, 10));
		`WriteRom('h2, rv_verif::alu_i_inst("addi", 3, 0, 15));
		`WriteRom('h3, rv_verif::alu_i_inst("addi", 3, 0, 20));
		`WriteRom('h4, rv_verif::alu_i_inst("addi", 3, 0, 25));
		`WriteRom('h5, rv_verif::alu_i_inst("addi", 3, 0, 30));
		`WriteRom('h6, rv_verif::alu_i_inst("addi", 3, 0, 35));
		`WriteRom('h7, rv_verif::jal_inst(-28>>1, 0));	// to pc = 0x00
		`WriteRom('h8, rv_verif::alu_i_inst("addi", 2, 0, 5));
		`WriteRom('h9, rv_verif::alu_i_inst("addi", 3, 0, 10));
		`WriteRom('ha, rv_verif::alu_i_inst("addi", 3, 0, 15));
		`WriteRom('hb, rv_verif::alu_i_inst("addi", 3, 0, 20));
		`WriteRom('hc, rv_verif::alu_i_inst("addi", 3, 0, 25));
		`WriteRom('hd, rv_verif::alu_i_inst("addi", 3, 0, 30));
		`WriteRom('he, rv_verif::alu_i_inst("addi", 3, 0, 35));
		`WriteRom('hf, rv_verif::jal_inst(-28>>1, 0));	// to pc = 0x20
	endtask

	initial begin
		clk = `Low;
		reset_ = `Enable_;
		inst = 0;
		ic_fetch_if.initialize_fetch();
		fetch_dec_if.initialize_fetch();
		pc_inst_if.initialize_fetch();

		#(STEP);
		reset_ = `Disable_;
		#(STEP*5);

		#(STEP);
		reset_ = `Enable_;
		`SetCharCyanBold
		$display("Test Case1");
		`ResetCharSetting
		// set debug rom for test case1
		set_debug_rom_case1;

		#(STEP);
		reset_ = `Disable_;

		#(STEP*10);
		$finish;
	end

`endif

endmodule
