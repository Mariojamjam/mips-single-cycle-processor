module tb_d_mem;

    reg         Clock;
    reg  [31:0] Address;
    reg  [31:0] WriteData;
    reg         MemRead;
    reg         MemWrite;
    wire [31:0] ReadData;

    d_mem uut (
        .Clock(Clock),
        .Address(Address),
        .WriteData(WriteData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ReadData(ReadData)
    );

    integer errors = 0;

    //Compares actual against expected, logs PASS/FAIL with operation label
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [127:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL [%s]: got %h, expected %h", label, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS [%s]", label);
        end
    endtask

    //Triggers one rising clock edge
    task tick;
        begin
            #5 Clock = 1;
            #5 Clock = 0;
        end
    endtask

    initial begin
        //Write and read back
        Clock = 0;
        MemWrite = 1; MemRead = 0; Address = 32'd0;; WriteData = 32'hAAAAAAAA; tick;
        MemWrite = 0; MemRead = 1; #1;
        check(32'hAAAAAAAA, ReadData, "write+read");

        //Check impedance when write and read are both 0
        MemWrite = 0; MemRead = 0; Address = 32'd0; #1;
        check(32'bz, ReadData, " impedance");

        //Check if the writing permission is denied with MemWrite = 0
        //First, we need to insert a known value in 32'd4 to check later
        MemWrite = 1; MemRead = 0; Address = 32'd4; WriteData = 32'hBCDAADCB; tick;

        MemRead=0; MemWrite = 0; Address = 32'd4; WriteData = 32'd1; tick;
        MemWrite = 0; MemRead = 1; Address = 32'd4; #1;
        check(32'hBCDAADCB, ReadData, "write denied");


        //Write different values to different addresses and verify no overlap
        MemWrite = 1; MemRead = 0; Address = 32'd0;  WriteData = 32'hAAAAAAAA; tick;
        MemWrite = 1; MemRead = 0; Address = 32'd4;  WriteData = 32'hBBBBBBBB; tick;
        MemWrite = 1; MemRead = 0; Address = 32'd8;  WriteData = 32'hCCCCCCCC; tick;
        MemWrite = 0; MemRead = 1;

        Address = 32'd0; #1;
        check(32'hAAAAAAAA, ReadData, "addr 0");

        Address = 32'd4; #1;
        check(32'hBBBBBBBB, ReadData, "addr 4");

        Address = 32'd8; #1;
        check(32'hCCCCCCCC, ReadData, "addr 8");

        if (errors == 0)
            $display("ALL PASS — %0d tests", 7);
        else begin
            $display("FAILED — %0d error(s)", errors);
            $finish(1);
        end
        $finish;
    end

    
endmodule
