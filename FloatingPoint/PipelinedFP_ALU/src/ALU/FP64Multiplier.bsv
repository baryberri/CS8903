import Fifo::*;

import FP64::*;

interface FP64Multiplier;
    method Action putArgA(FP64 newArgA);
    method Action putArgB(FP64 newArgB);
    method ActionValue#(FP64) getResult();
endinterface


(* synthesize *)
module mkFP64Multiplier(FP64Multiplier);
    /*** Input and Output Fifos ***/
    Fifo#(1, FP64) argA <- mkBypassFifo();
    Fifo#(1, FP64) argB <- mkBypassFifo();

    Fifo#(1, FP64) result <- mkPipelineFifo();


    /*** Pipelining Fifos ***/
    Fifo#(1, FP64MultiplierOperands) decoded <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) multiplied <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy64 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy32 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy16 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy8 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy4 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy2 <- mkPipelineFifo();
    Fifo#(1, FP64MultiplierOperand) shiftedBy1 <- mkPipelineFifo();


    /*** Rules ***/
    rule decode;
        // fetch
        let a = argA.first();
        let b = argB.first();

        argA.deq();
        argB.deq();

        // decode
        FP64MultiplierOperands operands = ?;

        operands.a.sign = a[63];
        operands.b.sign = b[63];

        if (a[62:52] == 0) begin
            // Denormal value
            //   - Regard this value as Normal value, by setting mantissa to 0.xxx form (rather than 1.xxx) and exponent to 1.
            operands.a.state = Normal;
            operands.a.exponent = 1;
            operands.a.mantissa = zeroExtend({1'b0, a[51:0]});
        end else if (a[62:52] == '1) begin
            if (a[51:0] == 0) begin
                operands.a.state = Inf;
                operands.a.mantissa = 1;  // Later we should the case (Inf * 0), so we set Inf's mantissa to 1 to differentiate 0 and Inf by mantissa.
            end else begin
                operands.a.state = NaN;
            end
        end else begin
            // Normal Value
            operands.a.state = Normal;
            operands.a.exponent = zeroExtend(a[62:52]);
            operands.a.mantissa = zeroExtend({1'b1, a[51:0]});
        end

        if (b[62:52] == 0) begin
            operands.b.state = Normal;
            operands.b.exponent = 1;
            operands.b.mantissa = zeroExtend({1'b0, b[51:0]});
        end else if (b[62:52] == '1) begin
            if (b[51:0] == 0) begin
                operands.b.state = Inf;
                operands.b.mantissa = 1;
            end else begin
                operands.b.state = NaN;
            end
        end else begin
            operands.b.state = Normal;
            operands.b.exponent = zeroExtend(b[62:52]);
            operands.b.mantissa = zeroExtend({1'b1, b[51:0]});
        end

        decoded.enq(operands);
    endrule

    rule multiplication;
        let operands = decoded.first();
        decoded.deq();

        FP64MultiplierOperand nextResult = ?;

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
            Bit#(12) bias = (1 << 10) - 1;
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

    rule shiftBy64;
        let operand = multiplied.first();
        multiplied.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[105:41] == 0) begin
                if (operand.exponent <= 64) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 64;
                    operand.exponent = operand.exponent - 64;
                end
            end
        end

        shiftedBy64.enq(operand);
    endrule

    rule shiftBy32;
        let operand = shiftedBy64.first();
        shiftedBy64.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[105:73] == 0) begin
                if (operand.exponent <= 32) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 32;
                    operand.exponent = operand.exponent - 32;
                end
            end
        end

        shiftedBy32.enq(operand);
    endrule

    rule shiftBy16;
        let operand = shiftedBy32.first();
        shiftedBy32.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[105:89] == 0) begin
                if (operand.exponent <= 16) begin
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal;
                end else begin
                    operand.mantissa = operand.mantissa << 16;
                    operand.exponent = operand.exponent - 16;
                end
            end
        end

        shiftedBy16.enq(operand);
    endrule

    rule shiftBy8;
        let operand = shiftedBy16.first();
        shiftedBy16.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[105:97] == 0) begin
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
            if (operand.mantissa[105:101] == 0) begin
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
            if (operand.mantissa[105:103] == 0) begin
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
            if (operand.mantissa[105:104] == 0) begin
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
            // 1 is in [105:104]
            if (operand.mantissa[105] == 1'b1) begin
                operand.exponent = operand.exponent + 1;

                // Result could be Inf
                if (operand.exponent >= (1 << 11)) begin
                    operand.exponent = '1;
                    operand.mantissa = 0;
                    result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[51:0]});        
                end else begin
                    // Resut is not Inf
                    result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[104:53]});
                end
            end else begin
                result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[103:52]});
            end
        end else if (operand.state == Denormal) begin
            operand.exponent = 0;
            result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[103:52]});
        end else if (operand.state == Inf) begin
            operand.exponent = '1;
            operand.mantissa = 0;
            result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[51:0]});
        end else begin
            // NaN
            operand.sign = 1'b0;
            operand.exponent = '1;
            operand.mantissa = 1;
            result.enq({operand.sign, operand.exponent[10:0], operand.mantissa[51:0]});
        end
    endrule


    /*** Interfaces ***/
    method Action putArgA(FP64 newArgA);
        argA.enq(newArgA);
    endmethod

    method Action putArgB(FP64 newArgB);
        argB.enq(newArgB);
    endmethod

    method ActionValue#(FP64) getResult();
        result.deq();
        return result.first();
    endmethod
endmodule
