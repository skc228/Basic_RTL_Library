module sync_fifo
#(
    parameter WIDTH                 = 32,
    parameter DEPTH                 = 32,
    parameter FULL_THRESHOLD        = 8,
    parameter EMPTY_THRESHOLD       = 8
)
(
    input  logic                    wr_en,
    input  logic                    rd_en,
    input  logic [WIDTH-1:0]        din,
    output logic [WIDTH-1:0]        dout,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic                    err_checker,
    input  logic                    clk,
    input  logic                    rst
);

// Signal declaration
    logic [WIDTH-1:0]               mem     [DEPTH-1:0];
    logic [$clog2(DEPTH)-1:0]       wr_ptr, wr_ptr_nxt;
    logic [$clog2(DEPTH)-1:0]       rd_ptr, rd_ptr_nxt;
    logic [$clog2(DEPTH+1)-1:0]     count, count_nxt;
    logic                           internal_wr_en;
    logic                           internal_rd_en;

// Assign Procedures
    assign dout                     = mem[rd_ptr];
    assign full                     = (count == DEPTH);
    assign empty                    = (count == 0);
    assign almost_full              = (count >= DEPTH - FULL_THRESHOLD);
    assign almost_empty             = (count <= EMPTY_THRESHOLD);

    assign internal_wr_en           = (!full && wr_en);
    assign internal_rd_en           = (!empty && rd_en);

// Always_comb Procedures
    always_comb begin
        count_nxt = count;

        if (internal_wr_en && !internal_rd_en) begin
            count_nxt = count + 'd1;
        end else if (!internal_wr_en && internal_rd_en) begin
            count_nxt = count - 'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 'd0;
        end else begin
            count <= count_nxt;
        end
    end

    always_comb begin
        wr_ptr_nxt = wr_ptr;
        rd_ptr_nxt = rd_ptr;

        if (internal_wr_en) begin
            wr_ptr_nxt = (wr_ptr == DEPTH - 1) ? 'd0 : wr_ptr + 'd1;
        end

        if (internal_rd_en) begin
            rd_ptr_nxt = (rd_ptr == DEPTH - 1) ? 'd0 : rd_ptr + 'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 'd0;
            rd_ptr <= 'd0;
        end else begin
            wr_ptr <= wr_ptr_nxt;
            rd_ptr <= rd_ptr_nxt;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            err_checker <= 'b0;
        end else if ((full && wr_en) || (empty && rd_en)) begin
            err_checker <= 'b1;
        end else begin
            err_checker <= err_checker;
        end
    end

    // Write to memory
    always_ff @(posedge clk) begin
        if (internal_wr_en) begin
            mem[wr_ptr] <= din;
        end
    end

    // Assertion for err_checker
    always @(posedge clk) begin
        if(!rst)
            assert (!err_checker) else $error("Error: err_checker is high!");
    end

endmodule