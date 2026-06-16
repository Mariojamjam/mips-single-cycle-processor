module tb_ula_ctrl;
    reg  [1:0] ALUOp;
    reg  [5:0] opcode;
    reg  [5:0] funct;
    wire [3:0] ULAOp;

    ula_ctrl uut (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .funct(funct),
        .ULAOp(ULAOp)
    );

    integer errors = 0;

    task check;
        input [1:0] expected_ALUOp;
        input [5:0] expected_opcode;
        input [5:0] expected_funct;
        input [3:0] expected_ULAOp;
        input [79:0] name;
        begin
            ALUOp = expected_ALUOp;
            opcode = expected_opcode;
            funct = expected_funct;
            #10;

            if (ULAOp !== expected_ULAOp) begin
                $display("FAIL [%s]: got %b, expected %b", name, ULAOp, expected_ULAOp);
                errors = errors + 1;
            end else begin
                $display("PASS [%s]", name);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_ula_ctrl.vcd");
        $dumpvars(0, tb_ula_ctrl);

        check(2'b00, 6'bxxxxxx, 6'bxxxxxx, 4'b0100, "LW_SW_ADD");
        check(2'b01, 6'bxxxxxx, 6'bxxxxxx, 4'b0101, "BRANCH_SUB");

        check(2'b10, 6'b000000, 6'b100100, 4'b0000, "R_AND");
        check(2'b10, 6'b000000, 6'b100101, 4'b0001, "R_OR");
        check(2'b10, 6'b000000, 6'b100110, 4'b0010, "R_XOR");
        check(2'b10, 6'b000000, 6'b100111, 4'b0011, "R_NOR");
        check(2'b10, 6'b000000, 6'b100000, 4'b0100, "R_ADD");
        check(2'b10, 6'b000000, 6'b100010, 4'b0101, "R_SUB");
        check(2'b10, 6'b000000, 6'b101010, 4'b0110, "R_SLT");
        check(2'b10, 6'b000000, 6'b101011, 4'b0111, "R_SLTU");
        check(2'b10, 6'b000000, 6'b000000, 4'b1000, "R_SLL");
        check(2'b10, 6'b000000, 6'b000010, 4'b1001, "R_SRL");
        check(2'b10, 6'b000000, 6'b000011, 4'b1010, "R_SRA");
        check(2'b10, 6'b000000, 6'b000100, 4'b1011, "R_SLLV");
        check(2'b10, 6'b000000, 6'b000110, 4'b1100, "R_SRLV");
        check(2'b10, 6'b000000, 6'b000111, 4'b1101, "R_SRAV");

        check(2'b11, 6'b001100, 6'b111111, 4'b0000, "I_ANDI");
        check(2'b11, 6'b001101, 6'b111111, 4'b0001, "I_ORI");
        check(2'b11, 6'b001110, 6'b111111, 4'b0010, "I_XORI");
        check(2'b11, 6'b001000, 6'b111111, 4'b0100, "I_ADDI");
        check(2'b11, 6'b001010, 6'b111111, 4'b0110, "I_SLTI");
        check(2'b11, 6'b001011, 6'b111111, 4'b0111, "I_SLTIU");

        if (errors == 0) begin
            $display("ALL PASS - ula_ctrl");
        end else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
