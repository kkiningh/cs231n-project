`timescale 1ns/1ps

module Top #(parameter DEPTH = 256, ADDRESS_WIDTH =8, WIDTH = 8) (CLK, RESET_sram,RESET,data_in_dram,DRAM,valid,REN,WEN,Full_out,Empty_out,w_in,stall,set_w);


wire [WIDTH-1:0] wire_inputtoarray [DEPTH-1:0];
wire [WIDTH-1:0] wire_arraytoaccq [DEPTH-1:0];
wire [WIDTH-1:0] wire_accqtomux [DEPTH-1:0];
wire [WIDTH-1:0] wire_muxdatatoinput [DEPTH-1:0];
input wire CLK;
input wire RESET;
input wire RESET_sram;
input wire [WIDTH-1:0] data_in_dram [DEPTH-1:0];
input wire DRAM;
input valid;
input WEN;
input REN;
input [DEPTH-1:0] Full_out;
input [DEPTH-1:0] Empty_out;
input [WIDTH-1:0] w_in [0:DEPTH-1];
input stall;
input set_w;

MatrixInput_sram #(.DEPTH(DEPTH), .ADDRESS_WIDTH(ADDRESS_WIDTH),.WIDTH(WIDTH)) MI_SRAM ( .Data_in(wire_muxdatatoinput),.Data_out(wire_inputtoarray), .valid(valid), .CLK(CLK), .WEN(WEN), .REN(REN), .RESET(RESET_sram), .Full_out(Full_out), .Empty_out(Empty_out));

SystolicArray #(.WIDTH(DEPTH),.HEIGHT(DEPTH),.D_BITS(WIDTH),.W_BITS(WIDTH),.A_BITS(WIDTH)) INST_SYSARRAY (.clock(CLK),.reset(RESET),.set_w,.stall,.d_in(wire_inputtoarray),.w_in(w_in) ,.a_out(wire_arraytoaccq));

shiftreg #(.DEPTH(DEPTH),.WIDTH(WIDTH)) INST_ACCREG (.data_in(wire_arraytoaccq),.data_out(wire_accqtomux),.CLK(CLK),.RESET(RESET));

mux_DRAMorLocal #(.DEPTH(DEPTH),.WIDTH(WIDTH)) INST_DATAMUX (.data_in_dram(data_in_dram), .data_in_local(wire_accqtomux),.data_from_DRAM(DRAM),.data_out(wire_muxdatatoinput)) ;

endmodule


//==========================================
// Function : Code Gray counter.
//=======================================


module GrayCounter
   #(parameter   COUNTER_WIDTH = 4)
   
    (output reg  [COUNTER_WIDTH-1:0]    GrayCount_out,  //'Gray' code count output.
    
     input wire                         Enable_in,  //Count enable.
     input wire                         Clear_in,   //Count reset.
    
     input wire                         Clk);

    /////////Internal connections & variables///////
    reg    [COUNTER_WIDTH-1:0]         BinaryCount;

    /////////Code///////////////////////
    
    always @ (posedge Clk)
        if (Clear_in) begin
            BinaryCount   <= {COUNTER_WIDTH{1'b 0}} + 1;  //Gray count begins @ '1' with
            GrayCount_out <= {COUNTER_WIDTH{1'b 0}};      // first 'Enable_in'.
        end
        else if (Enable_in) begin
            BinaryCount   <= BinaryCount + 1;
            GrayCount_out <= {BinaryCount[COUNTER_WIDTH-1],
                              BinaryCount[COUNTER_WIDTH-2:0] ^ BinaryCount[COUNTER_WIDTH-1:1]};
        end
    
endmodule
//EndModule
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

//EndModule
module MatrixInput_sram #(parameter DEPTH = 256, ADDRESS_WIDTH =8, WIDTH = 8) ( Data_in, Data_out, valid, CLK, WEN, REN, RESET, Full_out, Empty_out);

input wire [WIDTH-1:0] Data_in [DEPTH-1:0];
output wire [WIDTH-1:0] Data_out [DEPTH-1:0];
wire [WIDTH-1:0] Data_out_t [DEPTH-1:0];
output wire [DEPTH-1:0] Full_out;
output wire [DEPTH-1:0] Empty_out;
input wire valid;
input wire CLK;
input wire REN;
input wire WEN;
input wire RESET;

reg [DEPTH-1:0] valid_reg;

always @(posedge CLK or posedge RESET) begin
	if (RESET) begin
		valid_reg <= {256{1'b0}};
	end else begin
		valid_reg [DEPTH-1:0] <= {valid,valid_reg[DEPTH-1:1]};
	end
end


genvar i;

generate
	for (i=DEPTH-1; i >=0; i=i-1) begin : ROWFIFO
		if (i==DEPTH-1) begin : check
			aFifo_256x8 #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U
    				(.Data_out(Data_out_t[i]), 
     				.Empty_out(Empty_out[i]),
     				.ReadEn_in(valid),
     				.RClk(CLK),        
     				.Data_in(Data_in[i]),  
     				.Full_out(Full_out[i]),
     				.WriteEn_in(WEN),
     				.WClk(CLK),
         			.Clear_in(RESET));
			assign Data_out[i] = Data_out_t[i] & {8{valid}};
		end else begin : NonZero
			aFifo_256x8  #(.DATA_WIDTH(WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U
    				(.Data_out(Data_out_t[i]), 
     				.Empty_out(Empty_out[i]),
     				.ReadEn_in(valid_reg[i+1]),
     				.RClk(CLK),        
     				.Data_in(Data_in[i]),  
     				.Full_out(Full_out[i]),
     				.WriteEn_in(WEN),
     				.WClk(CLK),
         			.Clear_in(RESET));
			assign Data_out[i] = Data_out_t[i] & {8{valid_reg[i+1]}}; 
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

//EndModule
module Mac #(
    parameter D_BITS = 8,
    parameter W_BITS = 8,
    parameter A_BITS = 16
) (
    input clock,
    input reset,

    input set_w,
    input stall,

    input [A_BITS-1:0] a_in,
    input [D_BITS-1:0] d_in,

    output reg [A_BITS-1:0] a_out,
    output reg [D_BITS-1:0] d_out
);
    reg [W_BITS-1:0] w;
    always @(posedge clock) begin
        if (reset) begin
            //w     <= {W_BITS{1'b0}};
            a_out <= {A_BITS{1'b0}};
            d_out <= {D_BITS{1'b0}};
        end else if (!stall) begin
            if (set_w) begin
                w     <= a_in;
                a_out <= a_in;
            end else begin
                a_out <= d_in * w + a_in;
                d_out <= d_in;
            end
        end
    end
endmodule

module SystolicArray #(
    parameter WIDTH  = 4,
    parameter HEIGHT = 4,
    parameter D_BITS = 1,
    parameter W_BITS = 1,
    parameter A_BITS = 16
) (
    input clock,
    input reset,

    input set_w,
    input stall,

    input [D_BITS-1:0] d_in [0:HEIGHT-1],
    input [W_BITS-1:0] w_in [0:WIDTH-1],

    output [A_BITS-1:0] a_out [0:WIDTH-1]
);
    genvar i, j;
    generate for (i = 0; i < HEIGHT; i = i + 1) begin : Row
        for (j = 0; j < WIDTH; j = j + 1) begin : Column
            wire [A_BITS-1:0] a_in_row, a_out_row;
            wire [D_BITS-1:0] d_in_col, d_out_col;

            // Special case first row
            if (i == 0) begin : RowEdge
                assign a_in_row = set_w ? w_in[i] : {A_BITS{1'b0}};
            end else begin : RowNonEdge
                assign a_in_row = Row[i-1].Column[j].a_out_row;
            end

            // Special case first row
            if (j == 0) begin
                assign d_in_col = d_in[i];
            end else begin
                assign d_in_col = Row[i].Column[j-1].d_out_col;
            end

            Mac #(.D_BITS(D_BITS), .W_BITS(W_BITS), .A_BITS(A_BITS)) mac (
                .clock(clock),
                .reset(reset),
                .set_w(set_w),
                .stall(stall),

                .a_in(a_in_row),
                .d_in(d_in_col),
                .a_out(a_out_row),
                .d_out(d_out_col)
            );
        end
    end endgenerate

    generate for (j = 0; j < WIDTH; j = j + 1) begin : ColumnOut
        assign a_out[j] = Row[HEIGHT-1].Column[j].a_out_row;
    end endgenerate
endmodule

module AccumulateQueue #(
    parameter A_BITS = 32,
    parameter FIFO_LENGTH = 8,

    /* Number of bits needed to index into the queue */
    parameter INDEX_BITS = $clog2(FIFO_LENGTH)
) (
    input clock,
    input reset,

    input stall,

    input [A_BITS-1:0] a_in,

    output [A_BITS-1:0] a_out
);
    /*
    The accumulation queue stores the results of the systolic array and adds
    it to previous partial products.

    In particular, on each cycle we read the previous partial product from
    the end of the fifo and add the value emitted from systolic array.
    Then, on the next cycle we write the value to the front of the queue.

    The way this is actually implemented is that we have two SRAMs - odd and
    even. When the index is even, we write last cycle's partial product to the
    even queue, and read the next partial product from the odd queue.

    This is reversed when the index is odd.
    */
    reg [A_BITS-1:0] fifo_e [0:(FIFO_LENGTH/2)-1];
    reg [A_BITS-1:0] fifo_o [0:(FIFO_LENGTH/2)-1];
    reg [A_BITS-1:0] head;
    reg [INDEX_BITS-1:0] index;

    /* Set the fifo to zero on reset */
    integer i;
    always @(posedge clock) begin
        if (reset) begin
            for (i = 0; i < FIFO_LENGTH; i = i + 1) begin
                fifo_e[i] <= {A_BITS{1'b0}};
                fifo_o[i] <= {A_BITS{1'b0}};
            end

            head  <= {A_BITS{1'b0}};
            index <= {INDEX_BITS{1'b0}};
        end
    end

    /* The next index is just the current index + 1 */
    wire [INDEX_BITS-1:0] index_next = index + 1;

    /* The fifo index is just the top INDEX_BITS-1 bits */
    wire [INDEX_BITS-2:0] fifo_index = index[INDEX_BITS-1:1];
    wire [INDEX_BITS-2:0] fifo_index_next = index_next[INDEX_BITS-1:1];

    /* Index is odd if the last bit is 1 */
    wire odd = index[0];

    always @(posedge clock) begin
        if (!reset && !stall) begin
            if (odd) begin
                /* If odd, write to the odd queue... */
                fifo_o[fifo_index] <= head + a_in;

                /* ...and read from the even queue */
                head <= fifo_e[fifo_index_next];
            end else begin
                /* If even, write to the even queue... */
                fifo_e[fifo_index] <= head + a_in;

                /* ...and read from the odd queue */
                head <= fifo_o[fifo_index_next];
            end

            index <= index_next;
        end
    end

    /* Output is just the head of the queue */
    assign a_out = head;
endmodule
//EndModule
//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================


module aFifo
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 8,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output reg  [DATA_WIDTH-1:0]        Data_out, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    always @ (posedge RClk)
        if (ReadEn_in & !Empty_out)
            Data_out <= Mem[pNextWordToRead];
            
    //'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    GrayCounter #(ADDRESS_WIDTH) GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(WClk)
       );
       
    GrayCounter #(ADDRESS_WIDTH) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, Clear_in) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | Clear_in)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    //'Full_out' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    always @ (posedge WClk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            Full_out <= 1;
        else
            Full_out <= 0;
            
    //'Empty_out' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge RClk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            Empty_out <= 1;
        else
            Empty_out <= 0;
            
endmodule
//EndModule
//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================


module aFifo_256x8
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 8,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output reg  [DATA_WIDTH-1:0]        Data_out, 
     output reg                          Empty_out,
     input wire                          ReadEn_in,
     input wire                          RClk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        Data_in,  
     output reg                          Full_out,
     input wire                          WriteEn_in,
     input wire                          WClk,
	 
     input wire                          Clear_in);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'Data_out' logic:
    /*	Begin Comment
  	always @ (posedge RClk)
        if (ReadEn_in & !Empty_out)
            Data_out <= Mem[pNextWordToRead];
            
    //'Data_in' logic:
    always @ (posedge WClk)
        if (WriteEn_in & !Full_out)
            Mem[pNextWordToWrite] <= Data_in;
    End Comment */

    // Synopsys SRAM memory usage A1: ReadPort , A2 : WritePort
    wire   [DATA_WIDTH-1:0]        temp;
    wire   [DATA_WIDTH-1:0]        Lsb_Data_out;
    wire   [DATA_WIDTH-1:0]        Msb_Data_out;
    wire   read_LsbEn , read_MsbEn, write_MsbEn, write_Lsben;

    assign read_LsbEn = ~pNextWordToRead[7];
    assign read_MsbEn = pNextWordToRead[7];
    assign write_LsbEn = ~pNextWordToWrite[7];
    assign write_MsbEn = pNextWordToWrite[7];
    
    assign Data_out = (read_LsbEn ? Lsb_Data_out : Msb_Data_out); 
 
    SRAM2RW128x8 INST_LSB_SRAM2RW128x8 (.A1(pNextWordToRead[6:0]),
				    .A2(pNextWordToWrite[6:0]),
				    .CE1(RClk & read_LsbEn),
				    .CE2(WClk & write_LsbEn),
				    .WEB1(NextReadAddressEn),
				    .WEB2(~NextWriteAddressEn),
				    .OEB1(1'b0),
				    .OEB2(1'b1),
				    .CSB1(~NextReadAddressEn),
				    .CSB2(~NextWriteAddressEn),
				    .I1(8'h00),
				    .I2(Data_in),
				    .O1(Lsb_Data_out),
				    .O2(temp));

    SRAM2RW128x8 INST_MSB_SRAM2RW128x8 (.A1(pNextWordToRead[6:0]),
                                    .A2(pNextWordToWrite[6:0]),
                                    .CE1(RClk & read_MsbEn),
                                    .CE2(WClk & write_MsbEn),
                                    .WEB1(NextReadAddressEn),
                                    .WEB2(~NextWriteAddressEn),
                                    .OEB1(1'b0),
                                    .OEB2(1'b1),
                                    .CSB1(~NextReadAddressEn),
                                    .CSB2(~NextWriteAddressEn),
                                    .I1(8'h00),
                                    .I2(Data_in),
                                    .O1(Msb_Data_out),
                                    .O2(temp));


    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = WriteEn_in & ~Full_out;
    assign NextReadAddressEn  = ReadEn_in  & ~Empty_out;
           
    //Addreses (Gray counters) logic:
    GrayCounter #(ADDRESS_WIDTH) GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(Clear_in),
        
        .Clk(WClk)
       );
       
    GrayCounter #(ADDRESS_WIDTH) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(Clear_in),
        .Clk(RClk)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, Clear_in) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | Clear_in)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    //'Full_out' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    always @ (posedge WClk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            Full_out <= 1;
        else
            Full_out <= 0;
            
    //'Empty_out' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge RClk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            Empty_out <= 1;
        else
            Empty_out <= 0;
            
endmodule
//EndModule
module mux_DRAMorLocal #(parameter DEPTH=8,WIDTH=8) ( data_in_dram, data_in_local, data_from_DRAM, data_out) ;

input wire [WIDTH-1:0] data_in_dram [DEPTH-1:0];
input wire [WIDTH-1:0] data_in_local [DEPTH-1:0];
input wire data_from_DRAM;
output wire [WIDTH-1:0] data_out [DEPTH-1:0];

assign data_out = ( data_from_DRAM ? data_in_dram : data_in_local) ;

endmodule
 

//EndModule
/*********************************************************************
*  SAED_EDK90nm_SRAM : SRAM2RW128x8 Verilog description                 *
*  ---------------------------------------------------------------   *
*  Filename      : SRAM2RW128x8.v                                       *
*  SRAM name     : SRAM2RW128x8                                         *
*  Word width    : 8     bits                                        *
*  Word number   : 128                                               *
*  Adress width  : 7     bits                                        *
**********************************************************************/


`define numAddr 7
`define numWords 128
`define wordLength 8



