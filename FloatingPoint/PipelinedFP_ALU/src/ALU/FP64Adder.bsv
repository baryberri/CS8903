import Fifo::*;

import FP64::*;


interface FP64Adder;
    method Action putArgA(FP64 newArgA);
    method Action putArgB(FP64 newArgB);
    method ActionValue#(FP64) getResult();
endinterface

(* synthesize *)
module mkFP64Adder(FP64Adder);
    /*** Input and Output Fifos ***/
    Fifo#(1, FP64) argA <- mkBypassFifo();
    Fifo#(1, FP64) argB <- mkBypassFifo();
    Fifo#(1, FP64) result <- mkPipelineFifo();

    
    /*** Pipelining Fifos ***/
    Fifo#(1, FP64AdderOperands) decoded <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) added <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy32 <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy16 <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy8 <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy4 <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy2 <- mkPipelineFifo();
    Fifo#(1, FP64AdderOperand) shiftedBy1 <- mkPipelineFifo();


    /*** Rules ***/
    rule decode;
        // fetch
        let a = argA.first();
        let b = argB.first();

        argA.deq();
        argB.deq();

        // decode
        FP64AdderOperands operands = ?;

        operands.a.sign = a[63];
        operands.b.sign = b[63];

        operands.a.exponent = a[62:52];
        operands.b.exponent = b[62:52];

        if (operands.a.exponent == 0) begin
            // Denormal value
            //   - Regard this value as Normal value, by setting mantissa to 0.xxx form (rather than 1.xxx) and exponent to 1.
            operands.a.state = Normal;
            operands.a.exponent = 1;
            operands.a.mantissa = {2'b00, a[51:0]};
        end else if (operands.a.exponent == '1) begin
            if (a[2:0] == 0) begin
                operands.a.state = Inf;
            end else begin
                operands.a.state = NaN;
            end
        end else begin
            // Normal value
            operands.a.state = Normal;
            operands.a.mantissa = {2'b01, a[51:0]};
        end

        if (operands.b.exponent == 0) begin
            operands.b.state = Normal;
            operands.b.exponent = 1;
            operands.b.mantissa = {2'b00, b[51:0]};
        end else if (operands.b.exponent == '1) begin
            if (b[2:0] == 0) begin
                operands.b.state = Inf;
            end else begin
                operands.b.state = NaN;
            end
        end else begin
            operands.b.state = Normal;
            operands.b.mantissa = {2'b01, b[51:0]};
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
        
        FP64AdderOperand nextResult = ?;

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

    rule shiftBy32;
        let operand = added.first();
        added.deq();

        if (operand.state == Normal) begin
            // Shift mantissa by 32 if possible
            if (operand.mantissa[53:21] == 0) begin
                if (operand.exponent <= 32) begin
                    // Denormal Value
                    operand.mantissa = operand.mantissa << (operand.exponent - 1);
                    operand.state = Denormal; 
                end else begin
                    // Normal Value
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
            if (operand.mantissa[53:37] == 0) begin
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
            if (operand.mantissa[53:45] == 0) begin
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
            if (operand.mantissa[53:49] == 0) begin
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
            if (operand.mantissa[53:51] == 0) begin
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
            if (operand.mantissa[53:52] == 0) begin
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
            // 1 is in [53:52]
            if (operand.mantissa[53] == 1'b1) begin
                operand.exponent = operand.exponent + 1;

                // Result could be Inf
                if (operand.exponent >= '1) begin
                    operand.mantissa = 0;
                    result.enq({operand.sign, operand.exponent, operand.mantissa[51:0]});        
                end else begin
                    // Resut is not Inf
                    result.enq({operand.sign, operand.exponent, operand.mantissa[52:1]});
                end
            end else begin
                result.enq({operand.sign, operand.exponent, operand.mantissa[51:0]});
            end
        end else if (operand.state == Denormal) begin
            operand.exponent = 0;
            result.enq({operand.sign, operand.exponent, operand.mantissa[51:0]});
        end else if (operand.state == Inf) begin
            operand.exponent = '1;
            operand.mantissa = 0;
            result.enq({operand.sign, operand.exponent, operand.mantissa[51:0]});
        end else begin
            // NaN
            operand.sign = 1'b0;
            operand.exponent = '1;
            operand.mantissa = 1;
            result.enq({operand.sign, operand.exponent, operand.mantissa[51:0]});
        end
    endrule


    /*** interfaces ***/
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
