import Fifo::*;

import DataType::*;

interface PE_Control;
    method Action setTo(PE_State newState);
endinterface

interface PE_Data;
    method ActionValue#(Data) downFifoValue();
    method ActionValue#(Data) rightFifoValue();
    method Action putIntoUpFifo(Data data);
    method Action putIntoLeftFifo(Data data);

endinterface

interface PE;
    interface PE_Control control;
    interface PE_Data data;
endinterface


(* synthesize *)
module mkPE(PE);
    // Weight Storage
    Reg#(Data) weight <- mkRegU;

    // Input and Output Fifos
    Fifo#(1, Data) upFifo <- mkPipelineFifo;
    Fifo#(1, Data) downFifo <- mkPipelineFifo;
    Fifo#(1, Data) leftFifo <- mkPipelineFifo;
    Fifo#(1, Data) rightFifo <- mkPipelineFifo;

    // State
    Reg#(PE_State) state <- mkReg(Idle);


    // Rules
    rule doIdle if (state == Idle);
        $display("Idle");
    endrule

    rule doLoadWeight if (state == LoadWeight);
        $display("LoadWeight");
    endrule

    rule doCompute if (state == Compute);
        $display("Compute");
    endrule


    // Interfaces
    interface control = interface PE_Control
        method Action setTo(PE_State newState);
            state <= newState;
        endmethod
    endinterface;

    interface data = interface PE_Data
        method ActionValue#(Data) downFifoValue();
            let value = downFifo.first();
            downFifo.deq();

            return value;
        endmethod

        method ActionValue#(Data) rightFifoValue();
            let value = rightFifo.first();
            rightFifo.deq();

            return value;
        endmethod

        method Action putIntoUpFifo(Data data);
            upFifo.enq(data);
        endmethod

        method Action putIntoLeftFifo(Data data);
            leftFifo.enq(data);
        endmethod
    endinterface;
endmodule