module SRAM2RW128x8 (A1,A2,CE1,CE2,WEB1,WEB2,OEB1,OEB2,CSB1,CSB2,I1,I2,O1,O2);

input 				CE1;
input 				CE2;
input 				WEB1;
input 				WEB2;
input 				OEB1;
input 				OEB2;
input 				CSB1;
input 				CSB2;

input 	[`numAddr-1:0] 		A1;
input 	[`numAddr-1:0] 		A2;
input 	[`wordLength-1:0] 	I1;
input 	[`wordLength-1:0] 	I2;
output 	[`wordLength-1:0] 	O1;
output 	[`wordLength-1:0] 	O2;

/*reg   [`wordLength-1:0]   	memory[`numWords-1:0];*/
/*reg  	[`wordLength-1:0]	data_out1;*/
/*reg  	[`wordLength-1:0]	data_out2;*/
wire 	[`wordLength-1:0] 	O1;
wire  	[`wordLength-1:0]	O2;
	
wire 				RE1;
wire 				RE2;	
wire 				WE1;	
wire 				WE2;

SRAM2RW128x8_1bit sram_IO0 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[0], I2[0], O1[0], O2[0]);
SRAM2RW128x8_1bit sram_IO1 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[1], I2[1], O1[1], O2[1]);
SRAM2RW128x8_1bit sram_IO2 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[2], I2[2], O1[2], O2[2]);
SRAM2RW128x8_1bit sram_IO3 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[3], I2[3], O1[3], O2[3]);
SRAM2RW128x8_1bit sram_IO4 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[4], I2[4], O1[4], O2[4]);
SRAM2RW128x8_1bit sram_IO5 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[5], I2[5], O1[5], O2[5]);
SRAM2RW128x8_1bit sram_IO6 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[6], I2[6], O1[6], O2[6]);
SRAM2RW128x8_1bit sram_IO7 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[7], I2[7], O1[7], O2[7]);


