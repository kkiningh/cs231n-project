puts "Setting up common variables\n"

# Name of the top-level design
set DESIGN_NAME             "SystolicArray"

# Absolute path prefix for design data.
set DESIGN_REF_DATA_PATH    ""

# List of hierarchical block design names "DesignA DesignB"
set HIERARCHICAL_DESIGNS    ""

# List of hierarchical block cell instance names "u_DesignA u_DesignB"
set HIERARCHICAL_CELLS      ""

# Setup the technology library files
source -echo -verbose "scripts/common/saed32.tcl"

# Setup the RTL files
source -echo -verbose "scripts/common/rtl.tcl"
