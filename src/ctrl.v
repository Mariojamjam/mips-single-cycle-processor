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
    //main decode block: opcode sets the broad path, funct only matters for R-type details

    always @(*) begin
        //safe defaults before the opcode-specific cases
        //this keeps weird opcodes from reusing an old control pattern by accident
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
                //R-type needs funct to know if this is jr or a normal ALU op
                if (funct == 6'b001000) begin // jr
                    //jr only redirects the PC
                    JR = 1'b1;
                end else begin // other R-type
                    //regular R-type writes the ALU result into rd
                    RegDst   = 1'b1;
                    ALUOp    = 2'b10;
                    RegWrite = 1'b1;
                end
            end

            6'b100011: begin // lw
                //load computes an address in the ALU, then writes memory data back
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            6'b101011: begin // sw
                //store also uses the ALU for the effective address, but no writeback
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end

            6'b000100: begin // beq
                //the actual take/not-take decision happens later with zero_flag
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            6'b000101: begin // bne
                //same compare datapath as beq, different sense at the top-level
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            6'b001000: begin // addi
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            6'b001100: begin // andi
                //this one is a good place to mess up extension rules, so keep it explicit
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            6'b001101: begin // ori
                //logic immediates keep the upper half zeroed
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            6'b001110: begin // xori
                //same zero-extend rule here too
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
                //unsigned compare, but still through the immediate ALU path
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
                //jal asks for both a jump and a link writeback
                Jump     = 1'b1;
                JAL      = 1'b1;
                RegWrite = 1'b1;
            end
        endcase
    end
endmodule
