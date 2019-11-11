import Fifo::*;

import FP32::*;

(* synthesize *)
module mkLI_FP32Adder(LI_FP32ALU);
    /*** Latency Insensitive Implementation ***/


    /*** Fifos ***/
    Fifo#(1, FP32) argA <- mkBypassFifo();
    Fifo#(1, FP32) argB <- mkBypassFifo();
    Fifo#(1, FP32) result <- mkBypassFifo();


    /*** Internal States ***/
    // Some inputs require multiple cycles (to shift mantissa) to finish computation.
    // In this case isShifting register is set to `True`.
    Reg#(Bool) isShifting <- mkReg(False);

    // These registers save temporary values when shifting.
    Reg#(FP32Sign) resultSignReg <- mkRegU();
    Reg#(FP32Exponent) resultExponentReg <- mkRegU();
    Reg#(FP32MantissaAdded) resultMantissaAddedReg <- mkRegU();


    /*** Rules ***/
    rule doCompute if (!isShifting);
        // Fetch operands from the fifos, and decode them.
        //   - (1) Exponent != 0  ->  Mantissa = 01.xxx (Normal Value)
        //   - (2) Exponent == 0  ->  Mantissa = 00.xxx (Denormal Value)
        //       => In demornal case, exponent should be set to 1.
        let a = argA.first();
        argA.deq();

        let b = argB.first();
        argB.deq();

        FP32Sign aSign = a[31];
        FP32Sign bSign = b[31];

        FP32Exponent aExponent = a[30:23];
        FP32Exponent bExponent = b[30:23];

        FP32MantissaAdded aMantissa = ?;
        FP32MantissaAdded bMantissa = ?;

        if (aExponent != 0) begin
            aMantissa = {2'b01, a[22:0]};
        end else begin
            aMantissa = {2'b00, a[22:0]};
            aExponent = 1;
        end

        if (bExponent != 0) begin
            bMantissa = {2'b01, b[22:0]};
        end else begin
            bMantissa = {2'b00, b[22:0]};
            bExponent = 1;
        end

        
        /*** TODO: Implement inf/NaN arithmetic here ***/


        // Now compute these values.
        FP32Sign resultSign = ?;
        FP32Exponent resultExponent = ?;
        FP32MantissaAdded resultMantissaAdded = ?;


        // 1. resultExponent: Set to larger exponent.
        //   - Operand with smaller exponent should be manipulated to match the exponent:
        //       As exponent is incremented by 1, should shift the mantissa to the right by 1.
        //
        // 2. resultSign: Follow the sign of the larger absolute value.
        //   - If the absolute values are equal, compare operand signs:
        //       - If signs are equal, follow that sign
        //       - If signs are different, set resultSign = 0.
        // Comparing absolute value:
        //   - At this point two exponents are equal, just comparing mantissas is enough.
        //
        // 3. mantissaAdded: Add the two mantissas.
        //   - If signs are same, add two mantissas.
        //   - If signs are different, subtract from the larger operand.
        if (aExponent >= bExponent) begin
            resultExponent = aExponent;
            bMantissa = bMantissa >> (aExponent - bExponent);
        end else begin
            resultExponent = bExponent;
            aMantissa = aMantissa >> (bExponent - aExponent);
        end

        if (aMantissa > bMantissa) begin
            resultSign = aSign;
            resultMantissaAdded = (aSign == bSign) ? aMantissa + bMantissa : aMantissa - bMantissa;
        end else if (aMantissa < bMantissa) begin
            resultSign = bSign;
            resultMantissaAdded = (aSign == bSign) ? bMantissa + aMantissa : bMantissa - aMantissa;
        end else begin
            if (aSign == bSign) begin
                resultSign = aSign;
                resultMantissaAdded = aMantissa + bMantissa;
            end else begin
                resultSign = 1'b0;
                resultMantissaAdded = 0;  // Subtracting same values yields 0.
            end
            
        end


        // Decode the result: Computing resultMantissa from resultMantissaAdded is required.
        FP32Mantissa resultMantissa = ?;

        // At this point, resultMantissaAdded would be one of the following 4 cases:
        //   (1) 1x.yyy => resultExponent should be incremented by 1, resultMantissa is xyy
        //   (2) 01.xxx => resultExponent stays the same, resultMantissa is xxx
        //   (3) 00.000 => Result is 0. Both resultExponent and resultMantissa are 0
        //   (4) 00.xxx => This case requires shifting.
        //          Shift the value to the left until it becomes 01.xxx form.
        //          Then the resultMantissa could be set to xxx.
        //          One left shifting requires exponent decrement by 1.
        if (resultMantissaAdded[24] == 1'b1) begin
            resultExponent = resultExponent + 1;
            resultMantissa = resultMantissaAdded[23:1];

            result.enq({resultSign, resultExponent, resultMantissa});
        end else if (resultMantissaAdded[23] == 1'b1) begin
            resultMantissa = resultMantissaAdded[22:0];

            result.enq({resultSign, resultExponent, resultMantissa});
        end else if (resultMantissaAdded == 0) begin
            resultExponent = 0;
            resultMantissa = 0;

            result.enq({resultSign, resultExponent, resultMantissa});
        end else begin
            resultSignReg <= resultSign;
            resultExponentReg <= resultExponent;
            resultMantissaAddedReg <= resultMantissaAdded;

            isShifting <= True;
        end
    endrule


    rule shiftMantissa if (isShifting);
        // Shift resultMantissaAddedReg to the left until it reaches 01.xxx form.
        // Shifting left by 1 requires resultExponentReg decremented by 1.
        //   => Terminate shifting when form 01.xxx reached.
        if (resultMantissaAddedReg[23] == 1'b1) begin
            FP32Mantissa resultMantissa = resultMantissaAddedReg[22:0];
            result.enq({resultSignReg, resultExponentReg, resultMantissa});

            isShifting <= False;
        end else begin
            resultMantissaAddedReg <= resultMantissaAddedReg << 1;
            resultExponentReg <= resultExponentReg - 1;
        end
    endrule


    /*** Interfaces ***/
    method Action putArgA(FP32 argA_);
        argA.enq(argA_);
    endmethod

    method Action putArgB(FP32 argB_);
        argB.enq(argB_);
    endmethod

    method ActionValue#(FP32) getResult();
        result.deq();
        return result.first();
    endmethod
endmodule
