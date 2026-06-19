module tb_ula_ctrl;
    reg  [1:0] ALUOp;
    reg  [5:0] opcode;
    reg  [5:0] funct;
    wire [3:0] ULAOp;
    //decode-only bench for the ALU control micro-table

    ula_ctrl uut (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .funct(funct),
        .ULAOp(ULAOp)
    );

    integer errors = 0;
    //each check here is just one mapping in the decode table

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
            //tiny delay is enough, this whole block is combinational
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

        //lw and sw both need an add for address calculation
        check(2'b00, 6'bxxxxxx, 6'bxxxxxx, 4'b0100, "LW_SW_ADD");
        //branches compare by subtracting
        check(2'b01, 6'bxxxxxx, 6'bxxxxxx, 4'b0101, "BRANCH_SUB");

        //R-type AND decode
        check(2'b10, 6'b000000, 6'b100100, 4'b0000, "R_AND");
        //R-type OR decode
        check(2'b10, 6'b000000, 6'b100101, 4'b0001, "R_OR");
        //R-type XOR decode
        check(2'b10, 6'b000000, 6'b100110, 4'b0010, "R_XOR");
        //R-type NOR decode
        check(2'b10, 6'b000000, 6'b100111, 4'b0011, "R_NOR");
        //R-type ADD decode
        check(2'b10, 6'b000000, 6'b100000, 4'b0100, "R_ADD");
        //R-type SUB decode
        check(2'b10, 6'b000000, 6'b100010, 4'b0101, "R_SUB");
        //signed set-less-than decode
        check(2'b10, 6'b000000, 6'b101010, 4'b0110, "R_SLT");
        //unsigned set-less-than decode
        check(2'b10, 6'b000000, 6'b101011, 4'b0111, "R_SLTU");
        //fixed left shift decode
        check(2'b10, 6'b000000, 6'b000000, 4'b1000, "R_SLL");
        //fixed logical right shift decode
        check(2'b10, 6'b000000, 6'b000010, 4'b1001, "R_SRL");
        //fixed arithmetic right shift decode
        check(2'b10, 6'b000000, 6'b000011, 4'b1010, "R_SRA");
        //variable left shift decode
        check(2'b10, 6'b000000, 6'b000100, 4'b1011, "R_SLLV");
        //variable logical right shift decode
        check(2'b10, 6'b000000, 6'b000110, 4'b1100, "R_SRLV");
        //variable arithmetic right shift decode
        check(2'b10, 6'b000000, 6'b000111, 4'b1101, "R_SRAV");

        //I-type AND decode
        check(2'b11, 6'b001100, 6'b111111, 4'b0000, "I_ANDI");
        //I-type OR decode
        check(2'b11, 6'b001101, 6'b111111, 4'b0001, "I_ORI");
        //I-type XOR decode
        check(2'b11, 6'b001110, 6'b111111, 4'b0010, "I_XORI");
        //I-type ADD decode
        check(2'b11, 6'b001000, 6'b111111, 4'b0100, "I_ADDI");
        //I-type signed compare decode
        check(2'b11, 6'b001010, 6'b111111, 4'b0110, "I_SLTI");
        //I-type unsigned compare decode
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
