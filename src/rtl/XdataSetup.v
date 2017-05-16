module XdataSetup #(    
    parameter DATA_BITS         = 8,
    parameter MATRIX_SIZE       = 256,
    parameter PAD_SIZE 	= 2*MATRIX_SIZE-1
    ) (
	input clock,
	input reset,
        input [DATA_BITS-1:0] data_in [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
	input shift,
	input load,
	output [DATA_BITS-1:0] data_out [0:MATRIX_SIZE-1]
);


wire [DATA_BITS-1:0] sys_data_out[0:MATRIX_SIZE-1][0:PAD_SIZE-1];

SystolicDataSetupRow #(
   .DATA_BITS(DATA_BITS),
   .MATRIX_SIZE(MATRIX_SIZE),
   .OUTPUT_SIZE(PAD_SIZE)
) XSetup (
    .clock(clock),
    .reset(reset),
    .data_in(data_in),
    .data_out(sys_data_out)
);

ShiftRegister #(
   .DATA_BITS(DATA_BITS),
   .MATRIX_SIZE(MATRIX_SIZE),
   .OUTPUT_SIZE(PAD_SIZE)
) XshiftReg (
    .clock(clock),
    .reset(reset),
    .load(load),
    .shift(shift),
    .data_in(sys_data_out),
    .data_out(data_out)
);

endmodule

