import SystolicArray::*;
import ConstantInputGenerator::*;

import SystolicArrayType::*;
import DataType::*;
import State::*;


typedef Bit#(32) SimInt;
SimInt maxCycle = 10000;

typedef 13 MappingWidth;
typedef 11 MappingHeight;
typedef 15 InputLength;
// (0), (0, 1), (0, 1, 2), .... (0, 1, 2, 3, 4), (0, 1, 2, 3, 4), ...,  (0, 1, 2, 3, 4) => InputLength

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
        $display("[Sim] Simulation finished: max cycle %d reached.", maxCycle);
        $finish(0);
    endrule


    /*** Systolic Array Operation ***/
    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        rule displayResult;
            let result <- systolicArray.data[i].getSouth();
            $display("[Result]: PE %d -> %d", i, result);
        endrule

        rule pullLastActivation;
            let lastActivation <- systolicArray.data[i].getEast();
        endrule
    end


    /*** Tests ***/
    rule startSystolicArray if (state == 0);
        psumGenerator.control.setMaxLengthTo(fromInteger(valueOf(MappingWidth)));
        activationGenerator.control.setMaxLengthTo(fromInteger(valueOf(MappingHeight)));

        systolicArray.control.setStateTo(Load);

        state <= 1;
    endrule

    rule putWeight if (state == 1 && counter < fromInteger(valueOf(MappingHeight)));
        for (Integer i = 0; i < valueOf(MappingWidth); i = i + 1) begin
            systolicArray.data[i].putNorth(1);
        end

        counter <= counter + 1;
    endrule

    rule waitForWeightLoading if (state == 1 && (fromInteger(valueOf(MappingHeight)) <= counter && counter < fromInteger(valueOf(MappingHeight) + valueOf(SystolicArraySize))));
        counter <= counter + 1;
    endrule

    rule startComputation if (state == 1 && counter >= fromInteger(valueOf(MappingHeight) + valueOf(SystolicArraySize)));
        let psum <- psumGenerator.data.get(tagged Valid 0);
        let activation <- activationGenerator.data.get(tagged Valid 1); // activation 

        systolicArray.control.setStateTo(Compute);

        counter <= 0;
        state <= 2;
    endrule

    rule putStartData if (state == 2 && (counter < fromInteger(valueOf(InputLength))));
        let psum <- psumGenerator.data.get(tagged Valid 0);
        let activation <- activationGenerator.data.get(tagged Valid 1); // activation

        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            if (psum[i] matches tagged Valid .psumValue) begin
                systolicArray.data[i].putNorth(psumValue);
                $display("[Input] PE %d <- psum %d", i, psumValue);
            end

            if (activation[i] matches tagged Valid .activationValue) begin
                systolicArray.data[i].putWest(activationValue);
                $display("[Input] PE %d <- activation %d", i, activationValue);
            end
        end
        counter <= counter + 1;
    endrule

    rule putEndData if (state == 2 && (fromInteger(valueOf(InputLength)) <= counter && counter < fromInteger(valueOf(InputLength) * 2)));
        let psum <- psumGenerator.data.get(tagged Invalid);
        let activation <- activationGenerator.data.get(tagged Invalid);

        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            if (psum[i] matches tagged Valid .psumValue) begin
                systolicArray.data[i].putNorth(psumValue);
                $display("[Input] PE %d <- psum %d", i, psumValue);
            end

            if (activation[i] matches tagged Valid .activationValue) begin
                systolicArray.data[i].putWest(activationValue);
                $display("[Input] PE %d <- activation %d", i, activationValue);
            end
        end
        
        counter <= counter + 1;
    endrule

    rule waitForComputation if (state == 2 && (fromInteger(valueOf(InputLength) * 2) <= counter && counter < fromInteger(valueOf(InputLength) * 2 + valueOf(SystolicArraySize))));
        counter <= counter + 1;
    endrule

    rule resetSystolicArray if (state == 2 && (counter >= fromInteger(valueOf(InputLength) * 2 + valueOf(SystolicArraySize))));
        systolicArray.control.setStateTo(Init);

        counter <= 0;
        // state <= 0;

        $display("[Sim] Job done, simulation finished.");
        $finish(0);
    endrule
endmodule
