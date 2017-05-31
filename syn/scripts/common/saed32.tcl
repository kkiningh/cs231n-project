puts "Using Synopsys EDK Gate Libraries (6M, 32nm)"

# Set the SAED EDK32 path
if {[info exists ::env(SAED32_EDK_PATH)]} {
    set SAED32_EDK_PATH $::env(SAED32_EDK_PATH)
} else {
    set SAED32_EDK_PATH "/afs/ir.stanford.edu/class/ee/synopsys/physical/SAED32_EDK"
    puts "Warning: Path to SAED32 EDK was not specified in environment."
    puts "         Defaulting to ${SAED32_EDK_PATH}"
}

# This script uses Tcl arrays to describe technology constants.
# Standard library cells are keyed on process corner and voltage.
# Note that not all corners are compatible with all voltages (see table below).
#
# Variable      | Description                       | Values
# --
# $transistor   | Transistor n+p process corner     | ss    | tt    | ff
# $voltage      | Primary voltage                   | 0p70v | 0p78v | 0p85v
#                                                   | 0p75v | 0p85v | 0p95v
#                                                   | 0p95v | 1p05v | 1p16v
#
# Additionally, you can also key on threshold voltage (low, regular, or high)
# and tempurature.
#
# Variable      | Description                       | Values
# --
# $threshold    | Transistor threshold              | lvt, rvt, hvt
# $temperature  | Operating temperature             | 125c, 25c, n40c

set slow_corner_pvt     ss_0p70v_125c
set typical_corner_pvt  tt_0p85v_25c
set fast_corner_pvt     ff_1p16v_n40c

# Set the path of the cell libraries
set DESIGN_REF_PATH      ${SAED32_EDK_PATH}
set DESIGN_REF_TECH_PATH ${SAED32_EDK_PATH}/tech

# Setup some helper variables that map to the set of libraries we want to use
set hvt_libs " \
saed32hvt_tt0p78v125c.db \
saed32hvt_tt0p85v125c.db \
saed32hvt_tt1p05v125c.db \
saed32hvt_ulvl_tt0p78v125c_i0p78v.db \
saed32hvt_ulvl_tt0p85v125c_i0p85v.db \
saed32hvt_ulvl_tt1p05v125c_i0p78v.db \
saed32hvt_dlvl_tt0p78v125c_i0p78v.db \
saed32hvt_dlvl_tt0p85v125c_i0p85v.db \
saed32hvt_pg_tt0p78v125c.db \
saed32hvt_pg_tt0p85v125c.db \
saed32hvt_pg_tt1p05v125c.db \
"

set rvt_libs " \
saed32rvt_tt0p78v125c.db \
saed32rvt_tt0p85v125c.db \
saed32rvt_tt1p05v125c.db \
saed32rvt_ulvl_tt0p78v125c_i0p78v.db \
saed32rvt_ulvl_tt0p85v125c_i0p85v.db \
saed32rvt_ulvl_tt1p05v125c_i0p78v.db \
saed32rvt_dlvl_tt0p78v125c_i0p78v.db \
saed32rvt_dlvl_tt0p85v125c_i0p85v.db \
saed32rvt_pg_tt0p78v125c.db \
saed32rvt_pg_tt0p85v125c.db \
saed32rvt_pg_tt1p05v125c.db \
"

set lvt_libs " \
saed32lvt_tt0p78v125c.db \
saed32lvt_tt0p85v125c.db \
saed32lvt_tt1p05v125c.db
saed32lvt_ulvl_tt0p78v125c_i0p78v.db \
saed32lvt_ulvl_tt0p85v125c_i0p85v.db \
saed32lvt_ulvl_tt1p05v125c_i0p78v.db \
saed32lvt_dlvl_tt0p78v125c_i0p78v.db \
saed32lvt_dlvl_tt0p85v125c_i0p85v.db \
saed32lvt_pg_tt0p78v125c.db \
saed32lvt_pg_tt0p85v125c.db \
saed32lvt_pg_tt1p05v125c.db \
"

set mem_libs " \
saed32sram_tt1p05v125c.db
"

set ADDITIONAL_SEARCH_PATH  " \
${DESIGN_REF_PATH}/lib/stdcell_rvt/db_nldm \
${DESIGN_REF_PATH}/lib/stdcell_hvt/db_nldm \
${DESIGN_REF_PATH}/lib/stdcell_lvt/db_nldm \
${DESIGN_REF_PATH}/lib/io_std/db_nldm/ \
${DESIGN_REF_PATH}/lib/sram/db_nldm/ \
"

# Target technology logical libraries
set TARGET_LIBRARY_FILES        "$hvt_libs $rvt_libs $lvt_libs"

