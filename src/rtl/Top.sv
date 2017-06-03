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
            w     <= {W_BITS{1'b0}};
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
