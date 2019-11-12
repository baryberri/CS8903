import Connectable::*;
import Vector::*;
import PE::*;
import DataType::*;


interface SystolicArray_Control;
    method Action setTo(PE_State state);
endinterface

//             |
//             v
//        SystolicArray (put into top, fetch from bottom)
//             |
//             v
//
interface SystolicArrayVerticalData;
    method Action put(Data data);
    method ActionValue#(Data) get();
endinterface

// 
//  --> SystolicArray -->   (put into left, fetch from right)
//
interface SystolicArrayHorizontalData;
    method Action put(Data data);
    method ActionValue#(Data) get();
endinterface

interface SystolicArray;
    interface SystolicArray_Control control;
    interface Vector#(SystolicArrayHeight, SystolicArrayHorizontalData) horizontalData;
    interface Vector#(SystolicArrayWidth, SystolicArrayVerticalData) verticalData;
endinterface


(* synthesize *)
module mkSystolicArray(SystolicArray);
    // PEs
    Vector#(SystolicArrayHeight, Vector#(SystolicArrayWidth, PE)) pes <- replicateM(replicateM(mkPE));

    // Connect PEs, top to bottom
    for (Integer i = 0; i < valueOf(SystolicArrayHeight) - 1; i = i + 1) begin
        for (Integer j = 0; j < valueOf(SystolicArrayWidth); j = j + 1) begin
            mkConnection(pes[i][j].data.bottomFifoValue, pes[i + 1][j].data.putIntoTopFifo);
        end
    end

    // Connect PEs, left to right
    for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
        for (Integer j = 0; j < valueOf(SystolicArrayWidth) - 1; j = j + 1) begin
            mkConnection(pes[i][j].data.rightFifoValue, pes[i][j + 1].data.putIntoLeftFifo);
        end
    end

    // Data Interface
    Vector#(SystolicArrayHeight, SystolicArrayHorizontalData) horizontalDataDefinition = newVector;
    for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
        horizontalDataDefinition[i] = interface SystolicArrayHorizontalData
            method Action put(Data data);
                pes[i][0].data.putIntoLeftFifo(data);
            endmethod

            method ActionValue#(Data) get();
                let value <- pes[i][valueOf(SystolicArrayWidth) - 1].data.rightFifoValue();
                return value;
            endmethod
        endinterface;
    end

    Vector#(SystolicArrayWidth, SystolicArrayVerticalData) verticalDataDefinition = newVector;
    for (Integer i = 0; i < valueOf(SystolicArrayWidth); i = i + 1) begin
        verticalDataDefinition[i] = interface SystolicArrayVerticalData
            method Action put(Data data);
                pes[0][i].data.putIntoTopFifo(data);
            endmethod

            method ActionValue#(Data) get();
                let value <- pes[valueOf(SystolicArrayHeight) - 1][i].data.bottomFifoValue();
                return value;
            endmethod
        endinterface;
    end

    interface horizontalData = horizontalDataDefinition;
    interface verticalData = verticalDataDefinition;

    // Control Interface
    interface control = interface SystolicArray_Control
        method Action setTo(PE_State state);
            for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
                for (Integer j = 0; j < valueOf(SystolicArrayWidth); j = j + 1) begin
                    pes[i][j].control.setTo(state);
                end
            end
        endmethod
    endinterface;

endmodule