# Extra link logical libraries (e.g. libraries that can be referenced but are
# not targeted) that are not included in TARGET_LIBRARY_FILES
set ADDITIONAL_LINK_LIB_FILES   "$mem_libs"

# List of max-min library paris "max1 min1 max2 min2 ..."
set MIN_LIBRARY_FILES   " \
saed32rvt_ff1p16v125c.db \
saed32rvt_ff1p16vn40c.db \
saed32lvt_ff1p16v125c.db \
saed32lvt_ff1p16vn40c.db \
saed32hvt_ff1p16v125c.db \
saed32hvt_ff1p16vn40c.db \
saed32rvt_pg_ff1p16v125c.db \
saed32rvt_pg_ff1p16vn40c.db \
saed32lvt_pg_ff1p16v125c.db \
saed32lvt_pg_ff1p16vn40c.db \
saed32hvt_pg_ff1p16v125c.db \
saed32hvt_pg_ff1p16vn40c.db \
saed32sram_ff1p16v125c.db \
saed32sram_ff1p16vn40c.db \
saed32sram_ss0p95v125c.db \
saed32sram_tt1p05v25c.db \
saed32io_wb_ff1p16v125c_2p75v.db \
saed32io_wb_ff1p16vn40c_2p75v.db"

# Milkyway reference libraries (Include IC Compiler ILMs here)
set MW_REFERENCE_LIB_DIRS  " \
${DESIGN_REF_PATH}/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m \
${DESIGN_REF_PATH}/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m \
${DESIGN_REF_PATH}/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m \
${DESIGN_REF_PATH}/lib/sram/milkyway/SRAM32NM \
${DESIGN_REF_PATH}/lib/io_std/milkyway/saed32_io_wb \
"

# Reference Control File to define the MW reference libraries
set MW_REFERENCE_CONTROL_FILE ""

# Milkyway technology file
set TECH_FILE "${DESIGN_REF_TECH_PATH}/milkyway/saed32nm_1p9m_mw.tf"

# Mapping file for TLUplus
set MAP_FILE "${DESIGN_REF_TECH_PATH}/star_rcxt/saed32nm_tf_itf_tluplus.map"

# Max conditions
set TLUPLUS_MAX_FILE "${DESIGN_REF_TECH_PATH}/star_rcxt/saed32nm_1p9m_Cmax.tluplus"

# Min conditions
set TLUPLUS_MIN_FILE "${DESIGN_REF_TECH_PATH}/star_rcxt/saed32nm_1p9m_Cmin.tluplus"

# Name of power/ground ports/nets
set MW_POWER_NET   "VDD"
set MW_POWER_PORT  "VDD"
set MW_GROUND_NET  "VSS"
set MW_GROUND_PORT "VSS"

# Max/Min layers for routing
set MIN_ROUTING_LAYER "M2"
set MAX_ROUTING_LAYER "M8"

#### Don't Use File
# Tcl file to prevent Synopsys from considering irrelevent or unneeded library
# components.
set LIBRARY_DONT_USE_FILE                   ""
set LIBRARY_DONT_USE_PRE_COMPILE_LIST       ""
set LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST  ""

##########################################################################################
# Multi-Voltage Common Variables
#
# Define the following MV common variables for the RM scripts for multi-voltage flows.
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

set PD1              ""           ;# Name of power domain/voltage area  1
set PD1_CELLS        ""           ;# Instances to include in power domain/voltage area 1
set VA1_COORDINATES  {}           ;# Coordinates for voltage area 1
set MW_POWER_NET1    "VDD1"       ;# Power net for voltage area 1
set MW_POWER_PORT1   "VDD"        ;# Power port for voltage area 1

set PD2              ""           ;# Name of power domain/voltage area  2
set PD2_CELLS        ""           ;# Instances to include in power domain/voltage area 2
set VA2_COORDINATES  {}           ;# Coordinates for voltage area 2
set MW_POWER_NET2    "VDD2"       ;# Power net for voltage area 2
set MW_POWER_PORT2   "VDD"        ;# Power port for voltage area 2

set PD3              ""           ;# Name of power domain/voltage area  3
set PD3_CELLS        ""           ;# Instances to include in power domain/voltage area 3
set VA3_COORDINATES  {}           ;# Coordinates for voltage area 3
set MW_POWER_NET3    "VDD3"       ;# Power net for voltage area 3
set MW_POWER_PORT3   "VDD"        ;# Power port for voltage area 3

set PD4              ""           ;# Name of power domain/voltage area  4
set PD4_CELLS        ""           ;# Instances to include in power domain/voltage area 4
set VA4_COORDINATES  {}           ;# Coordinates for voltage area 4
set MW_POWER_NET4    "VDD4"       ;# Power net for voltage area 4
set MW_POWER_PORT4   "VDD"        ;# Power port for voltage area 4

puts "Finished loading Synopsys EDK"
