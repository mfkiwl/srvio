`include "stddef.vh"
`include "cpu_config.vh"

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
	reg [FETCH*ADDR-1:0]	btb_addr;
	wire [FETCH-1:0]		target_valid;
	wire [FETCH*ADDR-1:0]	target_addr;
	/* train */
	reg [SIMBRCOM-1:0]		pc_chg_com_;
	reg [SIMBRCOM-1:0]		chg_taken_;
	reg [SIMBRCOM*ADDR-1:0]	com_addr;
	reg [SIMBRCOM*ADDR-1:0]	com_tar_addr;

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

	task set_pc;
		input [31:0]		num;
		input [ADDR-1:0]	pc;
		begin
			btb_addr[`RangeF(num,ADDR)] = pc;
		end
	endtask

	task set_commit;
		input [31:0]		num;
		input				taken;
		input [ADDR-1:0]	pc;
		input [ADDR-1:0]	target;
		begin
			pc_chg_com_[num] = `Enable_;
			chg_taken_[num] = !taken;
			com_addr[`RangeF(num,ADDR)] = pc;
			com_tar_addr[`RangeF(num,ADDR)] = target;
		end
	endtask

	task reset_commit;
		begin
			pc_chg_com_ <= {SIMBRCOM{`Disable_}};
			chg_taken_ <= {SIMBRCOM{`Disable_}};
			com_addr <= {SIMBRCOM*ADDR{1'b0}};
			com_tar_addr <= {SIMBRCOM*ADDR{1'b0}};
		end
	endtask

	always #(STEP/2) begin
		clk <= ~clk;
	end

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		btb_addr <= {ADDR{1'b0}};
		pc_chg_com_ <= {SIMBRCOM{`Disable_}};
		chg_taken_ <= {SIMBRCOM{`Disable_}};
		com_addr <= {SIMBRCOM*ADDR{1'b0}};
		com_tar_addr <= {SIMBRCOM*ADDR{1'b0}};
		#(STEP);
		reset_ <= `Disable_;
		#(STEP*5);
		/* training check */
		set_commit(0, `Enable, 32'hdeadbe74, 32'hcafecafe);
		#(STEP);
		reset_commit;
		#(STEP);

		/* prediction check */
		#(STEP*5);
		set_pc(0, 32'hdeadbe74);
		dump_btb;
		#(STEP);
		$finish;
	end

`ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("ACF");
	end
`endif

endmodule
