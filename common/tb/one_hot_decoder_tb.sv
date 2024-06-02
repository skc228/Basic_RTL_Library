`timescale 1ns/1ps

module one_hot_decoder_tb;

    // Parameters
    parameter INPUT_WIDTH  = 8;
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH);

    // Signals
    logic [INPUT_WIDTH-1:0]  one_hot_in;
    logic [OUTPUT_WIDTH-1:0] binary_out;
    logic                    valid;

    // DUT instantiation
    one_hot_decoder #(
        .INPUT_WIDTH(INPUT_WIDTH)
    ) dut (
        .one_hot_in(one_hot_in),
        .binary_out(binary_out),
        .valid(valid)
    );

    // Test sequence
    initial begin
        $dumpfile("one_hot_decoder.vcd");
        $dumpvars(0, one_hot_decoder_tb);

        // Test case 1: No input active
        one_hot_in = 8'b00000000;
        #10;
        assert (valid == 1'b0) else $error("Test case 1 failed");
        assert (binary_out == 3'b000) else $error("Test case 1 failed");

        // Test case 2: Input 2 active
        one_hot_in = 8'b00000100;
        #10;
        assert (valid == 1'b1) else $error("Test case 2 failed");
        assert (binary_out == 3'd2) else $error("Test case 2 failed");

        // Test case 3: Input 7 active
        one_hot_in = 8'b10000000;
        #10;
        assert (valid == 1'b1) else $error("Test case 3 failed");
        assert (binary_out == 3'd7) else $error("Test case 3 failed");

        // Test case 4: Multiple inputs active (only the highest index should be encoded)
        one_hot_in = 8'b00101100;
        #10;
        assert (valid == 1'b1) else $error("Test case 4 failed");
        assert (binary_out == 3'd5) else $error("Test case 4 failed");

        // Test case 5: Input 0 active
        one_hot_in = 8'b00000001;
        #10;
        assert (valid == 1'b1) else $error("Test case 5 failed");
        assert (binary_out == 3'd0) else $error("Test case 5 failed");

        // End of test
        $display("All test cases passed");
        $finish;
    end

endmodule