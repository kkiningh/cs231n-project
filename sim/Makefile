RTL_DIR := ../src/rtl
RTL_TB  := $(RTL_DIR)/TopTest.sv
RTL_SRC := $(RTL_DIR)/Top.sv

### Naming setup
TOP ?= Top
TB  ?= $(basename $(basename $(notdir $(RTL_TB))))

### Setup for VCS
# Need to add linker flags if they're not already set
VCS			?= vcs -full64 -LDFLAGS -Wl,--no-as-needed
VCS_OPTIONS += -debug_access+all
VCS_OPTIONS += -q -notice
VCS_OPTIONS += -j8
VCS_OPTIONS += -sverilog

VCS			:= $(strip $(VCS))
VCS_OPTIONS := $(strip $(VCS_OPTIONS))

### Acutal build rules
build/$(TOP).$(TB).simv: $(RTL_TB) $(RTL_SRC)
	@mkdir -p $(dir $@)
	$(VCS) $(VCS_OPTIONS) \
		-o $@ $^ \
		-Mdir=$@-csrc \
		-top $(TOP)

build/$(TOP).$(TB).vcd: build/$(TOP).$(TB).simv
	@mkdir -p $(dir $@)
	$^ +vpdfile+$@ -k $@-ucli.key

.PHONY: clean
clean:
	rm -r build
