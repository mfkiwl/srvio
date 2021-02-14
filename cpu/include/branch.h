/*
* <rob_status.sv>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _BRANCH_H_INCLUDED_
`define _BRANCH_H_INCLUDED_

`ifndef _CPU_CONFIG_H_INCLUDED_
 $error("cpu_config.h must be included first");
`endif

/***** Branch predictor parameters *****/
// PredTableDepth is defined in cpu_config.h
`define PredTableAddr	$clog2(`PredTableDepth)	// Prediction table address Width
`define PredTableBus	`PredTableAddr-1:0		// Prediction table range
`define PredIdxWidth	`PredTableWidth

/***** Branch Target Buffer Configuration *****/
// TbtTableDepth is defined in cpu_config.h
`define BtbTableAddr	$clog2(`BtbTableDepth)	// BTB Address
`define BtbTableBus		`BtbTableAddr-1:0		// BTB Address bus

`endif // _BRANCH_H_INCLUDED_
