import Fifo::*;

import FPSmall::*;

(* synthesize *)
module mkLI_FPSmallMultiplier(LI_FPSmallALU);
    /*** Latency Insensitive Implementation ***/


    /*** Fifos ***/
    Fifo#(1, FPSmall) argA <- mkBypassFifo();
    Fifo#(1, FPSmall) argB <- mkBypassFifo();
    Fifo#(1, FPSmall) result <- mkBypassFifo();


    /*** Internal States ***/
    // Some inputs require multiple cycles (to shift mantissa) to finish computation.
    // In this case isShifting register is set to `True`.
    Reg#(Bool) isShifting <- mkReg(False);

    // These registers save temporary values when shifting.
    Reg#(FPSmallSign) resultSignReg <- mkRegU();
    Reg#(FPSmallExponentAdded) resultExponentAddedReg <- mkRegU();
    Reg#(FPSmallMantissaMultiplied) resultMantissaMultipliedReg <- mkRegU();


    /*** Rules ***/
    rule doCompute if (!isShifting);
        // Fetch operands from the fifos, and decode them.
        //   - (1) Exponent != 0  ->  Mantissa = 0...01.xxx (Normal Value)
        //   - (2) Exponent == 0  ->  Mantissa = 0...00.xxx (Denormal Value)
        //       => In demornal case, exponent should be set to 1.
        let a = argA.first();
        argA.deq();

        let b = argB.first();
        argB.deq();

        FPSmallSign aSign = a[6];
        FPSmallSign bSign = b[6];

        FPSmallExponentAdded aExponent = zeroExtend(a[5:3]);
        FPSmallExponentAdded bExponent = zeroExtend(b[5:3]);

        FPSmallMantissaMultiplied aMantissa = ?;
        FPSmallMantissaMultiplied bMantissa = ?;

        if (aExponent != 0) begin
            aMantissa = zeroExtend({1'b1, a[2:0]});
        end else begin
            aMantissa = zeroExtend({1'b0, a[2:0]});
            aExponent = 1;
        end

        if (bExponent != 0) begin
            bMantissa = zeroExtend({1'b1, b[2:0]});
        end else begin
            bMantissa = zeroExtend({1'b0, b[2:0]});
            bExponent = 1;
        end


        /*** TODO: Implement inf/NaN arithmetic here ***/


        // Now compute these values.
        FPSmallSign resultSign = ?;
        FPSmallExponentAdded resultExponentAdded = ?;
        FPSmallMantissaMultiplied resultMantissaMultiplied = ?;


        // 1. resultSign: Multply two signs.
        //   - If signs are equal. resultSign = 0
        //   - If signs are different, resultSign = 1
        //
        // 2. resultExponentAdded: Add two exponent
        //   - Considering bias b, we should compute:
        //         (aExponent - b) + (bExponent - b)
        //      =  (aExponent + bExponent) - 2b
        //      =  (aExponent + bExponent - b) - b
        //   Thus, new resultExponentAdded = (aExponent + bExponent - b)
        // 
        // 3. resultMantissaMultiplied: Multiply two mantissas
        //   - Regardless of sign / exponent value.
        if (aSign == bSign) begin
            resultSign = 1'b0;
        end else begin
            resultSign = 1'b1;
        end

        let bias = (1 << 2) - 1;  // 3-bit exponent: 1 << ('3-bit' - 1) - 1
        resultExponentAdded = aExponent + bExponent - bias;

        resultMantissaMultiplied = aMantissa * bMantissa;


        // Decode the result: Getting resultExponent and resultMantissa.
        FPSmallExponent resultExponent = ?;
        FPSmallMantissa resultMantissa = ?;


        /*** TODO: 
            Please check that some inputs could generate inf.
            This could be checked if resultExponentAdded[3] == 1'b1 after computation.    
        ***/


        // At this point, resultMantissaMultiplied would be one of the following 4 cases:
        //   (1) 1x.yyyyyy => resultExponentAdded should be incremented by 1, resultMantissa is xyy
        //                    resultExponent simply truncates the resultExponentAdded.
        //   (2) 01.xxxxxx => resultExponentAdded stays the same, resultMantissa is xxx
        //                    resultExponent simply truncates the resultExponentAdded.
        //   (3) 00.000000 => Result is 0. Both resultExponent and resultMantissa are 0
        //   (4) 00.xxxxxx => This case requires shifting.
        //          Shift the value to the left until it becomes 01.xxx form.
        //          Then the resultMantissa could be set to xxx.
        //          One left shifting requires exponent decrement by 1.
        if (resultMantissaMultiplied[7] == 1'b1) begin
            resultExponentAdded = resultExponentAdded + 1;
            resultExponent = truncate(resultExponentAdded);

            resultMantissa = resultMantissaMultiplied[6:4];

            result.enq({resultSign, resultExponent, resultMantissa});
        end else if (resultMantissaMultiplied[6] == 1'b1) begin
            resultExponent = truncate(resultExponentAdded);

            resultMantissa = resultMantissaMultiplied[5:3];

            result.enq({resultSign, resultExponent, resultMantissa});
        end else if (resultMantissaMultiplied == 0) begin
            resultExponent = 0;
            resultMantissa = 0;

            result.enq({resultSign, resultExponent, resultMantissa});
        end else begin
            resultSignReg <= resultSign;
            resultExponentAddedReg <= resultExponentAdded;
            resultMantissaMultipliedReg <= resultMantissaMultiplied;

            isShifting <= True;
        end
    endrule


    rule shiftMantissa if (isShifting);
        // Shift resultMantissaAddedReg to the left until it reaches 01.xxxxxx form.
        // Shifting left by 1 requires resultExponentReg decremented by 1.
        //   => Terminate shifting when form 01.xxx reached.
        if (resultMantissaAddedReg[6] == 1'b1) begin
            FPSmallExponent resultExponent = truncate(resultExponentAddedReg);
            FPSmallMantissa resultMantissa = resultMantissaAddedReg[5:3];

            result.enq({resultSignReg, resultExponent, resultMantissa});

            isShifting <= False;
        end else begin
            resultMantissaMultipliedReg <= resultMantissaMultipliedReg << 1;
            resultExponentAddedReg <= resultExponentAddedReg - 1;
        end
    endrule


    /*** Interfaces ***/
    method Action putArgA(FPSmall argA_);
        argA.enq(argA_);
    endmethod

    method Action putArgB(FPSmall argB_);
        argB.enq(argB_);
    endmethod

    method ActionValue#(FPSmall) getResult();
        result.deq();
        return result.first();
    endmethod
endmodule
