TOPLEVEL := MultiplyAccumulateCell
MODULE   := $(TOPLEVEL)_tb

PWD=$(shell pwd)
COCOTB=$(PWD)/../../cocotb

VERILOG_SOURCES= $(PWD)/../rtl/$(TOPLEVEL).v

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
