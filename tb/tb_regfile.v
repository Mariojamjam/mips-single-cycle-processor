module tb_regfile;
    reg         Clock;
    reg         RegWrite;
    reg         Reset;
    reg  [4:0]  ReadAddr1;
    reg  [4:0]  ReadAddr2;
    reg  [4:0]  WriteAddr;
    reg  [31:0] WriteData;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    //this one reads like a tiny usage script for the register file

    regfile uut (
        .ReadAddr1(ReadAddr1),
        .ReadAddr2(ReadAddr2),
        .Clock(Clock),
        .WriteAddr(WriteAddr),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .Reset(Reset),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    integer errors = 0;
    //direct scenarios are enough because the regfile interface is pretty small
    //Compares actual against expected, logs PASS/FAIL with operation label
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input [63:0] label;
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
            //makes the write timing explicit in each test block
            #5 Clock = 1;
            #5 Clock = 0;
        end
    endtask

    initial begin
        Clock = 0; RegWrite = 0; Reset = 0;
        ReadAddr1 = 0; ReadAddr2 = 0;
        WriteAddr = 0; WriteData = 0;

        //start clean so untouched registers are predictable
        Reset = 1;
        tick;
        Reset = 0;

        //write one register and read it back
        RegWrite = 1; WriteAddr = 5'd8; WriteData = 32'hDEADBEEF; tick;
        ReadAddr1 = 5'd8;
        #1;
        check(32'hDEADBEEF, ReadData1, "write+read $t0");

        //both read ports should work together
        WriteAddr = 5'd9; WriteData = 32'hCAFEBABE; tick;
        ReadAddr1 = 5'd8; ReadAddr2 = 5'd9;
        #1;
        check(32'hDEADBEEF, ReadData1, "simultaneous read $t0");
        check(32'hCAFEBABE, ReadData2, "simultaneous read $t1");

        //$0 must ignore writes by design
        WriteAddr = 5'd0; WriteData = 32'hFFFFFFFF; tick;
        ReadAddr1 = 5'd0;
        #1;
        check(32'b0, ReadData1, "$0 write protected");

        //disabled writes should leave the target alone
        RegWrite = 0; WriteAddr = 5'd10; WriteData = 32'h12345678; tick;
        ReadAddr1 = 5'd10;
        #1;
        check(32'b0, ReadData1, "RegWrite=0 no write");

        //reset should wipe values written earlier
        RegWrite = 1; WriteAddr = 5'd5; WriteData = 32'hAAAAAAAA; tick;
        Reset = 1; RegWrite = 0; tick;
        Reset = 0;
        ReadAddr1 = 5'd8; ReadAddr2 = 5'd5;
        #1;
        check(32'b0, ReadData1, "reset clears $t0");
        check(32'b0, ReadData2, "reset clears $t1");

        if (errors == 0)
            $display("ALL PASS — %0d tests", 7);
        else begin
            $display("FAILED — %0d error(s)", errors);
            $finish(1);
        end

        $finish;
    end

endmodule
