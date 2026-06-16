module ula (
    input  wire [31:0] In1,
    input  wire [31:0] In2,
    input  wire [4:0]  shamt,
    input  wire [3:0]  OP,
    output reg  [31:0] result,
    output wire        Zero_flag
);

    assign Zero_flag = (result == 32'b0);

    always @(*) begin
        //matches the encoding chosen in ula_ctrl
        case (OP)
            4'b0000: result = In1 & In2;                                        // AND
            4'b0001: result = In1 | In2;                                        // OR
            4'b0010: result = In1 ^ In2;                                        // XOR
            4'b0011: result = ~(In1 | In2);                                     // NOR
            4'b0100: result = In1 + In2;                                        // ADD
            4'b0101: result = In1 - In2;                                        // SUB
            4'b0110: result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;   // SLT
            4'b0111: result = (In1 < In2) ? 32'd1 : 32'd0;                     // SLTU
            4'b1000: result = In2 << shamt;                                     // SLL
            4'b1001: result = In2 >> shamt;                                     // SRL
            4'b1010: result = $signed(In2) >>> shamt;                           // SRA
            4'b1011: result = In2 << In1[4:0];                                  // SLLV
            4'b1100: result = In2 >> In1[4:0];                                  // SRLV
            4'b1101: result = $signed(In2) >>> In1[4:0];                        // SRAV
            default: result = 32'b0;
        endcase
    end

endmodule
