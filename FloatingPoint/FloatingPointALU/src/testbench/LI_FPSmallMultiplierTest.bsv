import FPSmall::*;
import FPSmallMultiplier::*;


typedef Bit#(64) SimInt;


/* Test Cases */
// Case 1: 2 Positive, Same Exponent, Same Mantissa
// Case 2: 2 Positive, Same Exponent, Different Mantissa
// Case 3: 2 Positive, Different Exponent, Different Mantissa
// Case 4: 2 Positive, Different Exponent, Different Mantissa
// Case 5: 1 Positive > 1 Negative, Different Exponent, Different Mantissa
// Case 6: 1 Positive < 1 Negative, Different Exponent, Different Mantissa
// Case 7: 1 Normal, 1 Denormal Value, Different Exponent, Different Mantissa
// Case 8: 2 Denormal Value, Different Exponent, Different Mantissa
// Case 9: Subtracting Same Number, yielding +0
// Case 10: +0 + +0 = +0
// Case 11: +0 + -0 = +0
// Case 12: -0 + -0 = -0


(* synthesize *)
module mkLI_FPSmallMultiplierTest();
    /* Unit Under Test */
    let li_FPSmallMultiplier <- mkLI_FPSmallMultiplier();

    /* Testbench States */
    Reg#(SimInt) testCase <- mkReg(1);
    Reg#(Bool) isPut <- mkReg(True);

    /* Unit Test */

    // Case 1
    rule put1 if (testCase == 1 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_101_010);
        li_FPSmallMultiplier.putArgB(7'b0_101_010);

        isPut <= False;
    endrule

    rule get1 if (testCase == 1 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_110_010) begin
            $display("Pass: Case 1");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 1");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 2
    rule put2 if (testCase == 2 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_100_101);
        li_FPSmallMultiplier.putArgB(7'b0_100_011);
        isPut <= False;
    endrule

    rule get2 if (testCase == 2 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_101_100) begin
            $display("Pass: Case 2");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 2");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 3
    rule put3 if (testCase == 3 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_101_110);
        li_FPSmallMultiplier.putArgB(7'b0_011_101);
        isPut <= False;
    endrule

    rule get3 if (testCase == 3 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_110_000) begin
            $display("Pass: Case 3");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 3");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 4
    rule put4 if (testCase == 4 && isPut);
        li_FPSmallMultiplier.putArgA(7'b1_101_010);
        li_FPSmallMultiplier.putArgB(7'b1_010_101);
        isPut <= False;
    endrule

    rule get4 if (testCase == 4 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b1_101_011) begin
            $display("Pass: Case 4");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 4");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 5
    rule put5 if (testCase == 5 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_101_100);
        li_FPSmallMultiplier.putArgB(7'b1_100_110);
        isPut <= False;
    endrule

    rule get5 if (testCase == 5 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_100_010) begin
            $display("Pass: Case 5");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 5");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 6
    rule put6 if (testCase == 6 && isPut);
        li_FPSmallMultiplier.putArgA(7'b1_011_000);
        li_FPSmallMultiplier.putArgB(7'b0_001_111);

        isPut <= False;
    endrule

    rule get6 if (testCase == 6 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b1_010_010) begin
            $display("Pass: Case 6");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 6");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 7
    rule put7 if (testCase == 7 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_000_011);
        li_FPSmallMultiplier.putArgB(7'b0_001_101);

        isPut <= False;
    endrule

    rule get7 if (testCase == 7 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_010_000) begin
            $display("Pass: Case 7");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 7");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 8
    rule put8 if (testCase == 8 && isPut);
        li_FPSmallMultiplier.putArgA(7'b1_000_010);
        li_FPSmallMultiplier.putArgB(7'b1_000_111);

        isPut <= False;
    endrule

    rule get8 if (testCase == 8 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b1_001_001) begin
            $display("Pass: Case 8");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 8");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 9
    rule put9 if (testCase == 9 && isPut);
        li_FPSmallMultiplier.putArgA(7'b1_110_101);
        li_FPSmallMultiplier.putArgB(7'b0_110_101);

        isPut <= False;
    endrule

    rule get9 if (testCase == 9 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_000_000) begin
            $display("Pass: Case 9");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 9");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 10
    rule put10 if (testCase == 10 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_000_000);
        li_FPSmallMultiplier.putArgB(7'b0_000_000);

        isPut <= False;
    endrule

    rule get10 if (testCase == 10 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_000_000) begin
            $display("Pass: Case 10");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 10");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Case 11
    rule put11 if (testCase == 11 && isPut);
        li_FPSmallMultiplier.putArgA(7'b0_000_000);
        li_FPSmallMultiplier.putArgB(7'b1_000_000);

        isPut <= False;
    endrule

    rule get11 if (testCase == 11 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b0_000_000) begin
            $display("Pass: Case 11");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 11");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule

    // Case 12
    rule put12 if (testCase == 12 && isPut);
        li_FPSmallMultiplier.putArgA(7'b1_000_000);
        li_FPSmallMultiplier.putArgB(7'b1_000_000);

        isPut <= False;
    endrule

    rule get12 if (testCase == 12 && !isPut);
        let result <- li_FPSmallMultiplier.getResult();

        if (result == 7'b1_000_000) begin
            $display("Pass: Case 12");
            
            testCase <= testCase + 1;
            isPut <= True;
        end else begin
            $display("Fail: Case 12");
            $display("Wrong result yielded: %b", result);
            $finish(-1);
        end    
    endrule


    // Finish
    rule finish if (testCase > 12);
        $display("Unit Test Done.");
        $finish(0);
    endrule
endmodule
