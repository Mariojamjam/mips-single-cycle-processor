module tb_i_mem;
    reg  [31:0] address;
    wire [31:0] i_out;

    i_mem #(.MEM_FILE("programs/instruction_test.list")) uut (
        .address(address),
        .i_out(i_out)
    );

    integer errors = 0;
    //Compares actual against expected, logs PASS/FAIL with operation label
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [63:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL [%s]: got %h, expected %h", label, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS [%s]", label);
        end
    endtask

    initial begin
        //Checking if the i_mem can read instruction_test.list
        //Also testing if the array progression that will be operated by the PC is working
        //Minimal #1 delay confirms asynchronous behavior — no clock needed
        address = 32'd0;  #1;
        check(32'h00000001, i_out, "PC=0");

        address = 32'd4;  #1;
        check(32'h00000002, i_out, "PC=4");

        address = 32'd8;  #1;
        check(32'h00000003, i_out, "PC=8");

        address = 32'd12; #1;
        check(32'h00000004, i_out, "PC=12");

        if (errors == 0)
            $display("ALL PASS — %0d tests", 4);
        else begin
            $display("FAILED — %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
