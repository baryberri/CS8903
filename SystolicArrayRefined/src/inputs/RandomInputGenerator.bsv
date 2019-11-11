import Vector::*;
import Randomizable::*;

import DataType::*;
import SystolicArrayType::*;

interface ConstantInputGeneratorData;
    method ActionValue#(Vector#(SystolicArraySize, Maybe#(Data))) get();
endinterface

interface ConstantInputGeneratorControl;
    method Action next(Maybe#(Data) nextData);
    method Action init();
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
    Randomize#(Data) randomData <- mkConstrainedRandomizer(0, 10);

    
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
            case (nextData) matches
                tagged Invalid: begin
                    dataReg[0] <= nextData;            
                end

                tagged Valid .*: begin
                    let newData <- randomData.next();
                    dataReg[0] <= newData;
                end
            endcase            
        endmethod

        method Action init();
            randomData.cntrl.init();
        endmethod
    endinterface;
endmodule
