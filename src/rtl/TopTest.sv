module Top;
    reg clock = 1'b0;
    reg reset = 1'b1;

    /* Toggle clock every 10 steps */
    always #10 clock <= ~clock;

    /* DUT */
    localparam A_BITS      = 32;
    localparam FIFO_LENGTH = 8;
    reg stall = 1'b1;
    reg  [A_BITS-1:0] a_in = {A_BITS{1'b0}};
    wire [A_BITS-1:0] a_out;
    AccumulateQueue #(
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
            $display("fifo_e %p, fifo_o %p, head %d, index %d",
                dut.fifo_e, dut.fifo_o, dut.head, dut.index);
        end

        // Stop sending
        a_in <= '0;

        for (i = 0; i < FIFO_LENGTH; i = i + 1) begin
            $display("Got %d", a_out);
            #10;
        end

        $finish;
    end
endmodule
