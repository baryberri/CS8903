import Types::*;
import Adder::*;

typedef Bit#(32) SimInt;
SimInt maxSimulationCycle = 100;

(* synthesize *)
module mkAdderTest();
    /// Unit Under Test
    let adder <- mkAdder();


    /// Simulation States
    Reg#(SimInt) cycle <- mkReg(0);
    Reg#(Bool) initialized <- mkReg(False);
    Reg#(SimInt) state <- mkReg(0);


    /// Simulation Related Rules
    rule incrementCycle if (initialized);
        cycle <= cycle + 1;
    endrule

    rule finishSimulation if (initialized && (cycle >= maxSimulationCycle));
        $display("[SIM]: Max cycle reached, simulation ended at cycle %d", maxSimulationCycle);
        $finish(0);
    endrule


    /// Initialize
    rule initialize if (!initialized);
        initialized <= True;
    endrule


    /// Tests
    rule insertValue if (initialized && (state == 0));
        adder.putA(1);
        adder.putB(2);

        state <= 1;
    endrule

    rule checkResult if (initialized && (state == 1));
        let result <- adder.get();
        
        $display("[RESULT]: Expected Result: 3");
        $display("[RESULT]: Actual Result: %d", result);

        $display("[SIM]: Test done, simulation ended.");
        $finish(0);
    endrule
endmodule