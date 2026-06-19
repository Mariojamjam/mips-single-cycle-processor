module tb_mips_wave;
    reg Clock;
    reg Reset;

    wire [31:0] PC;
    wire [31:0] ULAResult;
    wire [31:0] DataMemoryOut;
    reg  [31:0] last_t9;
    //test-only signal

    mips_top #(
        .INSTRUCTION_DEPTH(128)
    ) uut (
        .Clock(Clock),
        .Reset(Reset),
        .PC(PC),
        .ULAResult(ULAResult),
        .DataMemoryOut(DataMemoryOut)
    );

    always #5 Clock = ~Clock;

    always @(posedge Clock) begin
        //t9 works as a built-in test marker in the bigger assembly program
        if (uut.register_file.regs[25] !== last_t9) begin
            $display("TEST MARKER: t9=%h PC=%h", uut.register_file.regs[25], PC);
            last_t9 <= uut.register_file.regs[25];
        end
    end

    initial begin
        $dumpfile("sim/mips_wave.vcd");
        $dumpvars(0, tb_mips_wave);

        Clock = 1'b0;
        Reset = 1'b1;
        last_t9 = 32'bx;
        #12;
        Reset = 1'b0;

        //long enough to inspect the full program flow in GTKWave
        repeat (90) begin @(posedge Clock);
            #1;
            //printing instruction next to PC and ULA output saves a lot of guesswork
            $display("PC=%h instr=%h ula=%h", PC, uut.instruction, ULAResult);
        end

        $finish;
    end

endmodule
