module tb_pc;
    reg clk;
    reg Reset;
    reg [31:0] nextPC;
    wire [31:0] currentPC;

    pc uut (
        .clk(clk),
        .Reset(Reset),
        .nextPC(nextPC),
        .currentPC(currentPC)
    );

    integer errors = 0;

    //Generates clock with 10 ns period
    always #5 clk = ~clk;


    //Compares actual against expected, logs PASS/FAIL with test label
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [127:0] test_name;
        begin
            if (actual !== expected) begin
                $display("FAIL [%s]: got %h, expected %h", test_name, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS [%s]", test_name);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_pc.vcd");
        $dumpvars(0, tb_pc);

        clk =  1'b0;
        Reset = 1'b1;
        nextPC = 32'h00000000;

        #1;
        check(32'h00000000, currentPC, "reset");

        Reset = 0;

        nextPC = 32'h00000004;
        @(posedge clk);
        #1;
        check(32'h00000004, currentPC, "update to 4");

        nextPC = 32'h00000008;
        @(posedge clk);
        #1;
        check(32'h00000008, currentPC, "update to 8");

        nextPC = 32'h00000010;
        @(posedge clk);
        #1;
        check(32'h00000010, currentPC, "update to 16");

        nextPC = 32'h00000020;
        @(posedge clk);
        #1;
        check(32'h00000020, currentPC, "update to 32");

        Reset = 1;
        #1;
        check(32'h00000000, currentPC, "reset after updates");

        if (errors == 0)
            $display("ALL PASS");
        else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule