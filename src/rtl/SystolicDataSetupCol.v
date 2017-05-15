module SystolicDataSetupCol #(
    parameter DATA_BITS         = 8,
    parameter MATRIX_SIZE       = 256,
    parameter OUTPUT_SIZE 	= 2*MATRIX_SIZE-1
) (
    input clock,
    input reset,

    input [DATA_BITS-1:0] data_in [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    output [DATA_BITS-1:0] data_out[0:OUTPUT_SIZE-1][0:MATRIX_SIZE-1]
);

	integer i;
	integer j;
	always @ (posedge clock or posedge reset) begin
		if (reset) begin
  			for( i = 0; i < MATRIX_SIZE; i++ ) 
				for (j=0;j< OUTPUT_SIZE;j++)
   					data_out[j][i] = 8'h00;
		end else begin 
			$display ("New Iteration");
             		for( i = 0; i < MATRIX_SIZE; i++ ) begin
				for( j = 0; j < OUTPUT_SIZE; j++ ) begin
					if (j<i) begin
						data_out[j][i]=8'h00;
						$display("value of data_out[%d][%d] is 0 : 1",j,i);
					end
					else if (j > (i+MATRIX_SIZE-1)) begin
						data_out[j][i]=8'h00;
						$display("value of data_out[%d][%d] is 0 : 2",j,i);
					end
					else    begin
						data_out[j][i] = data_in[i+j][i];
						$display ("value of data_out[%d][%d] is data_in[%d][%d]",j,i,i+j,j );
					end
				end
			end
			$display ("End Iteration");
			$display("\n");
		end
	end

endmodule
