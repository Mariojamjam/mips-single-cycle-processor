module i_mem #(parameter MEM_FILE = "programs/instruction.list")(
    input  wire [31:0] address,
    output wire [31:0] i_out
);
    reg [31:0] mem [0:1023];

    initial begin
        $readmemb(MEM_FILE, mem);
    end

    assign i_out = mem[address >> 2];
endmodule