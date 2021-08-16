TCLDIR = tcl
SRCDIR = src

vpath %.tcl	= $(TCLDIR)
vpath %.v	= $(SRCDIR)

all: div64_l8.v dp_addsub_l2.v

%.v: %.tcl
	mkdir -p src
	mkdir -p tcl
	vivado -mode batch -source $(TCLDIR)/$(@:.v=.tcl)
	cp $(@:.v=)/$(@:.v=)_sim_netlist.v $(SRCDIR)/$@

clean:
	rm -rf managed_ip_project
	rm -rf ip_user_files
	rm -f vivado*.log
	rm -f vivado*.jou
	rm -f vivado*.str
	rm -f webtalk*.log
	rm -f webtalk*.jou
	rm -rf src
	rm -rf div64_l8
	rm -rf dp_addsub_l2