endmodule


module SRAM2RW128x8_1bit (CE1_i, CE2_i, WEB1_i, WEB2_i,  A1_i, A2_i, OEB1_i, OEB2_i, CSB1_i, CSB2_i, I1_i, I2_i, O1_i, O2_i);

input 	CSB1_i, CSB2_i;
input 	OEB1_i, OEB2_i;
input 	CE1_i, CE2_i;
input 	WEB1_i, WEB2_i;

input 	[`numAddr-1:0] 	A1_i, A2_i;
input 	[0:0] I1_i, I2_i;

output 	[0:0] O1_i, O2_i;

reg 	[0:0] O1_i, O2_i;
reg    	[0:0]  	memory[`numWords-1:0];
reg  	[0:0]	data_out1, data_out2;


and u1 (RE1, ~CSB1_i,  WEB1_i);
and u2 (WE1, ~CSB1_i, ~WEB1_i);
and u3 (RE2, ~CSB2_i,  WEB2_i);
and u4 (WE2, ~CSB2_i, ~WEB2_i);

//Primary ports

always @ (posedge CE1_i) 
	if (RE1)
		data_out1 = memory[A1_i];
always @ (posedge CE1_i) 
	if (WE1)
		memory[A1_i] = I1_i;
		

always @ (data_out1 or OEB1_i)
	if (!OEB1_i) 
		O1_i = data_out1;
	else
		O1_i =  1'bz;

