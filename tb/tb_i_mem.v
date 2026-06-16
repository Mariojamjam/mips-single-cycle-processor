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
        //first instruction should live at byte address 0
        address = 32'd0;  #1;
        check(32'h00000001, i_out, "PC=0");

        //next word should appear at PC=4
        address = 32'd4;  #1;
        check(32'h00000002, i_out, "PC=4");

        //same mapping for the third slot
        address = 32'd8;  #1;
        check(32'h00000003, i_out, "PC=8");

        //no clock here on purpose, the read is async
        address = 32'd12; #1;
        check(32'h00000004, i_out, "PC=12");

        if (errors == 0)
            $display("ALL PASS - %0d tests", 4);
        else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
