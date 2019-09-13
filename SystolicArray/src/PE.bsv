import Fifo::*;
import DataType::*;

interface PE_Control;
    method Action setTo(PE_State newState);
endinterface

interface PE_Data;
    method ActionValue#(Data) bottomFifoValue();
    method ActionValue#(Data) rightFifoValue();
    method Action putIntoTopFifo(Data data);
    method Action putIntoLeftFifo(Data data);
endinterface

interface PE;
    interface PE_Control control;
    interface PE_Data data;
endinterface


(* synthesize *)
module mkPE(PE);
    // Weight Storage
    Reg#(Maybe#(Data)) weight <- mkReg(tagged Invalid);

    // Input and Output Fifos
    Fifo#(1, Data) topFifo <- mkPipelineFifo;
    Fifo#(1, Data) bottomFifo <- mkPipelineFifo;
    Fifo#(1, Data) leftFifo <- mkPipelineFifo;
    Fifo#(1, Data) rightFifo <- mkPipelineFifo;

    // State
    Reg#(PE_State) state <- mkReg(Idle);

    // Rules
    rule doClear if (state == Clear);
        // Reset the weight for future computation
        weight <= tagged Invalid;
    endrule

    rule doLoadWeight if (state == LoadWeight);
        // Weight flows from top to bottom.
        // - If this PE doesn't contain any weight, then save the input
        // - If this PE already has weight, then flow it to the bototm

        let weightValue = topFifo.first();
        topFifo.deq();

        if (isValid(weight)) begin
            bottomFifo.enq(weightValue);    
        end else begin
            weight <= tagged Valid weightValue;
        end
    endrule

    rule doCompute if (state == Compute);
        //
        //                     psum (if empty, then 0)
        //                      |
        //                      v
        //    activation  --->  PE  ->  (activation pass through)
        //                      |
        //                      v
        //                  (next psum)
        //

        // Get the values
        Data psum = 0;
        if (topFifo.notEmpty()) begin
            psum = topFifo.first();
            topFifo.deq();
        end
        
        let activation = leftFifo.first();
        leftFifo.deq();

        // Compute next psum
        let nextPsum = (fromMaybe(0, weight) * activation) + psum;
        
        // Send the result
        bottomFifo.enq(nextPsum);
        rightFifo.enq(activation);
    endrule

    // Interfaces
    interface control = interface PE_Control
        method Action setTo(PE_State newState);
            state <= newState;
        endmethod
    endinterface;

    interface data = interface PE_Data
        method ActionValue#(Data) bottomFifoValue();
            let value = bottomFifo.first();
            bottomFifo.deq();

            return value;
        endmethod

        method ActionValue#(Data) rightFifoValue();
            let value = rightFifo.first();
            rightFifo.deq();

            return value;
        endmethod

        method Action putIntoTopFifo(Data data);
            topFifo.enq(data);
        endmethod

        method Action putIntoLeftFifo(Data data);
            leftFifo.enq(data);
        endmethod
    endinterface;
endmodule