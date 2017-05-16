module ShiftRegister #(
    parameter DATA_BITS         = 8,
    parameter MATRIX_SIZE       = 256,
    parameter OUTPUT_SIZE       = 2*MATRIX_SIZE-1
) (
    input clock,
    input reset,
    input load,
    input shift,
    input [DATA_BITS-1:0] data_in [0:MATRIX_SIZE-1][0:OUTPUT_SIZE-1],
    output [DATA_BITS-1:0] data_out [0:MATRIX_SIZE-1]
);

reg [DATA_BITS-1:0] mem [0:MATRIX_SIZE][0:OUTPUT_SIZE-1];
integer i;
integer j;

always @(posedge clock) begin
	if (reset) begin
		for (i=0;i<MATRIX_SIZE;i++)
			for(j=0;j<OUTPUT_SIZE;j++)
				mem[i][j]=8'h00;
	end
        else if (load) begin
		for (i=0;i<MATRIX_SIZE;i++)
			for(j=0;j<OUTPUT_SIZE;j++)
				mem[i][j] <= data_in[i][j];
	end
	else if (shift) begin
		for (i=0;i<MATRIX_SIZE;i++) begin
			data_out[i] <= mem[i][OUTPUT_SIZE-1];
			mem[i][0:OUTPUT_SIZE-1] <= {8'h00,mem[i][0:OUTPUT_SIZE-2]};
		end
	end
end


endmodule
