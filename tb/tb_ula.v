module tb_ula;
    reg [31:0] In1, In2;
    reg [4:0]  shamt;
    reg [3:0]  OP;
    wire [31:0] result;
    wire        Zero_flag;

    ula uut (
        .In1(In1),
        .In2(In2),
        .shamt(shamt),
        .OP(OP),
        .result(result),
        .Zero_flag(Zero_flag)
    );

    integer errors = 0;
    //Compares actual against expected, logs PASS/FAIL with operation label
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [63:0] op_name;
        begin
            if (actual !== expected) begin
                $display("FAIL [%s]: got %h, expected %h", op_name, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS [%s]", op_name);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_ula.vcd");
        $dumpvars(0, tb_ula);

        //bitwise and
        In1=32'hFF00FF00; In2=32'h0F0F0F0F; shamt=0; OP=4'b0000; #10;
        check(32'h0F000F00, result, "AND");

        //bitwise or
        In1=32'hFF00FF00; In2=32'h0F0F0F0F; OP=4'b0001; #10;
        check(32'hFF0FFF0F, result, "OR");

        //bitwise xor
        In1=32'hFF00FF00; In2=32'h0F0F0F0F; OP=4'b0010; #10;
        check(32'hF00FF00F, result, "XOR");

        //nor is an easy place to make a truth-table mistake
        In1=32'hFF00FF00; In2=32'h0F0F0F0F; OP=4'b0011; #10;
        check(32'h00F000F0, result, "NOR");

        //plain add
        In1=32'd15; In2=32'd10; OP=4'b0100; #10;
        check(32'd25, result, "ADD");

        //plain sub
        In1=32'd15; In2=32'd10; OP=4'b0101; #10;
        check(32'd5, result, "SUB");

        //zero flag matters later for branches
        In1=32'd7; In2=32'd7; OP=4'b0101; #10;
        if (Zero_flag !== 1'b1) begin
            $display("FAIL [Zero_flag]: expected 1, got %b", Zero_flag);
            errors = errors + 1;
        end else
            $display("PASS [Zero_flag]");

        //signed compare should treat 0xFFFFFFFF as -1
        In1=32'hFFFFFFFF; In2=32'd1; OP=4'b0110; #10;
        check(32'd1, result, "SLT true");

        //reverse signed comparison
        In1=32'd1; In2=32'hFFFFFFFF; OP=4'b0110; #10;
        check(32'd0, result, "SLT false");

        //unsigned compare should see 0xFFFFFFFF as huge
        In1=32'd1; In2=32'hFFFFFFFF; OP=4'b0111; #10;
        check(32'd1, result, "SLTU true");

        //fixed left shift
        In1=0; In2=32'd1; shamt=5'd4; OP=4'b1000; #10;
        check(32'd16, result, "SLL");

        //fixed logical right shift
        In1=0; In2=32'd16; shamt=5'd4; OP=4'b1001; #10;
        check(32'd1, result, "SRL");

        //arithmetic shift must keep the sign bit
        In1=0; In2=32'hFFFFFF00; shamt=5'd4; OP=4'b1010; #10;
        check(32'hFFFFFFF0, result, "SRA");

        //variable left shift uses In1[4:0]
        In1=32'd3; In2=32'd1; shamt=0; OP=4'b1011; #10;
        check(32'd8, result, "SLLV");

        //variable logical right shift
        In1=32'd2; In2=32'd16; OP=4'b1100; #10;
        check(32'd4, result, "SRLV");

        //same sign rule, now with a variable shift amount
        In1=32'd4; In2=32'hFFFFFF00; OP=4'b1101; #10;
        check(32'hFFFFFFF0, result, "SRAV");

        if (errors == 0)
            $display("ALL PASS — %0d tests", 16);
        else begin
            $display("FAILED — %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
