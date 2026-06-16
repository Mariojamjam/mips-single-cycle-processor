module regfile(
    input wire [4:0] ReadAddr1,
    input wire [4:0] ReadAddr2,
    input wire Clock,

    input wire [4:0] WriteAddr,
    input wire [31:0] WriteData,

    input wire RegWrite,
    input wire Reset,

    output wire [31:0] ReadData1,  
    output wire [31:0] ReadData2

);

    reg [31:0] regs [0:31];

    //$zero is fixed at 0, the rest come from the array
    assign ReadData1 = (ReadAddr1 == 5'b0) ? 32'b0 : regs[ReadAddr1];
    assign ReadData2 = (ReadAddr2 == 5'b0) ? 32'b0 : regs[ReadAddr2];

    integer i;
    always @(posedge Clock) begin
        if (Reset) begin
            //clear the whole bank so tests start from something known
            for (i = 0; i  < 32; i  = i  + 1) begin
                regs[i] <= 32'b0; 
            end
        end else if (RegWrite && WriteAddr != 5'b0) begin
            //writes to register 0 are ignored on purpose
            regs[WriteAddr] <= WriteData; 
        end
    end


endmodule
