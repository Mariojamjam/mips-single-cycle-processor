module tb_mips_top;
    reg Clock;
    reg Reset;

    wire [31:0] PC;
    wire [31:0] ULAResult;
    wire [31:0] DataMemoryOut;
    //super small integration bench: mainly checks fetch walks through the custom program file

    mips_top #(
        .INSTRUCTION_FILE("programs/instruction_test.list"),
        .INSTRUCTION_DEPTH(4)
    ) uut (
        .Clock(Clock),
        .Reset(Reset),
        .PC(PC),
        .ULAResult(ULAResult),
        .DataMemoryOut(DataMemoryOut)
    );

    integer errors = 0;
    //this one only sanity-checks fetch, not the whole processor behavior

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
        #1;
        check(32'd0, PC, "reset starts PC at 0");

        #11;
        Reset = 1'b0;
        //from here on, the ROM output should follow the PC immediately

        //first word fetched from the test ROM
        #1;
        check(32'h00000001, uut.instruction, "instruction at PC 0");

        //next cycle should move to address 4
        @(posedge Clock);
        #1;
        check(32'd4, PC, "PC advances to 4");
        check(32'h00000002, uut.instruction, "instruction at PC 4");

        //then address 8
        @(posedge Clock);
        #1;
        check(32'd8, PC, "PC advances to 8");
        check(32'h00000003, uut.instruction, "instruction at PC 8");

        //and finally address 12
        @(posedge Clock);
        #1;
        check(32'd12, PC, "PC advances to 12");
        check(32'h00000004, uut.instruction, "instruction at PC 12");

        if (errors == 0) begin
            $display("ALL PASS - mips_top fetch test");
        end else begin
            //if fetch is wrong, bigger integration benches are not worth trusting
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
