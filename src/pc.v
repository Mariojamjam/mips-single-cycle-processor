module pc (
    input wire clk,
    input wire reset,
    input wire [31:0] nextPC,
    output reg [31:0] currentPC
);

always @(posedge clk or posedge reset) begin
    if (reset)
        currentPC <= 32'h00000000;
    else
        currentPC <= nextPC;
end

endmodule