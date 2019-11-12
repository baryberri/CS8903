import Vector::*;
import Connectable::*;
import Randomizable::*;

import Types::*;
import MessageTypes::*;
import VirtualChannelTypes::*;
import RoutingTypes::*;
import CreditTypes::*;

import Network::*;
import CreditUnit::*;

import AdderSerializer::*;

typedef Bit#(32) SimInt;
SimInt maxSimulationCycle = 1000;

(* synthesize *)
module mkAdderNoCTest();
    /// Unit Under Test
    Vector#(MeshHeight, Vector#(MeshWidth, AdderSerializer)) adders <- replicateM(replicateM(mkAdderSerializer));

    // Please run this simulation with exactly 3x4 sized mesh NoC.
    let network <- mkNetwork();
    Vector#(MeshHeight, Vector#(MeshWidth, ReverseCreditUnit)) creditUnits <- replicateM(replicateM(mkReverseCreditUnit));


    /// Simulation States
    Randomize#(Data) randomizer <- mkConstrainedRandomizer(1, 100);
    Reg#(SimInt) cycle <- mkReg(0);
    Reg#(Bool) initialized <- mkReg(False);
    Reg#(SimInt) state <- mkReg(0);
    

    /// UUT Connections
    // First row: put data into AdderSerializer directly
    for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
        rule getFlits(initialized);
            let flit <- adders[0][j].getFlit();

            let credit <- network.ntkPorts[0][j].getCredit();
            network.ntkPorts[0][j].putFlit(flit);
        endrule
    end

    // Adder for rows except bottom row
    for (Integer i = 1; i < valueOf(MeshHeight) - 1; i = i + 1) begin
        for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
            mkConnection(creditUnits[i][j].getCredit, network.ntkPorts[i][j].putCredit);

            rule putFlits(initialized);
                let flit <- network.ntkPorts[i][j].getFlit();
                creditUnits[i][j].putCredit(Valid(CreditSignal_{vc: flit.vc, isTailFlit: True}));

                adders[i][j].putFlit(flit);
            endrule

            rule getFlits(initialized);
                let flit <- adders[i][j].getFlit();

                let credit <- network.ntkPorts[i][j].getCredit();
                network.ntkPorts[i][j].putFlit(flit);
            endrule
        end
    end

    // Adder for last row: Don't put flit into the network
    for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
        mkConnection(creditUnits[valueOf(MeshHeight) - 1][j].getCredit, network.ntkPorts[valueOf(MeshHeight) - 1][j].putCredit);

        rule putFlits(initialized);
            let flit <- network.ntkPorts[valueOf(MeshHeight) - 1][j].getFlit();
            creditUnits[valueOf(MeshHeight) - 1][j].putCredit(Valid(CreditSignal_{vc: flit.vc, isTailFlit: True}));

            adders[valueOf(MeshHeight) - 1][j].putFlit(flit);
        endrule

        rule getFlits(initialized);
            let flit <- adders[valueOf(MeshHeight) - 1][j].getFlit();
            $display("[Result] Value %d received.", flit.flitData);
        endrule
    end


    /// Simulation Related Rules
    rule incrementCycle if (initialized);
        cycle <= cycle + 1;
    endrule

    rule finishSimulation if (initialized && (cycle >= maxSimulationCycle));
        $display("[Sim] Max cycle reached, simulation ended at cycle %d", maxSimulationCycle);
        $finish(0);
    endrule


    /// Initialize
    rule initialize if (!initialized);
        randomizer.cntrl.init();

        for (Integer i = 0; i < valueOf(MeshHeight); i = i + 1) begin
            for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
                adders[i][j].initialize(fromInteger(i), fromInteger(j));
            end
        end

        if (network.isInited() && adders[0][0].isInitialized()) begin
            initialized <= True;    
        end
    endrule


    /// Tests
    rule putData if (initialized && (state < 2));
        for (Integer j = 0; j < valueOf(MeshWidth); j = j + 1) begin
            let data <- randomizer.next();

            // Make flit
            Flit flit = ?;
            flit.flitData = data;

            // Send flit
            adders[0][j].putFlit(flit);

            // Display
            $display("[Input] Putting Data %d", flit.flitData);
        end

        state <= state + 1;
    endrule
endmodule
