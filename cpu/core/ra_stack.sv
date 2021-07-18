/*
* <ra_stack.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`include "stddef.vh"
`include "cpu_config.svh"

module ra_stack #(
	parameter ADDR = `AddrWidth,
	parameter RA_DEPTH = `RaStackDepth
)(
	input wire					clk,
	input wire					reset_,

	input wire					call_,		// function call commit
	input wire [ADDR-1:0]		call_pc,	// 
	input wire					ret_,		// function return fetch
	output wire					ret_v,		// return address valid
	output wire [ADDR-1:0]		ret_addr	// 
);

	//***** internal parameter
	localparam INCR = `InstWidth / `ByteBitWidth;

	//***** internal assign
	wire [ADDR-1:0]				call_pc_p4;

	//***** assign interanl
	assign call_pc_p4 = call_pc + INCR;
	// TODO: 投機実行中と、commit済みでポインタを分離
	//			commit時にスタック間で別のポインタを使用
	//			commit時に本物のポインタを動かす
	// TODO: DEPTHを超えてスタックにつもうとした時の動作を確認
	//			スタックのそこのエントリが追い出されるようにしたい
	// stack.svをベースにして、ptrが一周可能なように書き換え

	// TODO: branchごとにstackの深さを保存しておく
	//			miss speculativeなreturnにより破壊される可能性はあるが、
	//			影響は少ないでしょう...



	//***** stack module
	stack #(
		.DATA		( ADDR ),
		.DEPTH		( RA_DEPTH ),
		.BUF_EXT	( `Disable ),
		.PUSH		( 1 ),
		.POP		( 1 )
	) stack (
		.clk		( clk ),
		.reset_		( reset_ ),
		.flush_		( `Disable_ ),
		.push_		( call_ ),
		.wd			( call_pc_p4 ),
		.pop_		( ret_ ),
		.rd			( ret_addr ),
		.v			( ret_v ),
		.busy		()
	);

endmodule
