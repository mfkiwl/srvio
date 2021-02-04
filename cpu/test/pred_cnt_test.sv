`include "stddef.h"
`include "cpu_config.h"

module pred_cnt_test;
	parameter STEP = 10;
	parameter ADDR = `AddrWidth;
	parameter CNTW = `PredCntWidth;
	parameter PRED_D = `PredMaxDepth;
	parameter PRT_D = `PredTableDepth;
	parameter SIMBRF = `SimBrFetch;
	parameter SIMBRCOM = `SimBrCommit;

	reg						clk;
	reg						reset_;
	reg						flush_;
	reg [SIMBRF-1:0]		br_;
	reg [SIMBRF*ADDR-1:0]	br_addr;
	wire [SIMBRF-1:0]		pred_taken;

	reg [SIMBRCOM-1:0]		br_commit_;
	reg [SIMBRCOM-1:0]		br_taken_;
	reg [SIMBRCOM-1:0]		br_pred_miss_;
	wire					busy;

	pred_cnt pred_cnt (
		.clk			( clk ),
		.reset_			( reset_ ),
		.flush_			( flush_ ),

		.br_			( br_ ),
		.br_addr		( br_addr ),
		.pred_taken		( pred_taken ),

		.br_commit_		( br_commit_ ),
		.br_taken_		( br_taken_ ),
		.br_pred_miss_	( br_pred_miss_ ),

		.busy			( busy )
	);

`ifndef VERILATOR
	always #(STEP/2) begin
		clk <= ~clk;
	end

	task br_issue;
		input [31:0]		num;
		input [ADDR-1:0]	addr;
		integer i;
		begin
			for ( i = 0; i < num; i = i + 1 ) begin
				br_[i] = `Enable_;
				br_addr[`RangeF(i,ADDR)] = addr + ( i * 64'h100 );
			end
			#(STEP);
			br_ = {SIMBRF{`Disable_}};
		end
	endtask

	task br_commit;
		input [31:0]			num;
		input [SIMBRCOM-1:0]	taken_;
		input [SIMBRCOM-1:0]	miss_;
		integer i;
		begin
			for ( i = 0; i < num; i = i + 1 ) begin
				br_commit_[i] = `Enable_;
				br_taken_[i] = taken_[i];
				br_pred_miss_[i] = miss_[i];
			end
			#(STEP);
			br_commit_ = {SIMBRCOM{`Disable_}};
		end
	endtask

	initial begin
		clk <= `Low;
		reset_ <= `Enable_;
		flush_ <= `Disable_;
		br_ <= {SIMBRF{`Disable_}};
		br_addr <= {SIMBRF*ADDR{1'b0}};
		br_commit_ <= {SIMBRCOM{`Disable_}};
		br_pred_miss_ <= {SIMBRCOM{`Disable}};
		#(STEP*5);
		reset_ <= `Disable_;
		#(STEP*2);
		br_issue(2, 64'hdeadbeef);
		#(STEP);
		br_commit(2,2'b01,2'b01);
		#(STEP*2);
		br_issue(2, 64'hdeadbeef);
		#(STEP*10);
		$finish();
	end

 `ifdef SimVision
	initial begin
		$shm_open();
		$shm_probe("AC");
	end
 `endif
`endif

endmodule
