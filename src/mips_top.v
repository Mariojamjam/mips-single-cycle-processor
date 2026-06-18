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
    //single-cycle glue module: fetch, decode, execute, memory, and writeback all meet here

    //split the raw instruction early so the rest of the datapath reads cleaner
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
    wire        LUI;

    wire [3:0]  ULAOp;
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] sign_extended_immediate;
    wire [31:0] zero_extended_immediate;
    wire [31:0] immediate_extended;
    
    wire [31:0] alu_in2;
    wire [31:0] lui_value;
    wire [31:0] write_data;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_plus_8;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [31:0] next_pc;
    wire [4:0]  write_addr;
    wire        zero_flag;
    wire        is_bne;
    wire        branch_taken;
    wire        reg_write_enabled;

    wire ZeroExt;

    //classic MIPS field extraction
    assign opcode       = instruction[31:26];
    assign rs           = instruction[25:21];
    assign rt           = instruction[20:16];
    assign rd           = instruction[15:11];
    assign shamt        = instruction[10:6];
    assign funct        = instruction[5:0];
    assign immediate    = instruction[15:0];
    assign jump_address = instruction[25:0];

    //logic immediates use zeros, the others keep the sign
    assign sign_extended_immediate = {{16{immediate[15]}}, immediate};
    assign zero_extended_immediate = {16'b0, immediate};

    //ctrl decides which immediate flavor this instruction wants
    assign immediate_extended = ZeroExt ? zero_extended_immediate : sign_extended_immediate;

    //ALUSrc picks between register data and the immediate path
    assign alu_in2            = ALUSrc ? immediate_extended : read_data2;
    //jal writes $ra, regular R-type writes rd, immediates usually write rt
    assign write_addr         = JAL ? 5'd31 : (RegDst ? rd : rt);

    //writeback can come from jal, lui, memory, or the ALU
    assign write_data         = JAL ? pc_plus_8 :
                                LUI ? lui_value :
                                (MemtoReg ? DataMemoryOut : ULAResult);
                    
    assign pc_plus_4          = PC + 32'd4;
    assign pc_plus_8          = PC + 32'd8;
    //branch immediate is already extended before shifting left by 2
    assign branch_target      = pc_plus_4 + (immediate_extended << 2);
    //jump keeps the upper nibble from PC+4, like the usual MIPS datapath
    assign jump_target        = {pc_plus_4[31:28], jump_address, 2'b00};
    assign is_bne             = (opcode == 6'b000101);
    //beq and bne share the same branch signal, so we split here
    assign branch_taken       = Branch && (is_bne ? !zero_flag : zero_flag);
    assign reg_write_enabled = RegWrite;
    //jr wins first, then j/jal, then branches, then plain fall-through
    assign next_pc = JR ? read_data1 :
                Jump ? jump_target :
                 branch_taken ? branch_target :
                 pc_plus_4;

    //lui drops the immediate in the upper 16 bits
    assign lui_value = {immediate, 16'b0};

    //PC is the state holder for the fetch path
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

    //ctrl decides the high-level behavior, top-level just wires the consequences
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
        .JR(JR),
        .LUI(LUI),
        .ZeroExt(ZeroExt),
        .funct(funct)
    );

    //regfile gives us the two source operands and takes the chosen writeback value
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

    //small decode block that turns ALUOp into the exact ALU function code
    ula_ctrl alu_control (
        .ALUOp(ALUOp),
        .opcode(opcode),
        .funct(funct),
        .ULAOp(ULAOp)
    );

    //main execute block
    ula alu (
        .In1(read_data1),
        .In2(alu_in2),
        .shamt(shamt),
        .OP(ULAOp),
        .result(ULAResult),
        .Zero_flag(zero_flag)
    );

    //data memory stays live all the time, even though only lw/sw really care
    d_mem data_memory (
        .Address(ULAResult),
        .WriteData(read_data2),
        .Clock(Clock),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ReadData(DataMemoryOut)
    );

endmodule
