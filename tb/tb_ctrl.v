module tb_ctrl;
    reg [5:0] opcode;

    wire RegDst;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;
    wire Jump;
    wire JAL;
    wire JR;

    ctrl uut (
        .opcode(opcode),
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .JAL(JAL),
        .JR(JR)
    );

    integer errors = 0;

    task check;
        input        exp_RegDst;
        input        exp_Branch;
        input        exp_MemRead;
        input        exp_MemtoReg;
        input [1:0]  exp_ALUOp;
        input        exp_MemWrite;
        input        exp_ALUSrc;
        input        exp_RegWrite;
        input        exp_Jump;
        input        exp_JAL;
        input        exp_JR;
        input [127:0] instr_name;
        begin
            if (RegDst   !== exp_RegDst   ||
                Branch   !== exp_Branch   ||
                MemRead  !== exp_MemRead  ||
                MemtoReg !== exp_MemtoReg ||
                ALUOp    !== exp_ALUOp    ||
                MemWrite !== exp_MemWrite ||
                ALUSrc   !== exp_ALUSrc   ||
                RegWrite !== exp_RegWrite ||
                Jump     !== exp_Jump     ||
                JAL      !== exp_JAL      ||
                JR       !== exp_JR) begin

                $display("FAIL [%s]", instr_name);
                $display("got      RegDst=%b Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b Jump=%b JAL=%b JR=%b",
                          RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, Jump, JAL, JR);
                $display("expected RegDst=%b Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b Jump=%b JAL=%b JR=%b",
                          exp_RegDst, exp_Branch, exp_MemRead, exp_MemtoReg, exp_ALUOp, exp_MemWrite, exp_ALUSrc, exp_RegWrite, exp_Jump, exp_JAL, exp_JR);

                errors = errors + 1;
            end else
                $display("PASS [%s]", instr_name);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_ctrl.vcd");
        $dumpvars(0, tb_ctrl);

        opcode = 6'b000000; #10;
        check(1, 0, 0, 0, 2'b10, 0, 0, 1, 0, 0, 0, "R-type");

        opcode = 6'b100011; #10;
        check(0, 0, 1, 1, 2'b00, 0, 1, 1, 0, 0, 0, "lw");

        opcode = 6'b101011; #10;
        check(0, 0, 0, 0, 2'b00, 1, 1, 0, 0, 0, 0, "sw");

        opcode = 6'b000100; #10;
        check(0, 1, 0, 0, 2'b01, 0, 0, 0, 0, 0, 0, "beq");

        opcode = 6'b000101; #10;
        check(0, 1, 0, 0, 2'b01, 0, 0, 0, 0, 0, 0, "bne");

        opcode = 6'b001000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "addi");

        opcode = 6'b001100; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "andi");

        opcode = 6'b001101; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "ori");

        opcode = 6'b001110; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "xori");

        opcode = 6'b001010; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "slti");

        opcode = 6'b001011; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, "sltiu");

        opcode = 6'b000010; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 0, 1, 0, 0, "j");

        opcode = 6'b000011; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 1, 1, 1, 0, "jal");

        opcode = 6'b111111; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 0, 0, 0, 0, "default");

        if (errors == 0)
            $display("ALL PASS - %0d tests", 14);
        else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule