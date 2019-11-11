import Vector::*;

import DataType::*;
import SystolicArrayType::*;

interface ConstantInputGeneratorData;
    method ActionValue#(Vector#(SystolicArraySize, Maybe#(Data))) get();
endinterface

interface ConstantInputGeneratorControl;
    method Action next(Maybe#(Data) nextData);
endinterface

interface ConstantInputGenerator;
    interface ConstantInputGeneratorData data;
    interface ConstantInputGeneratorControl control;
endinterface

(* synthesize *)
module mkConstantInputGenerator(ConstantInputGenerator);
    /*** Internal States ***/
    Vector#(SystolicArraySize, Reg#(Maybe#(Data))) dataReg <- replicateM(mkReg(tagged Invalid));
    Fifo#(1, Vector#(SystolicArraySize, Maybe#(Data))) dataFifo <- mkBypassFifo();

    /*** Interfaces ***/
    interface data = interface ConstantInputGeneratorData
        method ActionValue#(Vector#(SystolicArraySize, Maybe#(Data))) get();
            dataFifo.deq();
            return dataFifo.first();
        endmethod
    endinterface;

    interface control = interface ConstantInputGeneratorControl
        method Action next(Maybe#(Data) nextData);
            // Put current data into the queue
            Vector#(SystolicArraySize, Maybe#(Data)) data = newVector();
            for (Intger i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
                data[i] = dataReg[i];
            end
            dataFifo.enq(data);

            // Update to next data
            for (Integer i = valueOf(SystolicArraySize) - 1; i >= 1; i = i - 1) begin
                dataReg[i] <= dataReg[i - 1];
            end
            dataReg[0] <= nextData;
        endmethod
    endinterface;
endmodule
