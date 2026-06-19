module pc (
    input wire clk,
    input wire Reset,
    input wire [31:0] nextPC,
    output reg [31:0] currentPC
);

    // Program Counter (PC).
    // Stores the address of the instruction currently being fetched.

    // PC update logic.
    // The PC is updated on the rising edge of the clock.
    // Reset has priority over normal operation.


always @(posedge clk or posedge Reset) begin

    // When Reset is asserted, execution restarts from address 0.
    if (Reset)
        currentPC <= 32'h00000000;

    // Otherwise, load the next instruction address.
    else
        currentPC <= nextPC;
end

endmodule
