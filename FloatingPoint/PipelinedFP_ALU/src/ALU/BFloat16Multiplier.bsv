import Fifo::*;

import BFloat16::*;

interface BFloat16Multiplier;
    method Action putArgA(BFloat16 newArgA);
    method Action putArgB(BFloat16 newArgB);
    method ActionValue#(BFloat16) getResult();
endinterface


(* synthesize *)
module mkBFloat16Multiplier(BFloat16Multiplier);
    /*** Input and Output Fifos ***/
    Fifo#(1, BFloat16) argA <- mkBypassFifo();
    Fifo#(1, BFloat16) argB <- mkBypassFifo();

    Fifo#(1, BFloat16) result <- mkPipelineFifo();


    /*** Pipelining Fifos ***/
    Fifo#(1, BFloat16MultiplierOperands) decoded <- mkPipelineFifo();
    Fifo#(1, BFloat16MultiplierOperand) multiplied <- mkPipelineFifo();
    Fifo#(1, BFloat16MultiplierOperand) shiftedBy8 <- mkPipelineFifo();
    Fifo#(1, BFloat16MultiplierOperand) shiftedBy4 <- mkPipelineFifo();
    Fifo#(1, BFloat16MultiplierOperand) shiftedBy2 <- mkPipelineFifo();
    Fifo#(1, BFloat16MultiplierOperand) shiftedBy1 <- mkPipelineFifo();


    /*** Rules ***/
    rule decode;
        // fetch
        let a = argA.first();
        let b = argB.first();

        argA.deq();
        argB.deq();

        // decode
        BFloat16MultiplierOperands operands = ?;

        operands.a.sign = a[15];
        operands.b.sign = b[15];

        if (a[14:7] == 0) begin
            // Denormal value
            //   - Regard this value as Normal value, by setting mantissa to 0.xxx form (rather than 1.xxx) and exponent to 1.
            operands.a.state = Normal;
            operands.a.exponent = 1;
            operands.a.mantissa = zeroExtend({1'b0, a[6:0]});
        end else if (a[14:7] == '1) begin
            if (a[6:0] == 0) begin
                operands.a.state = Inf;
                operands.a.mantissa = 1;  // Later we should the case (Inf * 0), so we set Inf's mantissa to 1 to differentiate 0 and Inf by mantissa.
            end else begin
                operands.a.state = NaN;
            end
        end else begin
            // Normal Value
            operands.a.state = Normal;
            operands.a.exponent = zeroExtend(a[14:7]);
            operands.a.mantissa = zeroExtend({1'b1, a[6:0]});
        end

        if (b[14:7] == 0) begin
            operands.b.state = Normal;
            operands.b.exponent = 1;
            operands.b.mantissa = zeroExtend({1'b0, b[6:0]});
        end else if (b[14:7] == '1) begin
            if (b[6:0] == 0) begin
                operands.b.state = Inf;
                operands.b.mantissa = 1;
            end else begin
                operands.b.state = NaN;
            end
        end else begin
            operands.b.state = Normal;
            operands.b.exponent = zeroExtend(b[14:7]);
            operands.b.mantissa = zeroExtend({1'b1, b[6:0]});
        end

        decoded.enq(operands);
    endrule

    rule multiplication;
        let operands = decoded.first();
        decoded.deq();

        BFloat16MultiplierOperand nextResult = ?;

        // Compute
        if (operands.a.sign == operands.b.sign) begin
            nextResult.sign = 1'b0;
        end else begin
            nextResult.sign = 1'b1;
        end

        if (operands.a.state == Normal && operands.b.state == Normal) begin
            // Normal case

            // let mathematical exponents be aExponent, bExponent, and consider bias
            //    aExponent = a.exponent - bias
            //    bExponent = b.exponent - bias
            //    resultExponent = aExponent + bExponent
            //                   = a.exponent + b.exponent - 2bias
            //    result.exponent = resultExponent - bias
            //                    = a.exponent + b.exponent - bias
            Bit#(9) bias = (1 << 7) - 1;
            nextResult.exponent = operands.a.exponent + operands.b.exponent;
            if (nextResult.exponent <= bias) begin
                // result is too small: result is 0
                nextResult.state = Denormal;
                nextResult.mantissa = 0;
            end else begin
                nextResult.state = Normal;
                nextResult.exponent = nextResult.exponent - bias;
                nextResult.mantissa = operands.a.mantissa * operands.b.mantissa;
            end
        end else begin
            // Special Cases
            if (operands.a.state == NaN || operands.b.state == NaN) begin
                nextResult.state = NaN;
            end else if (operands.a.state == Inf || operands.b.state == Inf) begin
                if (operands.a.mantissa == 0 || operands.b.mantissa == 0) begin
                    nextResult.state = NaN;
                end else begin
                    nextResult.state = Inf;
                end
            end
        end

        multiplied.enq(nextResult);
    endrule

    rule shiftBy8;
        let operand = multiplied.first();
        multiplied.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[15:7] == 0) begin
                if (operand.exponent <= 8) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 8;
                    operand.exponent = operand.exponent - 8;
                end
            end
        end

        shiftedBy8.enq(operand);
    endrule

    rule shiftBy4;
        let operand = shiftedBy8.first();
        shiftedBy8.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[15:11] == 0) begin
                if (operand.exponent <= 4) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 4;
                    operand.exponent = operand.exponent - 4;
                end
            end
        end

        shiftedBy4.enq(operand);
    endrule

    rule shiftBy2;
        let operand = shiftedBy4.first();
        shiftedBy4.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[15:13] == 0) begin
                if (operand.exponent <= 2) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 2;
                    operand.exponent = operand.exponent - 2;
                end
            end
        end

        shiftedBy2.enq(operand);
    endrule

    rule shiftBy1;
        let operand = shiftedBy2.first();
        shiftedBy2.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[15:14] == 0) begin
                if (operand.exponent <= 1) begin
                    // operand.exponent is <= 1 already: shifting mantissa is not required.
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 1;
                    operand.exponent = operand.exponent - 1;
                end
            end
        end

        shiftedBy1.enq(operand);
    endrule

    rule putResult;
        let operand = shiftedBy1.first();
        shiftedBy1.deq();

        if (operand.state == Normal) begin
            // 1 is in [15:14]
            if (operand.mantissa[15] == 1'b1) begin
                operand.exponent = operand.exponent + 1;

                // Result could be Inf
                if (operand.exponent >= (1 << 8)) begin
                    operand.exponent = '1;
                    operand.mantissa = 0;
                    result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[6:0]});        
                end else begin
                    // Resut is not Inf
                    result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[14:8]});
                end
            end else begin
                result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[13:7]});
            end
        end else if (operand.state == Denormal) begin
            operand.exponent = 0;
            result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[13:7]});
        end else if (operand.state == Inf) begin
            operand.exponent = '1;
            operand.mantissa = 0;
            result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[6:0]});
        end else begin
            // NaN
            operand.sign = 1'b0;
            operand.exponent = '1;
            operand.mantissa = 1;
            result.enq({operand.sign, operand.exponent[7:0], operand.mantissa[6:0]});
        end
    endrule


    /*** Interfaces ***/
    method Action putArgA(BFloat16 newArgA);
        argA.enq(newArgA);
    endmethod

    method Action putArgB(BFloat16 newArgB);
        argB.enq(newArgB);
    endmethod

    method ActionValue#(BFloat16) getResult();
        result.deq();
        return result.first();
    endmethod
endmodule
