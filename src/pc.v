module pc (
    input wire clk,
    input wire Reset,
    input wire [31:0] nextPC,
    output reg [31:0] currentPC
);

always @(posedge clk or posedge Reset) begin
    //reset should restart fetch from address 0 right away
    if (Reset)
        currentPC <= 32'h00000000;
    else
        //otherwise just latch the next address for the new cycle
        currentPC <= nextPC;
end

endmodule
