//
`timescale 1ns/1ps

module test_afifo
 ();

parameter DEPTH = 8, ADDRESS_WIDTH = 3, WIDTH=8;
parameter clk_period  = 2;
parameter half_period = 1;

reg CLK;
reg REN;
reg WEN;
reg RESET;
reg valid;
reg [WIDTH-1:0] Data_in [DEPTH-1:0];
wire [WIDTH-1:0] Data_out [DEPTH-1:0];
wire [DEPTH-1:0] Full_out;
wire [DEPTH-1:0] Empty_out;


MatrixInput #(.DEPTH(DEPTH),.ADDRESS_WIDTH(ADDRESS_WIDTH),.WIDTH(WIDTH)) DUT (
	.CLK(CLK),.valid(valid),.REN(REN),.WEN(WEN),.RESET(RESET),
	.Data_in(Data_in),.Data_out(Data_out),.Full_out(Full_out),.Empty_out(Empty_out));

always begin
        #half_period
       CLK = ~CLK; 
end 

initial begin
	RESET = 1'b1;
	valid = 1'b0;
	REN = 1'b0;
	WEN = 1'b0;
	CLK = 1'b0;
	$dumpfile("test.vcd") ;
     	$dumpvars;

	#20 RESET=1'b0;
	#clk_period 
	for (integer i=0;i<DEPTH;i++) 
			Data_in[i] = 8'haa;	
	
	writeMem();
	
	#clk_period
	for (integer i=0;i<DEPTH;i++) 
			Data_in[i] = 8'hbb;	
	
	writeMem();

	#clk_period
	#clk_period
	#clk_period readMem();
	#clk_period readMem();
	#clk_period
	#clk_period
	#clk_period $finish;

end


task writeMem;
   //input [WIDTH-1:0] wdata [DEPTH-1:0];
   begin
       	WEN = 1; 
       	//D = wdata;
       	#clk_period
       	WEN = 0;     
   end
endtask

task readMem;
   begin
       	REN = 1; 
       	valid = 1;
       	#clk_period
       	REN = 0;
	valid = 0;
             
   end
endtask

endmodule

