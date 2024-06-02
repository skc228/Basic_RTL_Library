module one_hot_decoder #(
    parameter INPUT_WIDTH   = 2,                        // Number of input bits
    parameter OUTPUT_WIDTH  = 1 << INPUT_WIDTH          // Number of output bits, 2^INPUT_WIDTH
) (
    input  logic [INPUT_WIDTH-1:0]  binary_in,          // Binary encoded input
    output logic [OUTPUT_WIDTH-1:0] one_hot_out         // One-hot encoded output
);

    // Always block to generate one-hot encoding
    always_comb begin
        // Initialize all outputs to 0
        one_hot_out = '0;
        // Set the output bit corresponding to the input value to 1
        one_hot_out[binary_in] = 1'b1;
    end

endmodule