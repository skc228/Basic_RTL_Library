module sync_gearbox_fifo #(
    parameter IN_WIDTH              = 32,
    parameter OUT_WIDTH             = 16,
    parameter DEPTH                 = 32,
    parameter FULL_THRESHOLD        = 8,
    parameter EMPTY_THRESHOLD       = 8
) (
    input  logic                    wr_en,
    input  logic                    rd_en,
    input  logic [IN_WIDTH-1:0]     din,
    output logic [OUT_WIDTH-1:0]    dout,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic                    err_checker,
    input  logic                    clk,
    input  logic                    rst
);

    // Internal Parameters
    localparam MAX_WIDTH               = (IN_WIDTH > OUT_WIDTH) ? IN_WIDTH : OUT_WIDTH;
    localparam CONVERSION_FACTOR       = (IN_WIDTH > OUT_WIDTH) ? (IN_WIDTH / OUT_WIDTH) : (OUT_WIDTH / IN_WIDTH);

    // Power of 2 Check Function
    function bit is_power_of_two(input int value);
        return (value > 0) && ((value & (value - 1)) == 0);
    endfunction

    // Initial Assertion for Power of 2
    initial begin
        assert (is_power_of_two(CONVERSION_FACTOR)) else $error("Error: CONVERSION_FACTOR is not a power of 2");
    end

    // Signal Declaration
    logic [MAX_WIDTH-1:0]                mem [DEPTH-1:0];
    logic [$clog2(DEPTH)-1:0]            wr_ptr, wr_ptr_nxt;
    logic [$clog2(DEPTH)-1:0]            rd_ptr, rd_ptr_nxt;
    logic [$clog2(DEPTH+1)-1:0]          count, count_nxt;
    logic                                internal_wr_en;
    logic                                internal_rd_en;
    logic [$clog2(CONVERSION_FACTOR)-1:0] sub_word_cnt;

    // Assign Procedures
    assign full                         = (count == DEPTH);
    assign empty                        = (count == 0);
    assign almost_full                  = (count >= DEPTH - FULL_THRESHOLD);
    assign almost_empty                 = (count <= EMPTY_THRESHOLD);

    generate
        if(IN_WIDTH == OUT_WIDTH) begin
            assign internal_wr_en       = (!full && wr_en);
            assign internal_rd_en       = (!empty && rd_en);
            assign dout                 = mem[rd_ptr];
        end
        else if(IN_WIDTH > OUT_WIDTH) begin
            assign internal_wr_en       = (!full && wr_en);
            assign internal_rd_en       = ((!empty && rd_en) && (sub_word_cnt == CONVERSION_FACTOR - 'd1));
            assign dout                 = mem[rd_ptr][sub_word_cnt * OUT_WIDTH +: OUT_WIDTH];
        end
        else begin
            assign internal_wr_en       = ((!full && wr_en) && (sub_word_cnt == CONVERSION_FACTOR - 'd1));
            assign internal_rd_en       = (!empty && rd_en);
            assign dout                 = mem[rd_ptr];
        end 
    endgenerate
    
    // Count Update
    always_comb begin
        count_nxt = count;
        if (internal_wr_en && !internal_rd_en) begin
            count_nxt = count + 1;
        end else if (!internal_wr_en && internal_rd_en) begin
            count_nxt = count - 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 'd0;
        end else begin
            count <= count_nxt;
        end
    end

    // Sub Wordcounter Update
    always_ff @(posedge clk) begin
        if (rst) begin
            sub_word_cnt <= 'd0;
        end else begin
            if (IN_WIDTH > OUT_WIDTH) begin
                sub_word_cnt <= (rd_en && !empty) ? sub_word_cnt + 'd1 : sub_word_cnt;
            end else if (IN_WIDTH < OUT_WIDTH) begin
                sub_word_cnt <= (wr_en && !full) ? sub_word_cnt + 'd1 : sub_word_cnt;
            end else begin
                sub_word_cnt <= sub_word_cnt;
            end
        end
    end

    // Write Pointer Update
    always_comb begin
        wr_ptr_nxt = wr_ptr;
        if (internal_wr_en) begin
            wr_ptr_nxt = (wr_ptr == DEPTH - 1) ? 'd0 : wr_ptr + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 'd0;
        end else begin
            wr_ptr <= wr_ptr_nxt;
        end
    end

    // Read Pointer Update
    always_comb begin
        rd_ptr_nxt = rd_ptr;
        if (internal_rd_en) begin
            rd_ptr_nxt = (rd_ptr == DEPTH - 1) ? 'd0 : rd_ptr + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 'd0;
        end else begin
            rd_ptr <= rd_ptr_nxt;
        end
    end

    // Write to Memory
    always_ff @(posedge clk) begin
        if (IN_WIDTH >= OUT_WIDTH) begin
            if (internal_wr_en) begin
                mem[wr_ptr] <= din;
            end
        end else begin
            if (wr_en) begin
                mem[wr_ptr][sub_word_cnt * IN_WIDTH +: IN_WIDTH] <= din;
            end 
        end
    end

    // Error Checker
    always_ff @(posedge clk) begin
        if (rst) begin
            err_checker <= 'b0;
        end else if ((full && wr_en) || (empty && rd_en)) begin
            err_checker <= 'b1;
        end else begin
            err_checker <= err_checker;
        end
    end

    // Assertion for err_checker
    always @(posedge clk) begin
        if (!rst)
            assert (!err_checker) else $error("Error: err_checker is high!");
    end

endmodule