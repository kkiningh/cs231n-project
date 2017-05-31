remove_attribute [get_lib_cells */*ISO*] dont_use
remove_attribute [get_lib_cells */*ISO*] dont_touch
remove_attribute [get_lib_cells */*HEAD*] dont_touch
remove_attribute [get_lib_cells */*HEAD*] dont_use
remove_attribute [get_lib_cells */*LS*] dont_touch
remove_attribute [get_lib_cells */*LS*] dont_use
remove_attribute [get_lib_cells */*AO*] dont_touch
remove_attribute [get_lib_cells */*AO*] dont_use
remove_attribute -quiet [get_lib_cells */* -filter {is_a_test_cell == true}] dont_use
set_attribute [get_lib_cells */RSDFFARX*_HVT*] dont_use true
set_attribute [get_lib_cells */RSDFFARX*_HVT*] dont_touch true
