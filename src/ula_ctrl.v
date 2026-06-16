module ula_ctrl (
    input  wire [1:0] ALUOp,
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output reg  [3:0] ULAOp
);

    always @(*) begin
        case (ALUOp)
            2'b00: ULAOp = 4'b0100; // ADD: lw/sw address calculation
            2'b01: ULAOp = 4'b0101; // SUB: beq/bne comparison
            2'b10: begin
                case (funct)
                    6'b100100: ULAOp = 4'b0000; // AND
                    6'b100101: ULAOp = 4'b0001; // OR
                    6'b100110: ULAOp = 4'b0010; // XOR
                    6'b100111: ULAOp = 4'b0011; // NOR
                    6'b100000: ULAOp = 4'b0100; // ADD
                    6'b100010: ULAOp = 4'b0101; // SUB
                    6'b101010: ULAOp = 4'b0110; // SLT
                    6'b101011: ULAOp = 4'b0111; // SLTU
                    6'b000000: ULAOp = 4'b1000; // SLL
                    6'b000010: ULAOp = 4'b1001; // SRL
                    6'b000011: ULAOp = 4'b1010; // SRA
                    6'b000100: ULAOp = 4'b1011; // SLLV
                    6'b000110: ULAOp = 4'b1100; // SRLV
                    6'b000111: ULAOp = 4'b1101; // SRAV
                    default:   ULAOp = 4'b0000;
                endcase
            end
            2'b11: begin
                case (opcode)
                    6'b001100: ULAOp = 4'b0000; // ANDI
                    6'b001101: ULAOp = 4'b0001; // ORI
                    6'b001110: ULAOp = 4'b0010; // XORI
                    6'b001000: ULAOp = 4'b0100; // ADDI
                    6'b001010: ULAOp = 4'b0110; // SLTI
                    6'b001011: ULAOp = 4'b0111; // SLTIU
                    default:   ULAOp = 4'b0000;
                endcase
            end
            default: ULAOp = 4'b0000;
        endcase
    end

endmodule
