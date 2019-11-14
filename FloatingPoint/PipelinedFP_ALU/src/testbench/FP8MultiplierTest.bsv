import FP8::*;

import FP8Multiplier::*;


typedef Bit#(32) SimInt;
SimInt maxCycle = 10000;


// Test cases

// Case 1: (positive) * (positive) = (positive)
// Case 2: (positive) * (negative) = (negative)
// Case 3: (negative) * (negative) = (positive)
// Case 4: (denormal) * (normal)
// Case 5: (+large) * (+large) = (+Inf)
// Case 6: (+large) * (-large) = (-Inf)
// Case 7: (+small) * (+small) = (+0)
// Case 8: (+small) * (-small) = (-0)
// Case 9: (+0) * (-0) = (-0)
// Case 10: (-0) * (-0) = (+0)
// Case 11: (negative) * (+0) = (-0)
// Case 12: (NaN) * (positive) = (Nan)
// Case 13: (NaN) * (-Inf) = (NaN)
// Case 14: (+Inf) * (negative) = (-Inf)
// Case 15: (-Inf) * (-Inf) = (+Inf)
// Case 16: (-Inf) * (+Inf) = (-Inf)


(* synthesize *)
module mkFP8MultiplierTest();
    /*** Unit Under Test ***/
    let fp8Multiplier <- mkFP8Multiplier();


    /*** States ***/
    Reg#(SimInt) cycle <- mkReg(0);
    Reg#(SimInt) testCase <- mkReg(1);
    Reg#(Bool) isPut <- mkReg(True);

    
    /*** Simulation ***/
    rule simulation if (cycle < maxCycle);
        cycle <= cycle + 1;
    endrule

    rule finishSimulation if (cycle >= maxCycle);
        $display("[Sim] Simulation Finished: Max cycle %d", maxCycle);
        $finish(0);
    endrule


    /*** Test Cases ***/
    // Case 1
    rule putCase1 if (testCase == 1 && isPut);
        fp8Multiplier.putArgA(8'b0_0111_000);
        fp8Multiplier.putArgB(8'b0_0111_101);
        isPut <= False;
    endrule

    rule getCase1 if (testCase == 1 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_0111_101;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 1");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 1");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 2
    rule putCase2 if (testCase == 2 && isPut);
        fp8Multiplier.putArgA(8'b0_1001_110);
        fp8Multiplier.putArgB(8'b1_1000_011);
        isPut <= False;
    endrule

    rule getCase2 if (testCase == 2 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_1011_001;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 2");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 2");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 3
    rule putCase3 if (testCase == 3 && isPut);
        fp8Multiplier.putArgA(8'b1_1100_110);
        fp8Multiplier.putArgB(8'b1_0111_000);
        isPut <= False;
    endrule

    rule getCase3 if (testCase == 3 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_1100_110;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 3");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 3");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 4
    rule putCase4 if (testCase == 4 && isPut);
        fp8Multiplier.putArgA(8'b0_0000_110);
        fp8Multiplier.putArgB(8'b0_1100_101);
        isPut <= False;
    endrule

    rule getCase4 if (testCase == 4 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_0110_001;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 4");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 4");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 5
    rule putCase5 if (testCase == 5 && isPut);
        fp8Multiplier.putArgA(8'b0_1110_110);
        fp8Multiplier.putArgB(8'b0_1011_101);
        isPut <= False;
    endrule

    rule getCase5 if (testCase == 5 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_1111_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 5");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 5");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 6
    rule putCase6 if (testCase == 6 && isPut);
        fp8Multiplier.putArgA(8'b1_1110_101);
        fp8Multiplier.putArgB(8'b0_1011_111);
        isPut <= False;
    endrule

    rule getCase6 if (testCase == 6 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_1111_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 6");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 6");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 7
    rule putCase7 if (testCase == 7 && isPut);
        fp8Multiplier.putArgA(8'b0_0011_100);
        fp8Multiplier.putArgB(8'b0_0001_111);
        isPut <= False;
    endrule

    rule getCase7 if (testCase == 7 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_0000_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 7");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 7");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 8
    rule putCase8 if (testCase == 8 && isPut);
        fp8Multiplier.putArgA(8'b0_0010_001);
        fp8Multiplier.putArgB(8'b1_0011_001);
        isPut <= False;
    endrule

    rule getCase8 if (testCase == 8 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_0000_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 8");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 8");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 9
    rule putCase9 if (testCase == 9 && isPut);
        fp8Multiplier.putArgA(8'b0_0000_000);
        fp8Multiplier.putArgB(8'b1_0000_000);
        isPut <= False;
    endrule

    rule getCase9 if (testCase == 9 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_0000_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 9");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 9");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 10
    rule putCase10 if (testCase == 10 && isPut);
        fp8Multiplier.putArgA(8'b1_0000_000);
        fp8Multiplier.putArgB(8'b1_0000_000);
        isPut <= False;
    endrule

    rule getCase10 if (testCase == 10 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_0000_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 10");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 10");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 11
    rule putCase11 if (testCase == 11 && isPut);
        fp8Multiplier.putArgA(8'b1_0110_101);
        fp8Multiplier.putArgB(8'b0_0000_000);
        isPut <= False;
    endrule

    rule getCase11 if (testCase == 11 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_0000_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 11");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 11");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 12
    rule putCase12 if (testCase == 12 && isPut);
        fp8Multiplier.putArgA(8'b0_1111_001);
        fp8Multiplier.putArgB(8'b0_0110_001);
        isPut <= False;
    endrule

    rule getCase12 if (testCase == 12 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_1111_001;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 12");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 12");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 13
    rule putCase13 if (testCase == 13 && isPut);
        fp8Multiplier.putArgA(8'b0_1111_001);
        fp8Multiplier.putArgB(8'b0_1111_000);
        isPut <= False;
    endrule

    rule getCase13 if (testCase == 13 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_1111_001;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 13");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 13");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 14
    rule putCase14 if (testCase == 14 && isPut);
        fp8Multiplier.putArgA(8'b0_1111_000);
        fp8Multiplier.putArgB(8'b1_0111_111);
        isPut <= False;
    endrule

    rule getCase14 if (testCase == 14 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_1111_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 14");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 14");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 15
    rule putCase15 if (testCase == 15 && isPut);
        fp8Multiplier.putArgA(8'b1_1111_000);
        fp8Multiplier.putArgB(8'b1_1111_000);
        isPut <= False;
    endrule

    rule getCase15 if (testCase == 15 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b0_1111_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 15");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 15");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    // Case 16
    rule putCase16 if (testCase == 16 && isPut);
        fp8Multiplier.putArgA(8'b0_1111_000);
        fp8Multiplier.putArgB(8'b1_1111_000);
        isPut <= False;
    endrule

    rule getCase16 if (testCase == 16 && !isPut);
        let result <- fp8Multiplier.getResult();
        FP8 correctResult = 8'b1_1111_000;

        if (result == correctResult) begin
            $display("[Test] Pass: Case 16");
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("[Test] Fail: Case 16");
            $display("[Test] Correct Result: %b", correctResult);
            $display("[Test] Module Result: %b", result);
            $finish(-1);
        end
    endrule

    rule finishTest if (testCase > 16);
        $display("[Sim] Unit test done.");
        $finish(0);
    endrule
endmodule
