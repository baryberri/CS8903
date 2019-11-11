import Fifo::*;

import DataType::*;
import State::*;

interface PE_Data;
    method Action putNorth(Data data);
    method Action putWest(Data data);
    method ActionValue#(Data) getEast();
    method ActionValue#(Data) getSouth();
endinterface

interface PE_Control;
    method Action setStateTo(PE_State newState);
endinterface

interface PE;
    interface PE_Data data;
    interface PE_Control control;
endinterface

(* synthesize *)
module mkPE(PE);
    /*** Fifos ***/
    Fifo#(1, Data) north <- mkBypassFifo();
    Fifo#(1, Data) west <- mkBypassFifo();
    Fifo#(1, Data) east <- mkPipelineFifo();
    Fifo#(1, Data) south <- mkPipelineFifo();


    /*** Internal States ***/
    Reg#(PE_State) state <- mkReg(Init);
    Reg#(Maybe#(Data)) loadedData <- mkReg(tagged Invalid);


    /*** Rules ***/
    rule doInit if (state == Init);
        loadedData <= tagged Invalid;
    endrule

    rule doLoad if (state == Load);
        let northValue = north.first();
        north.deq();

        case (loadedData) matches
            tagged Invalid: begin
                loadedData <= tagged Valid northValue;
            end

            tagged Valid .*: begin
                south.enq(northValue);
            end
        endcase
    endrule

    rule doComputeValid if (state == Compute && isValid(loadedData));
        let northValue = north.first();
        let westValue = west.first();
        north.deq();
        west.deq();

        let data = fromMaybe(?, loadedData);
        let result = (data * westValue) + northValue;

        east.enq(westValue);
        south.enq(result);
    endrule

    rule doComputeInvlid if (state == Compute && !isValid(loadedData));
        if (north.notEmpty()) begin
            south.enq(north.first());
            north.deq();
        end

        if (west.notEmpty()) begin
            east.enq(west.first());
            west.deq();
        end
    endrule


    /*** Interface ***/
    interface data = interface PE_Data;
        method Action putNorth(Data data);
            north.enq(data);
        endmethod

        method Action putWest(Data data);
            west.enq(data);
        endmethod

        method ActionValue#(Data) getEast();
            east.deq();
            return east.first();
        endmethod

        method ActionValue#(Data) getSouth();
            south.deq();
            return south.first();
        endmethod
    endinterface;

    interface control = interface PE_Control;
        method Action setStateTo(PE_State newState);
            state <= newState;
        endmethod
    endinterface;
endmodule
