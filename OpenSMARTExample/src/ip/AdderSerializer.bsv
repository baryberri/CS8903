import Types::*;
import MessageTypes::*;
import VirtualChannelTypes::*;
import RoutingTypes::*;
import CreditTypes::*;

import Adder::*;

interface AdderSerializer;
    method Action initialize(MeshHIdx yId, MeshWIdx xID);
    method Bool isInitialized();

    method Action putFlit(Flit flit);
    method ActionValue#(Flit) getFlit();
endinterface

(* synthesize *)
module mkAdderSerializer(AdderSerializer);
    /// Internal States
    Reg#(MeshWIdx) wID <- mkRegU();
    Reg#(MeshHIdx) hID <- mkRegU();
    Reg#(Bool) initialized <- mkReg(False);
    Reg#(Bool) putIntoA <- mkReg(True);


    /// Internal Modules
    let adder <- mkAdder();
    

    /// Interface Definition
    method Action initialize(MeshHIdx yID, MeshWIdx xID);
        wID <= xID;
        hID <= yID;
        initialized <= True;
    endmethod

    method Bool isInitialized();
        return initialized;
    endmethod

    method Action putFlit(Flit flit);
        case (putIntoA)
            True: begin
                adder.putA(flit.flitData);
            end

            False: begin
                adder.putB(flit.flitData);    
            end
        endcase
        
        putIntoA <= !putIntoA;
    endmethod

    method ActionValue#(Flit) getFlit();
        let adderResult <- adder.get();
        
        Flit flit = ?;
        
        flit.flitData= adderResult;
        flit.msgType = Data;
        flit.vc = 0;
        flit.flitType = HeadTail;
        
        let xDest = 0;
        if (wID > hID) begin
            xDest = (wID - hID) / 2;
        end else begin
            xDest = (hID - wID) / 2;
        end
        let yDest = hID + 1;

        let goingEast = xDest > wID;
        let goingSouth = yDest > hID;

        let xhops = goingEast ? xDest - wID : wID - xDest;
        let yhops = goingSouth ? yDest - hID : hID - yDest;

        if (xDest != wID) begin
            flit.routeInfo.nextDir = goingEast ? east_ : west_;
        end else if (yDest != hID) begin
            flit.routeInfo.nextDir = goingSouth ? south_ : north_;
        end else begin
            flit.routeInfo.nextDir = local_;
        end

        flit.routeInfo.dirX = goingEast ? WE_ : EW_;
        flit.routeInfo.numXhops = xhops;
        flit.routeInfo.dirY = goingSouth ? NS_ : SN_;
        flit.routeInfo.numYhops = yhops;
        
        return flit;
    endmethod
endmodule
