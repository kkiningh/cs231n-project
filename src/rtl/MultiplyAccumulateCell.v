module MultiplyAccumulateCell #(
    parameter DATA_BITS        = 8,
    parameter WEIGHT_BITS      = 8,
    parameter ACCUMULATOR_BITS = 16
) (
    input clock,
    input reset,

    // Data input/output
    input [DATA_BITS-1:0]           data_in,
    input [ACCUMULATOR_BITS-1:0]    accumulator_in,
    input                           mac_stall_in,

    output [DATA_BITS-1:0]          data_out,
    output [ACCUMULATOR_BITS-1:0]   accumulator_out,

    // Weight input
    input  [WEIGHT_BITS-1:0]        weight_in,
    input                           weight_set
);
    // Save the weight when the weight_set is active
    reg [WEIGHT_BITS-1:0]       weight;
    always @(posedge clock) begin
        if (reset) begin
            weight <= {WEIGHT_BITS{1'b0}};
        end else if (weight_set) begin
            weight <= weight_in;
        end
    end

    // Save the result
    reg [DATA_BITS-1:0]         data;
    reg [ACCUMULATOR_BITS-1:0]  accumulator;
    always @(posedge clock) begin
        if (reset) begin
            data        <= {DATA_BITS{1'b0}};
            accumulator <= {ACCUMULATOR_BITS{1'b0}};
        end else if (!mac_stall_in) begin
            data        <= data_in;
            accumulator <= data_in * weight + accumulator_in;
        end
    end

    // Forward the value of the accumulator and data
    assign data_out        = data;
    assign accumulator_out = accumulator;
endmodule
