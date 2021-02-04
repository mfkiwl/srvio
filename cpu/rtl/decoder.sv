/*
* <decoder.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.vh"
`include "decode.svh"

module decoder  #(
)(
	output Decode_t		dec_out
);
