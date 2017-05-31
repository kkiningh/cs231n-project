source -echo -verbose "scripts/common/common_setup.tcl"
source -echo -verbose "scripts/dc/dc_setup_filenames.tcl"

puts "Running DC Setup\n"

##########################################################################################
# Hierarchical Flow Blocks
#
# If you are performing a hierarchical flow, define the hierarchical designs here.
# List the reference names of the hierarchical blocks.  Cell instance names will
# be automatically derived from the design names provided.
#
# Note: These designs are expected to be unique. There should not be multiple
#       instantiations of physical hierarchical blocks.
#
##########################################################################################

# Each of the hierarchical designs specified in ${HIERARCHICAL_DESIGNS} in the
# common_setup.tcl file should be added to only one of the lists below:

# List of Design Compiler hierarchical design names (.ddc will be read)
set DDC_HIER_DESIGNS ""

# List of Design Compiler block abstraction hierarchical designs (.ddc will be
# read) without transparent interface optimization
set DC_BLOCK_ABSTRACTION_DESIGNS ""

# List of Design Compiler block abstraction hierarchical designs
# with transparent interface optimization
set DC_BLOCK_ABSTRACTION_DESIGNS_TIO    ""

# List of IC Compiler block abstraction hierarchical design names (Milkyway will be read)
set ICC_BLOCK_ABSTRACTION_DESIGNS       ""

#################################################################################
# Setup Variables
#
# Portions of dc_setup.tcl may be used by other tools so program name checks
# are performed where necessary.
#################################################################################

if {$synopsys_program_name != "mvrc" &&
    $synopsys_program_name != "vsi" &&
    $synopsys_program_name != "vcst"} {

    # The following setting removes new variable info messages from the end of the log file
    set_app_var sh_new_variable_message false
}

if {$synopsys_program_name == "dc_shell" || $synopsys_program_name == "de_shell"} {
    ####
    # Design Compiler and DC Explorer Setup Variables
    ####

    # Use the set_host_options command to enable multicore optimization to improve runtime.
    set_host_options -max_cores 8

    # Change alib_library_analysis_path to point to a central cache of analyzed libraries
    # to save runtime and disk space.  The following setting only reflects the
    # default value and should be changed to a central location for best results.
    set_app_var alib_library_analysis_path .

    # In cases where RTL has VHDL generate loops or SystemVerilog structs, switching
    # activity annotation from SAIF may be rejected, the following variable setting
    # improves SAIF annotation, by making sure that synthesis object names follow same
    # naming convention as used by RTL simulation.
    set_app_var hdlin_enable_upf_compatible_naming true

    # By default the tool will create supply set handles. If your UPF has domain dependent
    # supply nets, please uncomment the following line:
    # set_app_var upf_create_implicit_supply_sets false

    # Add any additional Design Compiler variables needed here

    #################################################################################
    # DC Explorer Specific Setup Variables
    #################################################################################

    if {[shell_is_in_exploration_mode]} {
        # Uncomment the following setting to use top-level signal ports instead of a
        # isolation power controller.
        # set_app_var upf_auto_iso_enable_source top_level_port

        # Uncomment the following setting to allow DC Explorer to perform optimization with
        # physical design data.
        # set_app_var de_enable_physical_flow true

        # Add any additional DC Explorer variables needed here
  }
}

# Type of optimization to perform
set OPTIMIZATION_FLOW "hplp"

# Location of design and analysis files from output of Design Compiler
set REPORTS_DIR "dc/work/reports"
set RESULTS_DIR "dc/work/results"

file mkdir ${REPORTS_DIR}
file mkdir ${RESULTS_DIR}

#################################################################################
# Search Path Setup
#
# Set up the search path to find the libraries and design files.
#################################################################################
set_app_var search_path ". ${ADDITIONAL_SEARCH_PATH} $search_path"

# For a hierarchical flow, add the following directory to the search path to
# find the floorplan, voltage area definitions, and SDC budgets from IC Compiler.
# Note: The floorplan files from IC Compiler are named ${DESIGN_NAME}.DCT.def and
#       ${DESIGN_NAME}.DCT.fp. You should choose your floorplan file and name it
#       to ${DESIGN_NAME}.def or ${DESIGN_NAME}.fp for Design Compiler.
lappend search_path ./icc/work/DC

