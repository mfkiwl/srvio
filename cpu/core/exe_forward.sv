/*
* <exe_forward.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module exe_forward #(
	parameter DATA = `DataWidth,
	parameter ROB = $clog2(`RobDepth)
)(
);

endmodule
