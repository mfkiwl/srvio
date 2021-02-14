`include "stddef.vh"
`include "cpu_config.svh"

module btb_test;
	parameter STEP = 10;
	parameter ADDR = 32;
	parameter INST = `InstWidth;
	parameter BTB_D = 32;
	parameter FETCH = 1;
	parameter SIMBRCOM = 1;
	parameter CNT = `BtbCntWidth;

	reg						clk;
	reg						reset_;
	/* prediction */
	reg [ADDR-1:0]			pc;
	wire					btb_hit;
	wire [ADDR-1:0]			btb_addr;
	/* train */
	reg						br_commit_;
	reg						br_taken_;
	reg						br_miss_;
	reg						jump_commit_;
	reg						jump_miss_;
	reg [ADDR-1:0]			com_addr;
	reg [ADDR-1:0]			com_tar_addr;

	btb #(
		.ADDR			( ADDR ),
		.BTB_D			( BTB_D )
	) btb (
		.*
	);

	task dump_btb;
		integer i;
		begin
			for ( i = 0; i < BTB_D; i = i + 1 ) begin
				$display("table[%4d]: target = %x, tag = %x, cnt = %x", 
					i, btb.addr_buf[i], btb.tag[i], btb.cnt[i]);
			end
		end
	endtask

	task set_br_commit;
		input [ADDR-1:0]	pc;
		input [ADDR-1:0]	target;
		input				taken_;
		input				miss_;
		begin
			com_addr = pc;
			com_tar_addr = target;
			br_commit_ = `Enable_;
			br_taken_ = taken_;
			br_miss_ = miss_;
			#(STEP);
			reset_commit;
		end
	endtask

	task set_jump_commit;
		input [ADDR-1:0]	pc;
		input [ADDR-1:0]	target;
		input				miss_;
		begin
			com_addr = pc;
			com_tar_addr = target;
			jump_commit_ = `Enable_;
			jump_miss_ = miss_;
			#(STEP);
			reset_commit;
		end
	endtask

	task reset_commit;
		begin
			br_commit_ = `Disable_;
			br_taken_ = `Disable_;
			br_miss_ = `Disable_;
			jump_commit_ = `Disable_;
			jump_miss_ = `Disable_;
			com_addr = {ADDR{1'b0}};
			com_tar_addr = {ADDR{1'b0}};
		end
	endtask

	always #(STEP/2) begin
		clk <= ~clk;
	end

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		pc <= {ADDR{1'b0}};
		br_commit_ <= `Disable_;
		br_taken_ <= `Disable_;
		br_miss_ <= `Disable_;
		jump_commit_ <= `Disable_;
		jump_miss_ <= `Disable_;
		com_addr <= {ADDR{1'b0}};
		com_tar_addr <= {ADDR{1'b0}};
		#(STEP);
		reset_ <= `Disable_;

		#(STEP*5);
		/* training check */
		set_jump_commit(32'hdeadbe74, 32'hcafecafc, `Enable_);
		#(STEP);

		/* prediction check */
		#(STEP*5);
		pc = 32'hdeadbe74;
		#(STEP);
		pc = 0;
		dump_btb;
		#(STEP);
		$finish;
	end

	`include "waves.vh"

endmodule
