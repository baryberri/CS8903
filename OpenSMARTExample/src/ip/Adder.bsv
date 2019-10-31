import Types::*;
import Fifo::*;


interface Adder;
    method Action putA(Data data);
    method Action putB(Data data);
    method ActionValue#(Data) get();
endinterface


(* synthesize *)
module mkAdder(Adder);
    /// Input and output Fifos
    Fifo#(1, Data) aFifo <- mkBypassFifo();
    Fifo#(1, Data) bFifo <- mkBypassFifo();
    Fifo#(1, Data) resultFifo <- mkPipelineFifo();

    /// Rules
    rule doAddition;
        let a = aFifo.first();
        aFifo.deq();

        let b = bFifo.first();
        bFifo.deq();

        let result = a + b;
        resultFifo.enq(result);
    endrule

    /// Interface Implementation
    method Action putA(Data data);
        aFifo.enq(data);
    endmethod

    method Action putB(Data data);
        bFifo.enq(data);
    endmethod

    method ActionValue#(Data) get();
        let result = resultFifo.first();
        resultFifo.deq();

        return result;
    endmethod
endmodule