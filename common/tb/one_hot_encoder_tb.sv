`timescale 1ns/1ps

module one_hot_encoder_tb;

    // Parameter definitions
    parameter INPUT_WIDTH  = 2;
    parameter OUTPUT_WIDTH = 1 << INPUT_WIDTH;

    // DUT signal declarations
    logic [INPUT_WIDTH-1:0]  binary_in;
    logic [OUTPUT_WIDTH-1:0] one_hot_out;

    // DUT instantiation
    one_hot_encoder #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) dut (
        .binary_in(binary_in),
        .one_hot_out(one_hot_out)
    );

    // Dump File for EDA Playground
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    // Test sequence
    initial begin
        // Test input value 0
        binary_in = 2'b00;
        #10;
        assert (one_hot_out == 4'b0001) else $error("Test failed for input 2'b00");

        // Test input value 1
        binary_in = 2'b01;
        #10;
        assert (one_hot_out == 4'b0010) else $error("Test failed for input 2'b01");

        // Test input value 2
        binary_in = 2'b10;
        #10;
        assert (one_hot_out == 4'b0100) else $error("Test failed for input 2'b10");

        // Test input value 3
        binary_in = 2'b11;
        #10;
        assert (one_hot_out == 4'b1000) else $error("Test failed for input 2'b11");

        $display("All tests passed!");
        $finish();
    end

    // Monitor to display the values
    initial begin
        $monitor("Time: %0t | binary_in: %b | one_hot_out: %b", $time, binary_in, one_hot_out);
    end

endmodule