################################################################################################################################################################
# Example Tcl file for dont_use list to be used with Synopsys DesignWare logic libraries on TSMC16FFC process.
# Script: snpsll_hpdu_synth.tcl
# Version: M-2016.12-SP2 (April 3, 2017)
# Copyright (C) 2007-2017 Synopsys, Inc. All rights reserved.
###################################################################################################################################################################
# The LIBRARY_DONT_USE_PRE_COMPILE_LIST variable automatically points to the snpsll_hpdu_synth.tcl file when the "Synopsys Logic Library" option is set to TRUE.
# Open a SolvNet case for details about the snpsll_hpdu_synth.tcl file and to get additional dont_use lists for standard cell libraries.
###################################################################################################################################################################
remove_attribute [get_lib_cells */*] dont_use

set_dont_use [get_lib_cells */*CKGT*0P*] -power

# Uncomment the below lines to achieve a higher frequency when using Synopsys DesignWare Logic Libraries
#set_dont_use [get_lib_cells */*FSD*]
#set_dont_use [get_lib_cells */*FD*]
#remove_attribute [get_lib_cells */*FSD*QO*] dont_use

set dont_use_list [list *_0P* *_16 *_20 *_24 *_32 *_DEL* *_TIE* *ECO* *MMCK* *_CK_* *LP* *_MM_* *_S_* ]
foreach dont_use ${dont_use_list} {
        echo "[get_attribute [get_lib_cells */${dont_use}] full_name]"
               set_dont_use [get_lib_cells */${dont_use} ]
}
