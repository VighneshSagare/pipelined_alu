module pipelined_alu #(
    parameter int WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             valid_in,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [3:0]       op,
    output logic             valid_out,
    output logic [WIDTH-1:0] result,
    output logic             carry,
    output logic             overflow,
    output logic             zero,
    output logic             negative
);

    localparam logic [3:0] OP_ADD = 4'd0;
    localparam logic [3:0] OP_SUB = 4'd1;
    localparam logic [3:0] OP_AND = 4'd2;
    localparam logic [3:0] OP_OR  = 4'd3;
    localparam logic [3:0] OP_XOR = 4'd4;
    localparam logic [3:0] OP_SLL = 4'd5;
    localparam logic [3:0] OP_SRL = 4'd6;
    localparam logic [3:0] OP_SRA = 4'd7;
    localparam logic [3:0] OP_SLT = 4'd8;

    logic [WIDTH-1:0] r1_result;
    logic             r1_carry, r1_overflow, r1_valid;

    logic [WIDTH-1:0] comb_result;
    logic             comb_carry, comb_overflow;

    logic [WIDTH:0] add_ext;

    always_comb begin
        comb_result   = '0;
        comb_carry    = 1'b0;
        comb_overflow = 1'b0;
        add_ext       = '0;

        case (op)
            OP_ADD: begin
                add_ext       = {1'b0,a} + {1'b0,b};
                comb_result   = add_ext[WIDTH-1:0];
                comb_carry    = add_ext[WIDTH];
                comb_overflow = (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                                (comb_result[WIDTH-1] ^ a[WIDTH-1]);
            end

            OP_SUB: begin
                add_ext       = {1'b0,a} + {1'b0,~b} + 1'b1;
                comb_result   = add_ext[WIDTH-1:0];
                comb_carry    = add_ext[WIDTH];
                comb_overflow = (a[WIDTH-1] ^ b[WIDTH-1]) &
                                (comb_result[WIDTH-1] ^ a[WIDTH-1]);
            end

            OP_AND: comb_result = a & b;
            OP_OR : comb_result = a | b;
            OP_XOR: comb_result = a ^ b;
            OP_SLL: comb_result = a << b[$clog2(WIDTH)-1:0];
            OP_SRL: comb_result = a >> b[$clog2(WIDTH)-1:0];
            OP_SRA: comb_result = $signed(a) >>> b[$clog2(WIDTH)-1:0];
            OP_SLT: comb_result = ($signed(a) < $signed(b)) ? {{WIDTH-1{1'b0}},1'b1} : '0;
            default: comb_result = '0;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r1_result   <= '0;
            r1_carry    <= 1'b0;
            r1_overflow <= 1'b0;
            r1_valid    <= 1'b0;
        end else begin
            r1_result   <= comb_result;
            r1_carry    <= comb_carry;
            r1_overflow <= comb_overflow;
            r1_valid    <= valid_in;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result    <= '0;
            carry     <= 1'b0;
            overflow  <= 1'b0;
            zero      <= 1'b0;
            negative  <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            result    <= r1_result;
            carry     <= r1_carry;
            overflow  <= r1_overflow;
            zero      <= (r1_result == '0);
            negative  <= r1_result[WIDTH-1];
            valid_out <= r1_valid;
        end
    end

endmodule
