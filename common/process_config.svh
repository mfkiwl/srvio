/*
* <process_config.vh>
*
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
*
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _PROCESS_CONFIG_SVH_INCLUDED_
`define _PROCESS_CONFIG_SVH_INCLUDED_

// ASIC Configuration
//`define ASIC
//`define TSMC130		4'b0000
//`define TSMC65		4'b0001

//`define FPGA
//`define XILINX7		4'b1000
//`define XILINX_VUP	4'b1010

typedef enum {
	Generic,
	TSMC130,
	TSMC65,
	XILINX7,
	XILINX_VUP
} ProcessConf_t;

`define DEFAULT_PROCESS	Generic

`endif //_PROCESS_CONFIG_H_INCLUDED_
