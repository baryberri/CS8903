import Vector::*;
import Fifo::*;

import DataType::*;
import SystolicArrayType::*;

interface ConstantInputGeneratorControl;
    method Action setMaxLengthTo(Bit#(32) newMaxLength);
endinterface

interface ConstantInputGeneratorData;
    method ActionValue#(Vector#(SystolicArraySize, Maybe#(Data))) get(Maybe#(Data) nextData);
endinterface

interface ConstantInputGenerator;
    interface ConstantInputGeneratorControl control;
    interface ConstantInputGeneratorData data;
endinterface

(* synthesize *)
module mkConstantInputGenerator(ConstantInputGenerator);
    /*** Internal States ***/
    Vector#(SystolicArraySize, Reg#(Maybe#(Data))) dataReg <- replicateM(mkReg(tagged Invalid));
    Fifo#(1, Vector#(SystolicArraySize, Maybe#(Data))) dataFifo <- mkBypassFifo();
    Reg#(Bit#(32)) maxLength <- mkRegU;

    /*** Interfaces ***/
    interface control = interface ConstantInputGeneratorControl
        method Action setMaxLengthTo(Bit#(32) newMaxLength);
            maxLength <= newMaxLength;
        endmethod
    endinterface;
    interface data = interface ConstantInputGeneratorData
        method ActionValue#(Vector#(SystolicArraySize, Maybe#(Data))) get(Maybe#(Data) nextData);
            // Update to next data
            for (Integer i = valueOf(SystolicArraySize) - 1; i >= 1; i = i - 1) begin
                if (fromInteger(i) >= maxLength) begin
                    dataReg[i] <= tagged Invalid;
                end else begin
                    dataReg[i] <= dataReg[i - 1];
                end
            end
            dataReg[0] <= nextData;

            // Put current data into the queue
            Vector#(SystolicArraySize, Maybe#(Data)) data = newVector();
            for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
                data[i] = dataReg[i];
            end
            return data;
        endmethod
    endinterface;
endmodule
