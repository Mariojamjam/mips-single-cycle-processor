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

    // Main control unit.
    // Decodes the instruction opcode (and funct field for R-type instructions)
    // and generates all control signals required by the datapath.

    always @(*) begin

        // Default values assigned to all control signals.
        // These defaults prevent latch inference and provide
        // a safe behavior for unsupported opcodes.

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

            // R-type instructions
            6'b000000: begin
            
                // jr (jump register)
                // Updates the PC using the value stored in a register.
                if (funct == 6'b001000) begin
                    //jr only redirects the PC
                    JR = 1'b1;
                end

                // Arithmetic and logical R-type instructions.
                // The ALU result is written into register rd.
                else begin
                    //regular R-type writes the ALU result into rd
                    RegDst   = 1'b1;
                    ALUOp    = 2'b10;
                    RegWrite = 1'b1;
                end
            end

            // lw (load word)
            // Reads a word from memory and writes it into a register.
            6'b100011: begin
                //load computes an address in the ALU, then writes memory data back
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            // sw (store word)
            // Writes a register value into memory.
            6'b101011: begin
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end

            // beq (branch if equal)
            // Performs a comparison and enables branch logic.
            6'b000100: begin
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            // bne (branch if not equal)
            // Uses the same comparison hardware as beq.
            6'b000101: begin
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end

            // addi (add immediate)
            // Adds a sign-extended immediate to a register value.
            6'b001000: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            // andi (AND immediate)
            // Uses zero extension for the immediate field.
            6'b001100: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            // ori (OR immediate)
            // Uses zero extension for the immediate field.
            6'b001101: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            // xori (XOR immediate)
            // Uses zero extension for the immediate field.
            6'b001110: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                ZeroExt  = 1'b1;
            end

            // slti (set less than immediate)
            // Signed comparison with an immediate operand.
            6'b001010: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            // sltiu (set less than immediate unsigned)
            // Unsigned comparison with an immediate operand.
            6'b001011: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end

            // lui (load upper immediate)
            // Loads the immediate value into the upper 16 bits.
            6'b001111: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                LUI      = 1'b1;
            end

            // j (jump)
            // Performs an unconditional jump.
            6'b000010: begin
                Jump = 1'b1;
            end

            // jal (jump and link)
            // Performs a jump and stores the return address.
            6'b000011: begin
                Jump     = 1'b1;
                JAL      = 1'b1;
                RegWrite = 1'b1;
            end
        endcase
    end
endmodule
