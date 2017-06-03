RTL_DIR := ../src/rtl

RTL_SRC := $(RTL_DIR)/Top.sv $(RTL_DIR)/TopTest.sv
TOP     := Top

# Need to add linker flags if they're not already set
VCS_FLAGS ?= "-LDFLAGS -Wl,--no-as-needed"

$(TOP).test.vcd $(TOP).test.runlog: $(TOP).simv
	./$(TOP).simv -vcd $(TOP).test.vcd -l $(TOP).test.runlog

$(TOP).simv: $(RTL_SRC)
	vcs -full64 -q $(RTL_SRC) -sverilog -o $(TOP).simv $(VCS_FLAGS) -debug_access

.PHONY: clean
clean:
	rm -rf $(TOP).simv $(TOP).simv.daidir
	rm -f $(TOP).test.vcd $(TOP).test.runlog
	rm -f ucli.key
