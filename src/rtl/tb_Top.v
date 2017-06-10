`timescale 1ns/1ps

module tb_Top ();

parameter WIDTH = 8, DEPTH = 256;
parameter clk_period  = 2;
parameter half_period = 1;
//parameter SIZE = 3 ;
`define SIZE = 256
/*integer [7:0] A [2:0][2:0];
integer [7:0] B [2:0][2:0];

integer [7:0] C [2:0][2:0];*/

byte unsigned A[255:0][255:0];
byte unsigned B[255:0][255:0];
byte unsigned C[255:0][255:0];

reg CLK;
reg RESET;
reg RESET_sram;
reg [WIDTH-1:0] data_in_dram [DEPTH-1:0];
reg DRAM;
reg valid;
reg WEN;
reg REN;
reg REN_q;
wire [DEPTH-1:0] Full_out;
wire [DEPTH-1:0] Empty_out;
reg [WIDTH-1:0] w_in [0:DEPTH-1];
reg stall;
reg set_w;

Top ITop (.CLK(CLK), .RESET_sram(RESET_sram),.RESET(RESET),.data_in_dram(data_in_dram),.DRAM(DRAM),.valid(valid),.REN(REN),.WEN(WEN),.Full_out(Full_out),.Empty_out(Empty_out),.w_in(w_in),.stall(stall),.set_w(set_w),.REN_q(REN_q));

always begin
        #half_period
       CLK = ~CLK; 
end

initial begin
	CLK=0;
	RESET = 0;
	RESET_sram=0;
	DRAM=1;
	valid =0;
	REN =0;
	REN_q =0;
	WEN=0;
	stall=0;
	set_w=0;
	for(integer j=0;j<256;j++) begin
			w_in[j] = 8'h00;
			data_in_dram[j] = 8'h00;			
		end
	 $fsdbDumpfile("test.fsdb");
     	 $fsdbDumpvars(0,tb_Top);
		$fsdbDumpMDA(0,tb_Top);
	/*for (integer idx = 0; idx < 256; idx = idx + 1) begin
      		$dumpvars(0, data_in_dram[idx]);
		$dumpvars(0, w_in[idx]);
    	end*/
	randominputs();
	loadInputAndWeights();
	#20
	multiply();
	#50
	REN_q = 1'b1;
	#750 REN_q =1'b0;
	#200 $finish;
end

task randominputs;
for (integer i=0;i<256;i++) begin
		for(integer j=0;j<256;j++) begin
			A[i][j] = $urandom_range(15,0);
			B[i][j] = $urandom_range(15,0);			
		end
	end

	for (integer i=0;i<256;i++) begin
		for(integer j=0;j<256;j++) begin
			C[i][j] = 0;
			for (integer k=0;k<256;k++) begin
				#0 C[i][j] = C[i][j]+ (A[i][k]*B[k][j]);
			end			
		end
	end
endtask


task displayIO;
for (integer i=0;i<256;i++) begin
		for(integer j=0;j<256;j++) begin
			$write("%d\t",A[i][j]);			
		end
		$display("");
	end
	$display("");

	for (integer i=0;i<256;i++) begin
		for(integer j=0;j<256;j++) begin
			$write("%d\t",B[i][j]);			
		end
		$display("");
	end
	$display("");
	for (integer i=0;i<256;i++) begin
		for(integer j=0;j<256;j++) begin
			$write("%d\t",C[i][j]);			
		end
		$display("");
	end
endtask

task loadInputAndWeights;

@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
for(integer i=255,j=0;i>=0;i--,j++) begin
	@(posedge CLK) begin
		set_w <= 1'b1;
		WEN <= 1'b1;
		for(integer k=0,l=255;k<256;k++,l--) begin
			w_in[k] <= B[i][k];
			data_in_dram[l] <= A[k][i];
		end
	end
end

@(posedge CLK) 
	set_w <=1'b0;
	WEN <=1'b0;			

endtask

task multiply;

@(posedge CLK) RESET=1'b1;
@(posedge CLK) RESET=1'b0;
@(posedge CLK) 
	REN <=1'b1;
	valid <= 1'b1;

repeat (256)	begin
	@(posedge CLK) valid <=1'b1;
end

repeat (768)	begin
	@(posedge CLK) valid <= 1'b0;
end


@(posedge CLK)
	valid <= 1'b0;
	REN <= 1'b0;


endtask

endmodule

