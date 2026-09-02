module tb_pipelined_alu;
    localparam int W = 32;
    logic clk = 0, rst_n = 0, valid_in;
    logic [W-1:0] a,b;
    logic [3:0] op;
    logic valid_out, carry, overflow, zero, negative;
    logic [W-1:0] result;

    pipelined_alu #(.WIDTH(W)) dut(.*);

    always #5 clk = ~clk;

    task automatic apply(input [W-1:0] aa, input [W-1:0] bb, input [3:0] oo);
        begin
            @(negedge clk);
            a=aa; b=bb; op=oo; valid_in=1;
        end
    endtask

    initial begin
        a=0; b=0; op=0; valid_in=0;
        repeat(2) @(posedge clk);
        rst_n=1;

        apply(32'd10, 32'd7, 4'd0); // ADD
        apply(32'd10, 32'd7, 4'd1); // SUB
        apply(32'hF0F0, 32'h0FF0, 4'd2); // AND
        apply(32'hAAAA, 32'h5555, 4'd4); // XOR
        apply(32'd8, 32'd2, 4'd5); // SLL
        apply(-32'sd3, 32'd1, 4'd7); // SRA

        @(negedge clk);
        valid_in=0;

        repeat(5) @(posedge clk);
        $display("Pipeline test completed.");
        $finish;
    end
endmodule
