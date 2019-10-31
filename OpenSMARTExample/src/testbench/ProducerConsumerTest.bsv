import Vector::*;
import Connectable::*;

import Types::*;
import MessageTypes::*;
import VirtualChannelTypes::*;
import RoutingTypes::*;
import CreditTypes::*;

import Network::*;
import CreditUnit::*;


typedef Bit#(32) SimInt;
SimInt maxSimulationCycle = 1000;

(* synthesize *)
module mkProducerConsumerTest();
    /// Unit Under Test
    // Please run this simulation with at least 3x2 sized mesh NoC.
    let network <- mkNetwork();
    Vector#(MeshHeight, Vector#(MeshWidth, ReverseCreditUnit)) creditUnits <- replicateM(replicateM(mkReverseCreditUnit));


    /// UUT Connections
    for (Integer i = 0; i < valueOf(MeshHeight); i = i + 1) begin
        for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
            mkConnection(creditUnits[i][j].getCredit, network.ntkPorts[i][j].putCredit);
        end
    end


    /// Simulation States
    Reg#(SimInt) cycle <- mkReg(0);
    Reg#(Bool) initialized <- mkReg(False);
    Reg#(SimInt) state <- mkReg(0);


    /// Simulation Related Rules
    rule incrementCycle if (initialized);
        cycle <= cycle + 1;
    endrule

    rule finishSimulation if (initialized && (cycle >= maxSimulationCycle));
        $display("[SIM] Max cycle reached, simulation ended at cycle %d", maxSimulationCycle);
        $finish(0);
    endrule


    /// Initialize
    rule initialize if (!initialized);
        if (network.isInited) begin
            initialized <= True;    
        end
    endrule


    /// Tests
    rule producerPutFlit if (initialized && (state == 0));
        // Make flit
        Flit flit = ?;

        flit.msgType = Data;
        flit.vc = 0;
        flit.flitType = HeadTail;
        flit.routeInfo.nextDir = east_;
        flit.routeInfo.dirX = WE_;
        flit.routeInfo.numXhops = 1;
        flit.routeInfo.dirY = NS_;
        flit.routeInfo.numYhops = 2;
        flit.flitData = cycle;

        // Send flit
        let credit <- network.ntkPorts[0][0].getCredit();
        network.ntkPorts[0][0].putFlit(flit);

        // Display
        $display("[Producer] Sent flit with data %d", flit.flitData);

        // Wait for consumer
        state <= 1;
    endrule

    rule consumerGetFlit if (initialized && (state == 1));
        // Retrive Flit
        let flit <- network.ntkPorts[2][1].getFlit();
        creditUnits[2][1].putCredit(Valid(CreditSignal_{vc: 0, isTailFlit: True}));

        // Display
        $display("[Consumer] Received flit with data %d", flit.flitData);
        
        // Wait for producer
        state <= 0;
    endrule
endmodule