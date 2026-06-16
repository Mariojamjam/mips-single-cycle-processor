module tb_mips_top;
    reg Clock;
    reg Reset;

    wire [31:0] PC;
    wire [31:0] ULAResult;
    wire [31:0] DataMemoryOut;

    mips_top #(
        .INSTRUCTION_DEPTH(10)
    ) uut (
        .Clock(Clock),
        .Reset(Reset),
        .PC(PC),
        .ULAResult(ULAResult),
        .DataMemoryOut(DataMemoryOut)
    );

    integer errors = 0;

    always #5 Clock = ~Clock;

    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [511:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL [%s]: got %h, expected %h", label, actual, expected);
                errors = errors + 1;
            end else begin
                $display("PASS [%s]", label);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/mips.vcd");
        $dumpvars(0, tb_mips_top);

        Clock = 1'b0;
        Reset = 1'b1;
        #12;
        Reset = 1'b0;

        repeat (8) @(posedge Clock);
        #1;

        check(32'd5,  uut.register_file.regs[1], "addi writes r1");
        check(32'd7,  uut.register_file.regs[2], "addi writes r2");
        check(32'd12, uut.register_file.regs[3], "R-type add writes r3");
        check(32'd12, uut.data_memory.mem[0], "sw stores r3 in data memory");
        check(32'd12, uut.register_file.regs[4], "lw loads memory into r4");
        check(32'd0,  uut.register_file.regs[5], "beq and j skip r5 writes");
        check(32'd7,  uut.register_file.regs[6], "R-type sub writes r6");
        check(32'd40, PC, "PC reaches instruction after test program");

        if (errors == 0) begin
            $display("ALL PASS - mips_top integration test");
        end else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
