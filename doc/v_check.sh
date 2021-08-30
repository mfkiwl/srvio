#!/bin/tcsh

# test script for v_check.pl

make dir.yml
make incdir.yml
perl ./scripts/v_check.pl -t ./yaml/design \
	-d ../cpu/core/fetch_iag.sv -i ./yaml/incdir.yml
