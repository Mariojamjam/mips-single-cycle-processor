module mips_top #(
    parameter INSTRUCTION_FILE = "programs/instruction.list",
    parameter INSTRUCTION_DEPTH = 1024
)(
    input  wire        Clock,
    input  wire        Reset,
    output wire [31:0] PC,
    output wire [31:0] ULAResult,
    output wire [31:0] DataMemoryOut
);

    wire [31:0] instruction;
    wire [5:0]  opcode;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [4:0]  shamt;
    wire [5:0]  funct;
    wire [15:0] immediate;
    wire [25:0] jump_address;

    wire        RegDst;
    wire        Branch;
    wire        MemRead;
    wire        MemtoReg;
    wire [1:0]  ALUOp;
    wire        MemWrite;
    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire        JAL;
    wire        JR;

    wire [3:0]  ULAOp;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] immediate_extended;
    wire [31:0] alu_in2;
    wire [31:0] write_data;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [31:0] next_pc;
    wire [4:0]  write_addr;
    wire        zero_flag;
    wire        is_bne;
    wire        branch_taken;
    wire        jr_instruction;
    wire        reg_write_enabled;

    assign opcode       = instruction[31:26];
    assign rs           = instruction[25:21];
    assign rt           = instruction[20:16];
    assign rd           = instruction[15:11];
    assign shamt        = instruction[10:6];
    assign funct        = instruction[5:0];
    assign immediate    = instruction[15:0];
    assign jump_address = instruction[25:0];

    assign immediate_extended = {{16{immediate[15]}}, immediate};
    assign alu_in2            = ALUSrc ? immediate_extended : read_data2;
    assign write_addr         = JAL ? 5'd31 : (RegDst ? rd : rt);
    assign write_data         = JAL ? pc_plus_4 : (MemtoReg ? DataMemoryOut : ULAResult);
    assign pc_plus_4          = PC + 32'd4;
    assign branch_target      = pc_plus_4 + (immediate_extended << 2);
    assign jump_target        = {pc_plus_4[31:28], jump_address, 2'b00};
    assign is_bne             = (opcode == 6'b000101);
    assign branch_taken       = Branch && (is_bne ? !zero_flag : zero_flag);
    assign jr_instruction     = (opcode == 6'b000000) && (funct == 6'b001000);
    assign reg_write_enabled  = RegWrite && !jr_instruction;
    assign next_pc            = jr_instruction ? read_data1 :
                                (Jump ? jump_target :
                                (branch_taken ? branch_target : pc_plus_4));

    pc pc_unit (
        .clk(Clock),
        .Reset(Reset),
        .nextPC(next_pc),
        .currentPC(PC)
    );

    i_mem #(
        .DEPTH(INSTRUCTION_DEPTH),
        .MEM_FILE(INSTRUCTION_FILE)
    ) instruction_memory (
        .address(PC),
        .i_out(instruction)
    );

    ctrl control_unit (
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

    regfile register_file (
        .ReadAddr1(rs),
        .ReadAddr2(rt),
        .Clock(Clock),
        .WriteAddr(write_addr),
        .WriteData(write_data),
        .RegWrite(reg_write_enabled),
        .Reset(Reset),
        .ReadData1(read_data1),
        .ReadData2(read_data2)
    );

    ula_ctrl alu_control (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .funct(funct),
        .ULAOp(ULAOp)
    );

    ula alu (
        .In1(read_data1),
        .In2(alu_in2),
        .shamt(shamt),
        .OP(ULAOp),
        .result(ULAResult),
        .Zero_flag(zero_flag)
    );

    d_mem data_memory (
        .Address(ULAResult),
        .WriteData(read_data2),
        .Clock(Clock),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ReadData(DataMemoryOut)
    );

endmodule
