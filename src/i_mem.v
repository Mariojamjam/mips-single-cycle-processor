module i_mem #(
    parameter DEPTH    = 1024,
    parameter MEM_FILE = "programs/instruction.list"
)(
    input  wire [31:0] address,
    output wire [31:0] i_out
);
    reg [31:0] mem [0:DEPTH-1];

    initial begin
        //load the test program once when simulation starts
        $readmemb(MEM_FILE, mem);
    end

    //byte address in, word slot inside the array
    assign i_out = mem[address >> 2];

endmodule
