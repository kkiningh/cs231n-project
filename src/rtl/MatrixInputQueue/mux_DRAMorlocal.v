module mux_DRAMorLocal #(parameter DEPTH=8,WIDTH=8) ( data_in_dram, data_in_local, data_from_DRAM, data_out) ;

input wire [WIDTH-1:0] data_in_dram [DEPTH-1:0];
input wire [WIDTH-1:0] data_in_local [DEPTH-1:0];
input wire data_from_DRAM;
output wire [WIDTH-1:0] data_out [DEPTH-1:0];

assign data_out = ( data_from_DRAM ? data_in_dram : data_in_local) ;

endmodule
 

