module Top;
    reg clock = 1'b0;
    reg reset = 1'b1;

    /* Toggle clock every 10 steps */
    always clock <= #10 ~clock;

    /* DUT */
    localparam A_BITS      = 32;
    localparam FIFO_LENGTH = 8;
    reg stall = 1'b1;
    reg  [A_BITS-1:0] a_in = {A_BITS{1'b0}};
    wire [A_BITS-1:0] a_out;
    //# AccumulateQueue #(
    //#     .A_BITS(A_BITS),
    //#     .FIFO_LENGTH(FIFO_LENGTH)
    //# ) dut (
    //#     .clock(clock),
    //#     .reset(reset),

    //#     .stall(stall),
    //#     .a_in(a_in),
    //#     .a_out(a_out)
    //# );
    Test #(
         .A_BITS(A_BITS),
         .FIFO_LENGTH(FIFO_LENGTH)
    ) dut (
        .clock(clock),
        .reset(reset),
        .stall(stall),
        .a_in(a_in),
        .a_out(a_out)
    );

    /* Actual test program */
    integer i;
    initial begin
        $vcdpluson;
        $display("Simulation begining");

        /* Release reset after 10 cycles */
        #100 reset <= 1'b0;
        $display("Reset released");

        stall <= 0;

        for (i = 0; i < FIFO_LENGTH; i = i + 1) begin
            $display("Sending %d", i);
            a_in  <= i;
            #10;
        end

        for (i = 0; i < FIFO_LENGTH; i = i + 1) begin
            $display("Got %d", a_out);
            #10;
        end

        $finish;
    end
endmodule

module Test #(
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

    reg [A_BITS-1:0] fifo_e [0:(FIFO_LENGTH/2)-1];
    reg [A_BITS-1:0] fifo_o [0:(FIFO_LENGTH/2)-1];
    reg [A_BITS-1:0] head;
    reg [INDEX_BITS-1:0] index;

    /* Set the fifo to zero on reset */
    //integer i;
    //always @(posedge clock) begin
    //    if (reset) begin
    //        for (i = 0; i < 1; i = i + 1) begin
    //            fifo_e[i] <= {A_BITS{1'b0}};
    //            fifo_o[i] <= {A_BITS{1'b0}};
    //        end

    //        head  <= {A_BITS{1'b0}};
    //        index <= {INDEX_BITS{1'b0}};
    //    end
    //end

    /* Output is just the head of the queue */
    assign a_out = head;
endmodule