# For a hierarchical flow, add the block-level results directories to the
# search path to find the block-level design files.
set HIER_DESIGNS "\
${DDC_HIER_DESIGNS} \
${DC_BLOCK_ABSTRACTION_DESIGNS} \
${DC_BLOCK_ABSTRACTION_DESIGNS_TIO} \
"

foreach design $HIER_DESIGNS {
    lappend search_path "../${design}/dc/work/results"
}

# For a hierarchical UPF flow, add the results directory to the search path for
# Formality to find the output UPF files.
lappend search_path ${RESULTS_DIR}

#################################################################################
# Library Setup
#
# This section is designed to work with the settings from common_setup.tcl
# without any additional modification.
#################################################################################

if {$synopsys_program_name != "mvrc" &&
    $synopsys_program_name != "vsi" &&
    $synopsys_program_name != "vcst"} {

  # Milkyway variable settings

  # Make sure to define the Milkyway library variable
  # mw_design_library, it is needed by write_milkyway command

  set mw_reference_library ${MW_REFERENCE_LIB_DIRS}
  set mw_design_library ${RESULTS_DIR}/${DCRM_MW_LIBRARY_NAME}

  set mw_site_name_mapping { {CORE unit} {Core unit} {core unit} }
}

if {$synopsys_program_name == "mvrc"}  {
  set_app_var link_library "$TARGET_LIBRARY_FILES $ADDITIONAL_LINK_LIB_FILES"
}

if {$synopsys_program_name == "vsi" || $synopsys_program_name == "vcst"}  {
  set_app_var link_library "$TARGET_LIBRARY_FILES $ADDITIONAL_LINK_LIB_FILES"
}

if {$synopsys_program_name == "dc_shell" || $synopsys_program_name == "de_shell"} {
    # The target_library is the set of cells we want the tools to emit after
    # synthesis (e.g that our RTL gets "mapped to". This should be the gates
    # that can actually be physically manufactured in our process.
    set_app_var target_library ${TARGET_LIBRARY_FILES}

    # The synthetic_library is the name of the Designware libraries to use.
    #
    # Designware libraries are special, highly optimized implementations of
    # common operations (e.g *, +, registers, etc) that the Synopsys tool
    # can map to during optimization passes.
    set_app_var synthetic_library "dw_foundation.sldb"

    # The link_library tells the Synopsys tools where to look for the definitions
    # of module instances.
    #
    # The "*" at the begining tells the tools to first look in memory (ie. in the
    # previously analyzed Verilog files).
    set_app_var link_library \
        "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"

    # Setup min libraries if they exist
    foreach {max_library min_library} $MIN_LIBRARY_FILES {
        set_min_library $max_library -min_version $min_library
    }

    # Set the variable to use Verilog libraries for Test Design Rule Checking
    # (See dc.tcl for details)
    # set_app_var test_simulation_library <list of Verilog library files>

    if {[shell_is_in_topographical_mode]} {
        # If we want extended support for 4095 layers, uncomment the following line
        # before creating the Milkyway library.
        # Note that this is permanent and cannot be reverted.
        # extend_mw_layers

        # Only create new Milyway design library if it doesn't exist
        if {![file isdirectory $mw_design_library]} {
            create_mw_lib \
                -technology $TECH_FILE \
                -mw_reference_library $mw_reference_library \
                $mw_design_library
        } else {
            # If it does exist, make sure it's consistant with reference library
            set_mw_lib_reference $mw_design_library \
                -mw_reference_library $mw_reference_library
        }

        open_mw_lib $mw_design_library

        set_check_library_options -upf
        check_library > ${REPORTS_DIR}/${DCRM_CHECK_LIBRARY_REPORT}

        set_tlu_plus_files \
            -max_tluplus $TLUPLUS_MAX_FILE \
            -min_tluplus $TLUPLUS_MIN_FILE \
            -tech2itf_map $MAP_FILE

        check_tlu_plus_files
    }

    ####
    # Library modifications (apply after libraries are loaded
    ####
    if {[file exists [which ${LIBRARY_DONT_USE_FILE}]]} {
        source -echo -verbose ${LIBRARY_DONT_USE_FILE}
    } else {
        puts "Library Don't Use file not found: ${LIBRARY_DONT_USE_FILE}"
    }

    # Tcl file for Synopsys Logic Library don't use list
    set LIBRARY_DONT_USE_PRE_COMPILE_LIST "scripts/dc/snpsll_hpdu_synth.tcl"
}

puts "End DC Setup"
