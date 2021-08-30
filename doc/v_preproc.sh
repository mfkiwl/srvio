#!/bin/tcsh

# test script of v_preproc.pl

make dir.yml
make incdir.yml
perl ./scripts/v_preproc.pl -t ./yaml/design \
	-d ../cpu/core/fetch_iag.sv -i ./yaml/incdir.yml
