#!/bin/tcsh

##### Top Level modules
#set DEFAULT_DESIGN = "cpu_pipeline"

##### Semi-Top Level
#set DEFAULT_DESIGN = "fetch_dec"
#set DEFAULT_DESIGN = "fetch_dec_is"

##### Fetch Stage modules
#set DEFAULT_DESIGN = "fetch_top"
#set DEFAULT_DESIGN = "fetch_iag"
#set DEFAULT_DESIGN = "fetch_ctrl"
#set DEFAULT_DESIGN = "btb"
#set DEFAULT_DESIGN = "br_pred_cnt"
#set DEFAULT_DESIGN = "br_status_buf"
#set DEFAULT_DESIGN = "br_status"

##### Decode Stage modules
#set DEFAULT_DESIGN = "decode_top"
#set DEFAULT_DESIGN = "decoder"

##### Issue/Commit Stage modules
#set DEFAULT_DESIGN = "issue_top"
#set DEFAULT_DESIGN = "rename"
#set DEFAULT_DESIGN = "rob_status"
#set DEFAULT_DESIGN = "exp_manage"
#set DEFAULT_DESIGN = "reorder_buffer"
#set DEFAULT_DESIGN = "inst_sched"
#set DEFAULT_DESIGN = "inst_queue"

##### Exe Stage modules
#set DEFAULT_DESIGN = "alu_top"

##### Instruction Cache
set DEFAULT_DESIGN = ic_ram_block
