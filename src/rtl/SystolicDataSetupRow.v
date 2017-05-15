module SystolicDataSetupRow #(
    parameter DATA_BITS         = 8,
    parameter MATRIX_SIZE       = 256,
    parameter OUTPUT_SIZE 	= 2*MATRIX_SIZE-1
) (
    input clock,
    input reset,

    input [DATA_BITS-1:0] data_in [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1],
    output [DATA_BITS-1:0] data_out[0:MATRIX_SIZE-1][0:OUTPUT_SIZE-1]
);

	integer i;
	integer j;
	always @ (posedge clock or posedge reset) begin
		if (reset) begin
  			for( i = 0; i < MATRIX_SIZE; i++ ) 
				for (j=0;j< OUTPUT_SIZE;j++)
   					data_out[i][j] = 8'h00;
		end else begin 
			$display ("New Iteration");
             		for( i = 0; i < MATRIX_SIZE; i++ ) begin
				for( j = 0; j < OUTPUT_SIZE; j++ ) begin
					if (j<i) begin
						data_out[i][j]=8'h00;
						$display("value of data_out[%d][%d] is 0 : 1",i,j);
					end
					else if (j > (i+MATRIX_SIZE-1)) begin
						data_out[i][j]=8'h00;
						$display("value of data_out[%d][%d] is 0 : 2",i,j);
					end
					else    begin
						data_out[i][j] = data_in[i][i+j];
						$display ("value of data_out[%d][%d] is data_in[%d][%d]",i,j,i,i+j );
					end
				end
			end
			$display ("End Iteration");
			$display("\n");
		end
	end

endmodule
