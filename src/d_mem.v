module d_mem#(parameter SIZE=1024)(
    input wire [31:0] Address,
    input wire [31:0] WriteData,

    input wire Clock,

    input wire MemRead,
    input wire MemWrite,

    output wire [31:0] ReadData
);

    reg [31:0] mem [0:SIZE-1];

    assign ReadData = MemRead ? mem[Address >> 2] : 32'bz;

    always @(posedge Clock) begin
        if (MemWrite) begin
            mem[Address >> 2] <= WriteData; 
        end
    end

endmodule
