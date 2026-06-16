module pc (
    input wire clk,
    input wire Reset,
    input wire [31:0] nextPC,
    output reg [31:0] currentPC
);

always @(posedge clk or posedge Reset) begin
    if (Reset)
        currentPC <= 32'h00000000;
    else
        currentPC <= nextPC;
end

endmodule