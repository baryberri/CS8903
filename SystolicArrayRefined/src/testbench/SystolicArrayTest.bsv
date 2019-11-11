import SystolicArray::*;
import ConstantInputGenerator::*;

import SystolicArrayType::*;
import DataType::*;
import State::*;


typedef Bit#(32) SimInt;
SimInt maxCycle = 10000


(* synthesize *)
module mkSystolicArrayTest();
    /*** Unit Under Test ***/
    let systolicArray <- mkSystolicArray();


    /*** Benchmarks ***/


    /*** Internal States ***/
    let activationGenerator <- mkConstantInputGenerator();
    let psumGenerator <- mkConstantInputGenerator();

    Reg#(SimInt) cycle <- mkReg(0);
    Reg#(SimInt) state <- mkReg(0);
    Reg#(SimInt) counter <- mkReg(0);


    /*** Simulation ***/
    rule doSimulation;
        cycle <= cycle + 1;
    endrule

    rule finishSimulation if (cycle >= maxCycle);
        $dipslay("[Sim] Simulation finished: max cycle %d reached.", maxCycle);
        $finish(0);
    endrule


    /*** Systolic Array Operation ***/
    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        rule displayResult;
            let result <- systolicArray.data[i].getSouth();
            $display("[Result]: %d", result);
        endrule

        rule pullLastActivation;
            let lastActivation <- systolicArray.data[i].getEast();
        endrule
    end


    /*** Tests ***/
    rule startSystolicArray if (state == 0);
        systolicArray.setStateTo(Load);

        state <= 1;
    endrule

    rule putWeight if (state == 1 && counter < 2);
        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            systolicArray.data[i].putNorth(1);
        end

        counter <= counter + 1;
    endrule

    rule waitForWeightLoading if (state == 1 && (2 <= counter && counter < 4));
        counter <= counter + 1;
    endrule

    rule initGenerators if (state == 1 && (4 <= counter && counter < 5))
        psumGenerator.next(tagged Valid 0);
        activationGenerator.next(tagged Valid 1);  // activation

        counter <= counter + 1;
    endrule

    rule startComputation if (state == 1 && counter >= 5);
        let psum <- psumGenerator.get();
        let activation <- activationGenerator.get(); 

        psumGenerator.next(tagged Valid 0);
        activationGenerator.next(tagged Valid 1);  // activation

        systolicArray.setStateTo(Compute);

        counter <= 0;
        state <= 2;
    endrule

    rule putStartData if (state == 2 && counter < 6);
        let psum <- psumGenerator.get();
        let activation <- activationGenerator.get();

        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            if (psum[i] matches tagged Valid .psumValue) begin
                systolicArray.data[i].putNorth(psumValue);
            end

            if (activation[i] matches tagged Valid .activationValue) begin
                systolicArray.data[i].putWest(activationValue);
            end
        end

        psumGenerator.next(tagged Valid 0);
        activationGenerator.next(tagged Valid 1);

        counter <= counter + 1;
    endrule

    rule putEndData if (state == 2 && (6 <= counter && counter < 10));
        let psum <- psumGenerator.get();
        let activation <- activationGenerator.get();

        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            if (psum[i] matches tagged Valid .psumValue) begin
                systolicArray.data[i].putNorth(psumValue);
            end

            if (activation[i] matches tagged Valid .activationValue) begin
                systolicArray.data[i].putWest(activationValue);
            end
        end

        psumGenerator.next(tagged Invalid);
        activationGenerator.next(tagged Invalid);
        
        counter <= counter + 1;
    endrule

    rule waitForComputation if (state == 2 && (10 <= counter && counter < 30));
        counter <= counter + 1;
    endrule

    rule resetSystolicArray if (state == 2 && counter >= 30);
        systolicArray.setStateTo(Idle);

        counter <= 0;
        // state <= 0;

        $display("[Sim] Job done, simulation finished.");
        $finish(0);
    endrule
endmodule