//Dual ports	
always @ (posedge CE2_i)
  	if (RE2)
		data_out2 = memory[A2_i];
always @ (posedge CE2_i)
	if (WE2)
		memory[A2_i] = I2_i;
		
always @ (data_out2 or OEB2_i)
	if (!OEB2_i) 
		O2_i = data_out2;
	else
		O2_i = 1'bz;

endmodule
//EndModule
module shiftreg #(parameter DEPTH = 8, WIDTH = 8) (data_in,data_out,CLK,RESET);

input wire [WIDTH-1:0] data_in [DEPTH-1:0];
output reg [WIDTH-1:0] data_out [DEPTH-1:0];
reg [WIDTH-1:0] stage1 [DEPTH-1:0];
reg [WIDTH-1:0] stage2 [DEPTH-1:0];
input CLK;
input RESET;

always @(posedge CLK) begin
	if (RESET) begin
		for(integer i=0;i<DEPTH;i++) begin
			stage1[i] <= {(WIDTH){1'b0}};
		end
	end else begin
		stage1 <= data_in;
		stage2 <= stage1;
		data_out <= stage2;
	end

end

endmodule
//EndModule
//

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

//EndModule
//

module test_afifo_sram ();

parameter DEPTH =256, ADDRESS_WIDTH = 8, WIDTH=8;
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


MatrixInput_sram #(.DEPTH(DEPTH),.ADDRESS_WIDTH(ADDRESS_WIDTH),.WIDTH(WIDTH)) DUT (
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

//EndModule
