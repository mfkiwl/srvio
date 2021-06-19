##### Directory
SRCDIR		= src
BUILDDIR	= build
vpath %.s 	= $(SRCDIR)
vpath %.c 	= $(SRCDIR)
vpath %.out	= $(BUILDDIR)
vpath %.dmp	= $(BUILDDIR)
vpath %.prg	= $(BUILDDIR)

##### Datapath size (bit)
DATA		= 64
#DATA		= 32

##### Architecture
ARCH		= riscv$(DATA)

##### Tools
CC 			= $(ARCH)-unknown-elf-gcc
AS 			= $(ARCH)-unknown-elf-as
OBJDUMP		= $(ARCH)-unknown-elf-objdump

all: main.out main.dmp main.prg
allc: main.s main.out main.dmp main.prg

%.s: %.c
	$(CC) -S -o $(SRCDIR)/$@ $<

%.out: %.s
	mkdir -p $(BUILDDIR)
	$(AS) -o $(BUILDDIR)/$@ $<

%.dmp: %.out
	$(OBJDUMP) --disassemble $(BUILDDIR)/$< > $(BUILDDIR)/$@

%.prg: %.dmp
	python3 dmp2prg.py -i $(BUILDDIR)/$< -o $(BUILDDIR)/$@

.PHONY: clean
clean:
	rm -rf ./build
