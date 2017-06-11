`timescale 1ns/1ps
`include "test.svh"

module tb_Top ();

parameter WIDTH = 8, DEPTH = 32 , DEPTH2 = 2*DEPTH;
parameter clk_period  = 2;
parameter half_period = 1;
//parameter SIZE = 3 ;
`define SIZE = DEPTH
/*integer [7:0] A [2:0][2:0];
integer [7:0] B [2:0][2:0];

integer [7:0] C [2:0][2:0];*/

byte unsigned A[DEPTH-1:0][DEPTH-1:0];
byte unsigned B[DEPTH-1:0][DEPTH-1:0];
byte unsigned C[DEPTH-1:0][DEPTH-1:0];

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
reg [WIDTH-1:0] temp ;

`TB_ARG_STR(weights, "values.raw/features_layer9_fire_squeeze_Conv2D_eightbit_quantized_conv/1/lhs_169_256.trunc");
`TB_ARG_STR(inputval, "values.raw/features_layer9_fire_squeeze_Conv2D_eightbit_quantized_conv/1/rhs_256_48.trunc");
`TB_ARG_INT(mode, "0");

Top #(.DEPTH(DEPTH),.ADDRESS_WIDTH(5), .WIDTH(WIDTH))ITop (.CLK(CLK), .RESET_sram(RESET_sram),.RESET(RESET),.data_in_dram(data_in_dram),.DRAM(DRAM),.valid(valid),.REN(REN),.WEN(WEN),.Full_out(Full_out),.Empty_out(Empty_out),.w_in(w_in),.stall(stall),.set_w(set_w),.REN_q(REN_q));

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
	for(integer j=0;j<DEPTH;j++) begin
			w_in[j] = 8'h00;
			data_in_dram[j] = 8'h00;			
		end
	 $fsdbDumpfile("test.fsdb");
     	 $fsdbDumpvars(1,Top);
		$fsdbDumpMDA(1,Top);
	/*for (integer idx = 0; idx < DEPTH; idx = idx + 1) begin
      		$dumpvars(0, data_in_dram[idx]);
		$dumpvars(0, w_in[idx]);
    	end*/
	//randominputs();
	TFinputs();
	//loadInputAndWeights();
	if (mode == 1) begin
		loadWeights();
	end else if (mode == 2) begin
		loadInputs();
	end
	else begin
		loadInputAndWeights();
	end
	#20
	multiply();
	#50
	REN_q = 1'b1;
	#DEPTH2 REN_q =1'b0;
	#200 $finish;
end

task randominputs;
for (integer i=0;i<DEPTH;i++) begin
		for(integer j=0;j<DEPTH;j++) begin
			#0 A[i][j] = $urandom_range(DEPTH-1,0);
			#0 B[i][j] = $urandom_range(DEPTH-1,0);			
		end
	end

	for (integer i=0;i<DEPTH;i++) begin
		for(integer j=0;j<DEPTH;j++) begin
			C[i][j] = 0;
			for (integer k=0;k<DEPTH;k++) begin
				#0 C[i][j] = C[i][j]+ (A[i][k]*B[k][j]);
			end			
		end
	end
endtask

task TFinputs;
	integer In_File_ID,In_A,W_File_ID,W_B;
	//In_File_ID = $fopen("values.raw/features_layer9_fire_squeeze_Conv2D_eightbit_quantized_conv/1/lhs_169_DEPTH.trunc", "rb");
	In_File_ID = $fopen(weights,"rb");
	//In_A = $fread(A, In_File_ID);
	//W_File_ID = $fopen("values.raw/features_layer9_fire_squeeze_Conv2D_eightbit_quantized_conv/1/rhs_DEPTH_48.trunc", "rb");
	W_File_ID = $fopen(inputval,"rb");
	//W_B = $fread(B, W_File_ID);


	for (integer i=0;i<DEPTH;i++) begin
		for(integer j=0;j<DEPTH;j++) begin
			$fread(temp,In_File_ID);
			A[i][j] = temp ;
			$fread(temp,W_File_ID);
			B[i][j] = temp ;
		end
	end
	$fclose(In_File_ID);
	$fclose(W_File_ID);


	for (integer i=0;i<DEPTH;i++) begin
		for(integer j=0;j<DEPTH;j++) begin
			C[i][j] = 0;
			for (integer k=0;k<DEPTH;k++) begin
				#0 C[i][j] = C[i][j]+ (A[i][k]*B[k][j]);
			end			
		end
	end
endtask


task displayIO;
for (integer i=0;i<DEPTH-1;i++) begin
		for(integer j=0;j<DEPTH-1;j++) begin
			$write("%d\t",A[i][j]);			
		end
		$display("");
	end
	$display("");

	for (integer i=0;i<DEPTH-1;i++) begin
		for(integer j=0;j<DEPTH-1;j++) begin
			$write("%d\t",B[i][j]);			
		end
		$display("");
	end
	$display("");
	for (integer i=0;i<DEPTH-1;i++) begin
		for(integer j=0;j<DEPTH-1;j++) begin
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
for(integer i=DEPTH-1,j=0;i>=0;i--,j++) begin
	@(posedge CLK) begin
		set_w <= 1'b1;
		WEN <= 1'b1;
		for(integer k=0,l=DEPTH;k<DEPTH-1;k++,l--) begin
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

repeat (DEPTH)	begin
	@(posedge CLK) valid <=1'b1;
end

repeat (2*DEPTH)	begin
	@(posedge CLK) valid <= 1'b0;
end


@(posedge CLK)
	valid <= 1'b0;
	REN <= 1'b0;


endtask


task loadWeights;

@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
for(integer i=DEPTH-1,j=0;i>=0;i--,j++) begin
	@(posedge CLK) begin
		set_w <= 1'b1;
		//WEN <= 1'b1;
		for(integer k=0,l=DEPTH-1;k<DEPTH;k++,l--) begin
			w_in[k] <= B[i][k];
			//data_in_dram[l] <= A[k][i];
		end
	end
end

@(posedge CLK) 
	set_w <=1'b0;
	WEN <=1'b0;			

endtask

task loadInputs;

@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=1; RESET_sram =1'b1;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
@(posedge CLK) RESET=0; RESET_sram =1'b0;
for(integer i=DEPTH-1,j=0;i>=0;i--,j++) begin
	@(posedge CLK) begin
		//set_w <= 1'b1;
		WEN <= 1'b1;
		for(integer k=0,l=DEPTH-1;k<DEPTH;k++,l--) begin
			//w_in[k] <= B[i][k];
			data_in_dram[l] <= A[k][i];
		end
	end
end

@(posedge CLK) 
	set_w <=1'b0;
	WEN <=1'b0;			

endtask

endmodule

