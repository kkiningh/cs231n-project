set sdc_version 2.0

# Create each clock in the design
create_clock "clock" -name "clock" -period 1

# Input delay
set_input_delay 0.1 -clock "clock" [list a b c]

# Output delay
set_output_delay 0.1 -clock "clock" [list mac]

# Max delay
set_max_delay 10 -from reset
