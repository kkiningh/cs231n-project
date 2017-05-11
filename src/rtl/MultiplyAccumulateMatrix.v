module MultiplyAccumulateMatrix #(
    parameter DATA_BITS         = 8,
    parameter WEIGHT_BITS       = 8,
    parameter ACCUMULATOR_BITS  = 16,
    parameter MATRIX_SIZE       = 256
) (
    input clock,
    input reset,

    input [DATA_BITS-1:0] data_in [0:255],

    // Global inputs
    input                   mac_stall_in,
    input [WEIGHT_BITS-1:0] weight_in,
    input                   weight_set
);
    genvar i, j;
    generate for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : MatrixRow
        for (j = 0; j < MATRIX_SIZE; j = j + 1) begin : MatrixColumn
            wire [DATA_BITS-1:0]        cell_data_in, cell_data_out;
            wire [ACCUMULATOR_BITS-1:0] cell_accumulator_in, cell_accumulator_out;

            /* Handle edge conditions */
            if (i == 0) begin : RowEdge
                assign cell_accumulator_in = {ACCUMULATOR_BITS{1'b0}};
            end else begin : RowNonEdge
                assign cell_accumulator_in = MatrixRow[i-1].MatrixColumn[j].cell_accumulator_out;
            end

            if (j == 0) begin : ColumnEdge
                assign cell_data_in = data_in[i];
            end else begin : ColumnNonEdge
                assign cell_data_in = MatrixRow[i].MatrixColumn[j-1].cell_data_out;
            end

            /* Actual cell instance */
            MultiplyAccumulateCell #(
                .DATA_BITS(DATA_BITS),
                .WEIGHT_BITS(WEIGHT_BITS),
                .ACCUMULATOR_BITS(ACCUMULATOR_BITS)
            ) mac_cell (
                .clock(clock),
                .reset(reset),

                // Use the previous columns' data_out
                .data_in (cell_data_in),
                .data_out(cell_data_out),

                // Use the previous rows' accumulator_out
                .accumulator_in (cell_accumulator_in),
                .accumulator_out(cell_accumulator_out),

                // global stall
                .mac_stall_in(mac_stall_in),

                // global weight signals
                .weight_in(weight_in),
                .weight_set(weight_set)
            );
        end
    end endgenerate
endmodule
