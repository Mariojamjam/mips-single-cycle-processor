module pc (
    input wire clk,
    input wire Reset,
    input wire [31:0] nextPC,
    output reg [31:0] currentPC
);

//tiny module, but fetch depends on it being boring and predictable
//if this guy glitches, everything downstream starts looking suspicious
always @(posedge clk or posedge Reset) begin
    //reset should restart fetch from address 0 right away
    if (Reset)
        currentPC <= 32'h00000000;
    else
        //otherwise just latch the next address for the new cycle
        //one cycle later the new instruction shows up from i_mem
        currentPC <= nextPC;
end

endmodule
