module MatrixInput #(parameter DEPTH = 256, ADDRESS_WIDTH =8, WIDTH = 8) ( Data_in, Data_out, valid, CLK, WEN, REN, RESET, Full_out, Empty_out);

input wire [WIDTH-1:0] Data_in [DEPTH-1:0];
output wire [WIDTH-1:0] Data_out [DEPTH-1:0];
output wire [DEPTH-1:0] Full_out;
output wire [DEPTH-1:0] Empty_out;
input wire valid;
input wire CLK;
input wire REN;
input wire WEN;
input wire RESET;

reg [DEPTH-1:0] valid_reg;

always @(posedge CLK) begin
	valid_reg [DEPTH-1:0] <= {valid,valid_reg[DEPTH-1:1]};
end


genvar i;

generate
	for (i=DEPTH-1; i >=0; i=i-1) begin : ROWFIFO
		if (i==DEPTH-1) begin : check
			aFifo #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U
    				(.Data_out(Data_out[i]), 
     				.Empty_out(Empty_out[i]),
     				.ReadEn_in(valid),
     				.RClk(CLK),        
     				.Data_in(Data_in[i]),  
     				.Full_out(Full_out[i]),
     				.WriteEn_in(WEN),
     				.WClk(CLK),
         			.Clear_in(RESET));
		end else begin : NonZero
			aFifo  #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U
    				(.Data_out(Data_out[i]), 
     				.Empty_out(Empty_out[i]),
     				.ReadEn_in(valid_reg[i+1]),
     				.RClk(CLK),        
     				.Data_in(Data_in[i]),  
     				.Full_out(Full_out[i]),
     				.WriteEn_in(WEN),
     				.WClk(CLK),
         			.Clear_in(RESET));
		end
	end
endgenerate


/*AUTOPERL
        for ($e=7; $e>=0; $e--) {
		$t = $e;
		if ($e==7) {
			print "aFifo #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U$e\n";
			print "\t(.Data_out(Data_out[$e]),";
			print ".Empty_out(),";
     			print ".ReadEn_in(REN & valid),\n";
     			print "\t.RClk(CLK),";        
     			print ".Data_in(Data_in[$e]),";  
     			print ".Full_out(),\n";
     			print "\t.WriteEn_in(WEN),";
     			print ".WClk(CLK),";
         		print ".Clear_in(RESET));\n";
			print "\n";
		} else {
			print "aFifo #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U$e\n";
			print "\t(.Data_out(Data_out[$e]),";
			print ".Empty_out(),";
     			print ".ReadEn_in(REN & valid_reg[$t]),\n";
     			print "\t.RClk(CLK),";        
     			print ".Data_in(Data_in[$e]),";  
     			print ".Full_out(),\n";
     			print "\t.WriteEn_in(WEN),";
     			print ".WClk(CLK),";
         		print ".Clear_in(RESET));\n";
			print "\n";
		}
        }
*/

endmodule

