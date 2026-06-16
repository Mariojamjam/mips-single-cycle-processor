module tb_ctrl;
    reg [5:0] opcode;
    reg [5:0] funct;

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
    wire LUI;
    wire ZeroExt;

    ctrl uut (
        .opcode(opcode),
        .funct(funct),
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
        .JR(JR),
        .LUI(LUI),
        .ZeroExt(ZeroExt)
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
        input        exp_LUI;
        input        exp_ZeroExt;
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
                JR       !== exp_JR       ||
                LUI      !== exp_LUI      ||
                ZeroExt  !== exp_ZeroExt) begin

                $display("FAIL [%s]", instr_name);
                $display("got      RegDst=%b Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b Jump=%b JAL=%b JR=%b LUI=%b ZeroExt=%b",
                          RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, Jump, JAL, JR, LUI, ZeroExt);
                $display("expected RegDst=%b Branch=%b MemRead=%b MemtoReg=%b ALUOp=%b MemWrite=%b ALUSrc=%b RegWrite=%b Jump=%b JAL=%b JR=%b LUI=%b ZeroExt=%b",
                          exp_RegDst, exp_Branch, exp_MemRead, exp_MemtoReg, exp_ALUOp, exp_MemWrite, exp_ALUSrc, exp_RegWrite, exp_Jump, exp_JAL, exp_JR, exp_LUI, exp_ZeroExt);

                errors = errors + 1;
            end else
                $display("PASS [%s]", instr_name);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_ctrl.vcd");
        $dumpvars(0, tb_ctrl);

        //plain R-type should write to rd
        opcode = 6'b000000; funct = 6'b100000; #10;
        check(1, 0, 0, 0, 2'b10, 0, 0, 1, 0, 0, 0, 0, 0, "R-type");

        //jr should only redirect control flow
        opcode = 6'b000000; funct = 6'b001000; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 0, 0, 0, 1, 0, 0, "jr");

        //load reads memory and writes back to a register
        opcode = 6'b100011; funct = 6'b000000; #10;
        check(0, 0, 1, 1, 2'b00, 0, 1, 1, 0, 0, 0, 0, 0, "lw");

        //store only touches memory
        opcode = 6'b101011; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b00, 1, 1, 0, 0, 0, 0, 0, 0, "sw");

        //beq uses the branch compare path
        opcode = 6'b000100; funct = 6'b000000; #10;
        check(0, 1, 0, 0, 2'b01, 0, 0, 0, 0, 0, 0, 0, 0, "beq");

        //bne shares the same compare machinery
        opcode = 6'b000101; funct = 6'b000000; #10;
        check(0, 1, 0, 0, 2'b01, 0, 0, 0, 0, 0, 0, 0, 0, "bne");

        //addi keeps the immediate sign
        opcode = 6'b001000; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 0, "addi");

        //andi needs zero extension or the datapath will be wrong
        opcode = 6'b001100; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 1, "andi");

        //same zero-extension rule here
        opcode = 6'b001101; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 1, "ori");

        //xori follows the same immediate rule
        opcode = 6'b001110; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 1, "xori");

        //slti still uses the signed immediate path
        opcode = 6'b001010; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 0, "slti");

        //sltiu changes the compare type, not the extension mode
        opcode = 6'b001011; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b11, 0, 1, 1, 0, 0, 0, 0, 0, "sltiu");

        //lui should select the upper-immediate writeback path
        opcode = 6'b001111; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b00, 0, 1, 1, 0, 0, 0, 1, 0, "lui");

        //plain jump only changes the PC
        opcode = 6'b000010; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 0, 1, 0, 0, 0, 0, "j");

        //jal jumps and saves a return point
        opcode = 6'b000011; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 1, 1, 1, 0, 0, 0, "jal");

        //unknown opcode should fall back to the safe defaults
        opcode = 6'b111111; funct = 6'b000000; #10;
        check(0, 0, 0, 0, 2'b00, 0, 0, 0, 0, 0, 0, 0, 0, "default");

        if (errors == 0)
            $display("ALL PASS - %0d tests", 16);
        else begin
            $display("FAILED - %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
