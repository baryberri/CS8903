import Vector::*;
import Connectable::*;

import PE::*;

import SystolicArrayType::*;
import DataType::*;
import State::*;


interface SystolicArrayData;
    method Action putNorth(Data data);
    method Action putWest(Data data);
    method ActionValue#(Data) getEast();
    method ActionValue#(Data) getSouth();
endinterface

interface SystolicArrayControl;
    method Action setStateTo(PE_State newState);
endinterface

interface SystolicArray;
    interface Vector#(SystolicArraySize, SystolicArrayData) data;
    interface SystolicArrayControl control;
endinterface

(* synthesize *)
module mkSystolicArray(SystolicArray);
    /*** PEs ***/
    Vector#(SystolicArraySize, Vector#(SystolicArraySize, PE)) pes <- replicateM(replicateM(mkPE()));
    

    /*** PEs Connection ***/
    for (Integer i = 0; i < valueOf(SystolicArraySize) - 1; i = i + 1) begin
        for (Integer j = 0; j < valueOf(SystolicArraySize); j = j + 1) begin
            mkConnection(pes[i][j].data.getSouth, pes[i + 1][j].data.putNorth);
        end
    end

    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        for (Integer j = 0; j < valueOf(SystolicArraySize) - 1; j = j + 1) begin
            mkConnection(pes[i][j].data.getEast, pes[i][j + 1].data.putWest);
        end
    end


    /*** Interface ***/
    Vector#(SystolicArraySize, SystolicArrayData) dataDef = newVector();
    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        dataDef[i] = interface SystolicArrayData
            method Action putNorth(Data data);
                pes[0][i].data.putNorth(data);
            endmethod

            method Action putWest(Data data);
                pes[i][0].data.putWest(data);
            endmethod

            method ActionValue#(Data) getEast();
                let east <- pes[i][valueOf(SystolicArraySize) - 1].data.getEast();
                return east;
            endmethod

            method ActionValue#(Data) getSouth();
                let south <- pes[valueOf(SystolicArraySize) - 1][i].data.getSouth();
                return south;
            endmethod
        endinterface;
    end
    interface data = dataDef;

    interface control = interface SystolicArrayControl
        method Action setStateTo(PE_State newState);
            for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
                for (Integer j = 0; j < valueOf(SystolicArraySize); j = j + 1) begin
                    pes[i][j].control.setStateTo(newState);
                end
            end
        endmethod
    endinterface;
endmodule
