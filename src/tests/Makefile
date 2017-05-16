TOPLEVEL := MultiplyAccumulateCell
MODULE   := $(TOPLEVEL)_tb

PWD=$(shell pwd)
COCOTB=$(PWD)/../../cocotb
RTL=$(PWD)/../rtl

# List of Verilog source files
VERILOG_SOURCES = \
	$(RTL)/$(TOPLEVEL).v \
	# $(RTL)/MultiplyAccumulateCell.v

# Use VCS as the simulator
SIM ?= VCS
COMPILE_ARGS = -LDFLAGS -Wl,--no-as-needed

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
