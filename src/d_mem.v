module d_mem#(parameter SIZE=1024)(
    input wire [31:0] Address,
    input wire [31:0] WriteData,

    input wire Clock,

    input wire MemRead,
    input wire MemWrite,

    output wire [31:0] ReadData
);
    //keeps the memory behavior simple enough to reason about in waveforms

    reg [31:0] mem [0:SIZE-1];
    //plain word-addressed RAM model, good enough for these integration tests

    //reads happen directly from the selected word
    assign ReadData = MemRead ? mem[Address >> 2] : 32'bz;

    always @(posedge Clock) begin
        if (MemWrite) begin
            //stores update memory on the clock edge
            //that makes repeated writes easier to follow in the wave
            mem[Address >> 2] <= WriteData; 
        end
    end

endmodule
