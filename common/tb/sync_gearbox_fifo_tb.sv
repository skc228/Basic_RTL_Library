`timescale 1ns/1ps

module sync_gearbox_fifo_tb;

    // Parameter definitions
    parameter IN_WIDTH              = 32;
    parameter OUT_WIDTH             = 16;
    parameter DEPTH                 = 32;
    parameter FULL_THRESHOLD        = 8;
    parameter EMPTY_THRESHOLD       = 8;

    // DUT signal declarations
    logic                    wr_en;
    logic                    rd_en;
    logic [IN_WIDTH-1:0]     din;
    logic [OUT_WIDTH-1:0]    dout;
    logic                    full;
    logic                    empty;
    logic                    almost_full;
    logic                    almost_empty;
    logic                    err_checker;
    logic                    clk;
    logic                    rst;

    // DUT instantiation
    sync_gearbox_fifo #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH),
        .DEPTH(DEPTH),
        .FULL_THRESHOLD(FULL_THRESHOLD),
        .EMPTY_THRESHOLD(EMPTY_THRESHOLD)
    ) dut (
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .err_checker(err_checker),
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Dump File for EDA Playground
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, sync_gearbox_fifo_tb);
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Apply reset
        @(posedge clk); #0;
        rst = 1;
        @(posedge clk); #0;
        rst = 0;
        
        // Write data to FIFO
        @(posedge clk); #0;
        wr_en = 1;
        for (int i = 0; i < DEPTH; i++) begin
            din = $random;
            @(posedge clk); #0;
        end
        wr_en = 0;

        // Read data from FIFO
        @(posedge clk); #0;
        rd_en = 1;
        for (int i = 0; i < DEPTH * (IN_WIDTH / OUT_WIDTH); i++) begin
            @(posedge clk); #0;
        end
        rd_en = 0;

        // Test almost full and almost empty conditions
        @(posedge clk); #0;
        wr_en = 1;
        for (int i = 0; i < (DEPTH - FULL_THRESHOLD); i++) begin
            din = $random;
            @(posedge clk); #0;
        end
        wr_en = 0;

        @(posedge clk); #0;
        rd_en = 1;
        for (int i = 0; i < (DEPTH - EMPTY_THRESHOLD) * (IN_WIDTH / OUT_WIDTH); i++) begin
            @(posedge clk); #0;
        end
        rd_en = 0;

        // End of test
        @(posedge clk); #0;
        $finish();
    end

    // Monitor to display the values
    initial begin
        $monitor("Time: %0t | wr_en: %b | rd_en: %b | din: %h | dout: %h | full: %b | empty: %b | almost_full: %b | almost_empty: %b | err_checker: %b",
                 $time, wr_en, rd_en, din, dout, full, empty, almost_full, almost_empty, err_checker);
    end

endmodule