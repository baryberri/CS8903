import Fifo::*;
import Connectable::*;
import Vector::*;
import SystolicArray::*;
import DataType::*;
import Configuration::*;


// Test mapping Size
typedef 4 FilterSize;  // Each filter's size
typedef 2 FiltersCount;  // Number of CNN filters 
typedef 5 InputLength;  // Number of resulting activations CNN generate



// Datatype
typedef Bit#(32) SimulationInteger;

(* synthesize *)
module mkTestBenchInputStationary();
    // Cycle
    Reg#(SimulationInteger) cycleReg <- mkReg(0);
    
    // Benchmarks
    Vector#(FiltersCount, Reg#(SimulationInteger)) resultsCount <- replicateM(mkReg(0));

    // Test case generation values
    Reg#(SimulationInteger) simulationState <- mkReg(0);
    Reg#(SimulationInteger) counter <- mkReg(0);
    Reg#(SimulationInteger) counter2 <- mkReg(0);
    Vector#(FiltersCount, Reg#(SimulationInteger)) widthCounter <- replicateM(mkReg(0));
    Vector#(FilterSize, Reg#(SimulationInteger)) heightCounter <- replicateM(mkReg(0));
    
    // Unit Under Test
    let systolicArray <- mkSystolicArray();


    rule cycleCount;
        cycleReg <= cycleReg + 1;
        if (cycleReg >= 1000) begin
            $display("\n[Simulation Summary] ================================================\n");
            $display("[Cycle] Simulation terminated at cycle %d\n", cycleReg);

            for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
                $display("[Computation] PE %d generated total %d activations\n", i, resultsCount[i]); 
            end
            $finish;
        end
    endrule

    for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
        rule countResult;
            let result <- systolicArray.verticalData[i].get();
            resultsCount[i] <= resultsCount[i] + 1;
            $display("[Result] PE %d, Generates Result %d\n", i, result);
        endrule
    end

    for (Integer i = 0; i < valueOf(FilterSize); i = i + 1) begin
        rule throwAwayActivationAtTheEnd;
            let result <- systolicArray.horizontalData[i].get();
        endrule
    end

    rule startSystolicArray if (simulationState == 0);
        systolicArray.control.setTo(LoadWeight);
        simulationState <= 1;
        counter <= 1;
    endrule

    rule sendWeight if (simulationState == 1);
        for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
            systolicArray.verticalData[i].put(1);
        end

        counter <= counter + 1;

        if (counter >= fromInteger(valueOf(FilterSize))) begin
            counter2 <= 0;
            simulationState <= 2;
        end
    endrule

    rule waitForWeightLoading if (simulationState == 2);
        counter2 <= counter2 + 1;
        if (counter2 >= fromInteger(valueOf(FilterSize))) begin
            simulationState <= 3;
        end
    endrule

    rule startCompuation if (simulationState == 3);
        systolicArray.control.setTo(Compute);
        simulationState <= 4;
        counter <= 0;
        counter2 <= 0;
    endrule

    rule sendActivation1 if (simulationState == 4);
        for (Integer i = 0; i < valueOf(FilterSize); i = i + 1) begin
            if ((fromInteger(i) <= counter) && (heightCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.horizontalData[i].put(1);
                heightCounter[i] <= heightCounter[i] + 1;
            end
        end

        counter <= counter + 1;

        if (heightCounter[valueOf(FilterSize) - 1] >= fromInteger(valueOf(InputLength))) begin
            simulationState <= 5;
        end
    endrule

    rule sendPsum1 if (simulationState == 4);
        for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
            if ((fromInteger(i) <= counter2) && (widthCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.verticalData[i].put(0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;
    endrule

    rule sendActivation2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(FilterSize); i = i + 1) begin
            if ((fromInteger(i) <= counter) && (heightCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.horizontalData[i].put(1);
                heightCounter[i] <= heightCounter[i] + 1;
            end
        end

        counter <= counter + 1;
    endrule

    rule sendPsum2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
            if ((fromInteger(i) <= counter2) && (widthCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.verticalData[i].put(0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;

        if (widthCounter[valueOf(FiltersCount) - 1] >= fromInteger(valueOf(InputLength))) begin
            simulationState <= 6;
        end
    endrule
endmodule
