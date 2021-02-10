#!/bin/tcsh

source sim_tool.sh

if ( $SIM_TOOL =~ "xmverilog" ) then
	# cadence 
	echo "Removing file xmverilog.log"
	rm -f xmverilog.log

	echo "Removing file xmverilog.key"
	rm -f xmverilog.key

	echo "Removing file xmverilog.history"
	rm -f xmverilog.history

	echo "Removing directory xcelium.d"
	rm -rf xcelium.d

	echo "Removing directory waves.shm"
	rm -rf waves.shm

	echo "Removing directory .simvision"
	rm -rf .simvision

	echo "Removing directory .bpad"
	rm -rf .bpad
else if ( $SIM_TOOL =~ "vcs" ) then
	# synopsys
	echo "Removing file ucli.key"
	rm -f ucli.key

	foreach simbin ( *.sim )
		echo "Removing file $simbin"
		rm -f $simbin
	end

	echo "Removing directory csrc"
	rm -rf ./csrc

	foreach simdir ( *.sim.daidir )
		echo "Removing directory $simdir"
		rm -rf $simdir
	end
else if ( $SIM_TOOL =~ "verilator" ) then
endif
