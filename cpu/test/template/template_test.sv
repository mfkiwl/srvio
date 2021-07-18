/*
* <template_test.sv>
*/

// include

module template_test;
	parameter STEP = 10;
	// parameter

	// wire

	template #(
		//parameter list
	) template (
		.*
	);

`ifdef VERILATOR
`else
	// clock generation

	initial begin
	end
`endif

endmodule
