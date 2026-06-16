module ctrl (
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output reg        RegDst,
    output reg        Branch,
    output reg        MemRead,
    output reg        MemtoReg,
    output reg [1:0]  ALUOp,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        RegWrite,
    output reg        Jump,
    output reg        JAL,
    output reg        JR,
    output reg        LUI,
    output reg        ZeroExt
);

    always @(*) begin
        //safe defaults before the opcode-specific cases
        RegDst   = 1'b0;
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;
        Jump     = 1'b0;
        JAL      = 1'b0;
        JR       = 1'b0;
        LUI      = 1'b0;
        ZeroExt  = 1'b0;

        case (opcode)
            6'b000000: begin
                if (funct == 6'b001000) begin // jr
                    //jr only redirects the PC
                    JR = 1'b1;
                end else begin // other R-type
                    RegDst   = 1'b1;
                    ALUOp    = 2'b10;
                    RegWrite = 1'b1;
                end
            end

            6'b100011: begin // lw
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            6'b101011: begin // sw
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end

            6'b000100: begin // beq
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            6'b000101: begin // bne
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            6'b001000: begin // addi
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            6'b001100: begin // andi
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            6'b001101: begin // ori
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            6'b001110: begin // xori
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            6'b001010: begin // slti
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            6'b001011: begin // sltiu
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            6'b001111: begin // lui
                //writeback comes from the immediate upper half
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                LUI      = 1'b1;
            end

            6'b000010: begin // j
                Jump = 1'b1;
            end

            6'b000011: begin // jal
                Jump     = 1'b1;
                JAL      = 1'b1;
                RegWrite = 1'b1;
            end
        endcase
    end
endmodule
