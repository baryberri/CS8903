import Fifo::*;

import FPSmall::*;

(* synthesize *)
module mkLI_FPSmallAdder(LI_FPSmallAdder);
    /* Latency Insensitive Implementation */


    /* Fifos */
    Fifo#(1, FPSmall) argA <- mkBypassFifo();
    Fifo#(1, FPSmall) argB <- mkBypassFifo();
    Fifo#(1, FPSmall) result <- mkBypassFifo();


    /* Internal States */
    // Some inputs require multiple cycles to compute result
    // This register marks if the computation requires additional cycles
    Reg#(Bool) doShifting <- mkReg(False);

    // These registers are used for those input values
    Reg#(FPSmallSign) resultSign <- mkRegU();
    Reg#(FPSmallExponent) resultExponent <- mkRegU();
    Reg#(FPSmallMantissaAdded) resultMantissaAdded <- mkRegU();
    
    // After computation, mantissaAdded's form is 01.xxx
    // Thus, resultMantissa is trailing bits (truncate mantissaAdded)
    FPSmallMantissa resultMantissa = truncate(resultMantissaAdded);
    

    /* Rules */
    rule decodeInputs if (!doShifting);
        // Fetch input and decode.
        //   - If exponent != 0, Mantissa should be 01.xxx
        //   - If exponent == 0, Mantissa should be 00.xxx (Denormal Number)
        //       - In this case, exponent should be 1.
        let a = argA.first();
        argA.deq();
        FPSmallSign aSign = a[6];
        FPSmallExponent aExponent = a[5:3];
        FPSmallMantissaAdded aMantissa = ?;
        if (aExponent != 0) begin
            aMantissa = {2'b01, a[2:0]};
        end else begin
            aMantissa = {2'b00, a[2:0]};
            aExponent = 1;
        end

        let b = argB.first();
        argB.deq();
        FPSmallSign bSign = b[6];
        FPSmallExponent bExponent = b[5:3];
        FPSmallMantissaAdded bMantissa = ?;
        if (bExponent != 0) begin
            bMantissa = {2'b01, b[2:0]};
        end else begin
            bMantissa = {2'b00, b[2:0]};
            bExponent = 1;
        end


        // Should compute and fill up these values
        FPSmallSign resultSign_ = ?;
        FPSmallExponent resultExponent_ = ?;
        FPSmallMantissaAdded resultMantissaAdded_ = ?;
        FPSmallMantissa resultMantissa_ = ?;


        // 1. Exponent: Set to the larger exponent
        //   - Incrementing exponent requires shifting mantissa right by 1.
        //
        // 2. Sign: Check if a and b's sign matches.
        //   - If sign is the same, resultSign_ is also the same.
        //   - If sign is different, resultSign_ follows the larger absolute value's sign.
        //
        // 3. MantissaAdded: add two mantissas
        //   - If sign is the same, just add two mantissas
        //   - If sign is different, subtract from larger absolute value's mantissa.
        if (aExponent >= bExponent) begin
            resultExponent_ = aExponent;

            let shiftingAmmount = aExponent - bExponent;
            bMantissa = bMantissa >> shiftingAmmount;
        end else begin
            resultExponent_ = bExponent;

            let shiftingAmmount = bExponent - aExponent;
            aMantissa = aMantissa >> shiftingAmmount;
        end

        if (aSign == bSign) begin
            resultSign_ = aSign;
            resultMantissaAdded_ = aMantissa + bMantissa;
        end else begin
            if (aMantissa >= bMantissa) begin
                resultSign_ = aSign;
                resultMantissaAdded_ = aMantissa - bMantissa;
            end else begin
                resultSign_ = bSign;
                resultMantissaAdded_ = bMantissa - aMantissa;
            end
        end


        // Decode the result.
        // At this point, resultMantissaAdded_ would be one of the four cases:
        //   (1) 1y.xxx -> resultExponent_ should be incremented by 1, resultMantissa_ becomes y.xx
        //   (2) 01.xxx -> resultExponent_ stays the same, resultMantissa_ becomes xxx
        //   (3) 00.000 -> Cannot make 01.xxx form by shifting left. The result is 0.
        //      - if aSign == bSign, follows the sign.
        //      - Otherwise, +0.
        //   (4) 00.xxx -> Shift the mantissa to the left until this becomes 01.xxx form. Then it's same as case (2).
        //
        // Among these cases, (1), (2), and (3) can yield result immediately.
        // Case (4) needs shifting.
        if (resultMantissaAdded_[4] == 1'b1) begin
            resultExponent_ = resultExponent_ + 1;
            resultMantissa_ = resultMantissaAdded_[3:1];
            result.enq({resultSign_, resultExponent_, resultMantissa_});
        end else if (resultMantissaAdded_[3] == 1'b1) begin
            resultMantissa_ = resultMantissaAdded_[2:0];
            result.enq({resultSign_, resultExponent_, resultMantissa_});
        end else if (resultMantissaAdded_ == 0) begin
            resultSign_ = (aSign == bSign) ? aSign : 1'b0;
            resultExponent_ = 0;
            resultMantissa_ = 0;
            result.enq({resultSign_, resultExponent_, resultMantissa_});
        end else begin
            resultSign <= resultSign_;
            resultExponent <= resultExponent_;
            resultMantissaAdded <= resultMantissaAdded_;
            doShifting <= True;
        end
    endrule


    rule shiftMantissa if (doShifting);
        // Shift resultMantissaAdded until it becomes 01.xxx form.
        // If it reaches 01.xxx form, put the result.
        if (resultMantissaAdded[3] == 1'b1) begin
            doShifting <= False;

            result.enq({resultSign, resultExponent, resultMantissa});
        end else begin
            resultExponent <= resultExponent - 1;
            resultMantissaAdded <= (resultMantissaAdded << 1);
        end
    endrule


    /* Interfaces */
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
