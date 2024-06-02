module one_hot_decoder #(
    parameter INPUT_WIDTH  = 8,                       // Number of input bits
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH)      // Number of output bits (log2(INPUT_WIDTH))
) (
    input  logic [INPUT_WIDTH-1:0]  one_hot_in,       // One-hot encoded input
    output logic [OUTPUT_WIDTH-1:0] binary_out,       // Binary encoded output
    output logic                    valid             // Valid signal indicating at least one input is high
);

    always_comb begin
        binary_out = {OUTPUT_WIDTH{1'b0}};            // Initialize binary output to 0
        valid      = 1'b0;                            // Initialize valid signal to 0

        for (int i = 0; i < INPUT_WIDTH; i++) begin
            if (one_hot_in[i]) begin
                binary_out = i;                       // Set binary output to the index of the active one-hot input
                valid      = 1'b1;                    // Set valid signal to 1
            end
        end
    end

endmodule