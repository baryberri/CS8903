import Fifo::*;

import BFloat16::*;


interface BFloat16Adder;
    method Action putArgA(BFloat16 newArgA);
    method Action putArgB(BFloat16 newArgB);
    method ActionValue#(BFloat16) getResult();
endinterface

(* synthesize *)
module mkBFloat16Adder(BFloat16Adder);
    /*** Input and Output Fifos ***/
    Fifo#(1, BFloat16) argA <- mkBypassFifo();
    Fifo#(1, BFloat16) argB <- mkBypassFifo();
    Fifo#(1, BFloat16) result <- mkPipelineFifo();

    
    /*** Pipelining Fifos ***/
    Fifo#(1, BFloat16AdderOperands) decoded <- mkPipelineFifo();
    Fifo#(1, BFloat16AdderOperand) added <- mkPipelineFifo();
    Fifo#(1, BFloat16AdderOperand) shiftedBy4 <- mkPipelineFifo();
    Fifo#(1, BFloat16AdderOperand) shiftedBy2 <- mkPipelineFifo();
    Fifo#(1, BFloat16AdderOperand) shiftedBy1 <- mkPipelineFifo();


    /*** Rules ***/
    rule decode;
        // fetch
        let a = argA.first();
        let b = argB.first();

        argA.deq();
        argB.deq();

        // decode
        BFloat16AdderOperands operands = ?;

        operands.a.sign = a[15];
        operands.b.sign = b[15];

        operands.a.exponent = a[14:7];
        operands.b.exponent = b[14:7];

        if (operands.a.exponent == 0) begin
            // Denormal value
            //   - Regard this value as Normal value, by setting mantissa to 0.xxx form (rather than 1.xxx) and exponent to 1.
            operands.a.state = Normal;
            operands.a.exponent = 1;
            operands.a.mantissa = {2'b00, a[6:0]};
        end else if (operands.a.exponent == '1) begin
            if (a[6:0] == 0) begin
                operands.a.state = Inf;
            end else begin
                operands.a.state = NaN;
            end
        end else begin
            // Normal value
            operands.a.state = Normal;
            operands.a.mantissa = {2'b01, a[6:0]};
        end

        if (operands.b.exponent == 0) begin
            operands.b.state = Normal;
            operands.b.exponent = 1;
            operands.b.mantissa = {2'b00, b[6:0]};
        end else if (operands.b.exponent == '1) begin
            if (b[6:0] == 0) begin
                operands.b.state = Inf;
            end else begin
                operands.b.state = NaN;
            end
        end else begin
            operands.b.state = Normal;
            operands.b.mantissa = {2'b01, b[6:0]};
        end

        // Match exponent: shift smaller exponent value's mantissa
        if (operands.a.state == Normal && operands.b.state == Normal) begin
            if (operands.a.exponent >= operands.b.exponent) begin
                operands.b.mantissa = operands.b.mantissa >> (operands.a.exponent - operands.b.exponent);
                operands.b.exponent = operands.a.exponent;
            end else begin
                operands.a.mantissa = operands.a.mantissa >> (operands.b.exponent - operands.a.exponent);
                operands.a.exponent = operands.b.exponent;
            end
        end

        decoded.enq(operands);
    endrule

    rule addition;
        let operands = decoded.first();
        decoded.deq();
        
        BFloat16AdderOperand nextResult = ?;

        // Compute
        if (operands.a.state == Normal && operands.b.state == Normal) begin
            // Normal case
            nextResult.state = Normal;

            nextResult.exponent = operands.a.exponent;

            if (operands.a.sign == operands.b.sign) begin
                // addition
                nextResult.sign = operands.a.sign;
                nextResult.mantissa = operands.a.mantissa + operands.b.mantissa;
            end else begin
                // subtraction
                if (operands.a.mantissa > operands.b.mantissa) begin
                    nextResult.sign = operands.a.sign;
                    nextResult.mantissa = operands.a.mantissa - operands.b.mantissa;
                end else if (operands.a.mantissa < operands.b.mantissa) begin
                    nextResult.sign = operands.b.sign;
                    nextResult.mantissa = operands.b.mantissa - operands.a.mantissa;
                end else begin
                    // subtracting same absolute value: result is 0
                    nextResult.sign = 1'b0;
                    nextResult.mantissa = 0;
                end
            end
        end else begin
            // Special cases
            if (operands.a.state == NaN || operands.b.state == NaN) begin
                nextResult.state = NaN;
            end else if (operands.a.state == Inf && operands.b.state == Inf) begin
                if (operands.a.sign == operands.b.sign) begin
                    nextResult.sign = operands.a.sign;
                    nextResult.state = Inf;
                end else begin
                    nextResult.state = NaN;
                end
            end else if (operands.a.state == Inf) begin
                nextResult.sign = operands.a.sign;
                nextResult.state = Inf; 
            end else begin
                nextResult.sign = operands.b.sign;
                nextResult.state = Inf;
            end
        end

        added.enq(nextResult);
    endrule

    rule shiftBy4;
        let operand = added.first();
        added.deq();

        if (operand.state == Normal) begin
            if (operand.mantissa[8:4] == 0) begin
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
            if (operand.mantissa[8:6] == 0) begin
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
            if (operand.mantissa[8:7] == 0) begin
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
            // 1 is in [8:7]
            if (operand.mantissa[8] == 1'b1) begin
                operand.exponent = operand.exponent + 1;

                // Result could be Inf
                if (operand.exponent >= '1) begin
                    operand.mantissa = 0;
                    result.enq({operand.sign, operand.exponent, operand.mantissa[6:0]});
                end else begin
                    // Resut is not Inf
                    result.enq({operand.sign, operand.exponent, operand.mantissa[7:1]});
                end
            end else begin
                result.enq({operand.sign, operand.exponent, operand.mantissa[6:0]});
            end
        end else if (operand.state == Denormal) begin
            operand.exponent = 0;
            result.enq({operand.sign, operand.exponent, operand.mantissa[6:0]});
        end else if (operand.state == Inf) begin
            operand.exponent = '1;
            operand.mantissa = 0;
            result.enq({operand.sign, operand.exponent, operand.mantissa[6:0]});
        end else begin
            // NaN
            operand.sign = 1'b0;
            operand.exponent = '1;
            operand.mantissa = 1;
            result.enq({operand.sign, operand.exponent, operand.mantissa[6:0]});
        end
    endrule


    /*** interfaces ***/
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
