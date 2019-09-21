import FixedPoint::*;
import CReg::*;
import Fifo::*;
import DataType::*;


interface FixedPointExamples;
    method Action putA(FixedPointData a);
    method Action putB(FixedPointData b);
    method ActionValue#(FixedPointData) getSum();
    method ActionValue#(FixedPointData) getSubtraction();
    method ActionValue#(FixedPointData) getMultiplication();
endinterface


(* synthesize *)
module mkFixedPointExamples(FixedPointExamples);
    Fifo#(1, FixedPointData) aFifo <- mkPipelineFifo();
    Fifo#(1, FixedPointData) bFifo <- mkPipelineFifo();
    Fifo#(1, FixedPointData) sumFifo <- mkPipelineFifo();
    Fifo#(1, FixedPointData) subtractionFifo <- mkPipelineFifo();
    Fifo#(1, FixedPointData) multiplicationFifo <- mkPipelineFifo();

    rule compute;
        let a = aFifo.first();
        aFifo.deq();

        let b = bFifo.first();
        bFifo.deq();

        let sum = a + b;
        sumFifo.enq(sum);

        let subtraction = a - b;
        subtractionFifo.enq(subtraction);

        let multiplication = a * b;
        multiplicationFifo.enq(multiplication);
    endrule

    method Action putA(FixedPointData a);
        aFifo.enq(a);
    endmethod

    method Action putB(FixedPointData b);
        bFifo.enq(b);
    endmethod

    method ActionValue#(FixedPointData) getSum();
        let result = sumFifo.first();
        sumFifo.deq();
        return result;
    endmethod

    method ActionValue#(FixedPointData) getSubtraction();
        let result = subtractionFifo.first();
        subtractionFifo.deq();
        return result;
    endmethod

    method ActionValue#(FixedPointData) getMultiplication();
        let result = multiplicationFifo.first();
        multiplicationFifo.deq();
        return result;
    endmethod

endmodule
