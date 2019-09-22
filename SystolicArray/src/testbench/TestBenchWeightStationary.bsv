import Fifo::*;
import Connectable::*;
import Vector::*;
import FixedPoint::*;
import SystolicArray::*;
import DataType::*;
import Configuration::*;


// Test mapping Size
typedef 4 FilterSize;  // Each filter's size; if filter is (2x2)x2, then 8
typedef 3 FiltersCount;  // Number of CNN filters; if there are 4 filters, then 4 (output channel)
typedef 7 InputLength;  // Number of resulting activations CNN generate; if output is (3x3)x4, then 9



// Datatype
typedef Bit#(32) SimulationInt;

(* synthesize *)
module mkTestBenchWeightStationary();
    // Cycle
    Reg#(SimulationInt) cycleReg <- mkReg(0);
    
    // Benchmarks
    Vector#(FiltersCount, Reg#(SimulationInt)) resultsCount <- replicateM(mkReg(0));

    // Test case generation values
    Reg#(SimulationInt) simulationState <- mkReg(0);
    Reg#(SimulationInt) counter <- mkReg(0);
    Reg#(SimulationInt) counter2 <- mkReg(0);
    Vector#(FiltersCount, Reg#(SimulationInt)) widthCounter <- replicateM(mkReg(0));
    Vector#(FilterSize, Reg#(SimulationInt)) heightCounter <- replicateM(mkReg(0));
    
    // Unit Under Test
    let systolicArray <- mkSystolicArray();


    rule cycleCount;
        cycleReg <= cycleReg + 1;
        if (cycleReg >= 10000) begin
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
            `ifdef PRINT_RESULT
            $display("[Result] PE %d, Generates Result: ", i);
            fxptWrite(5, result);
            $display("\n");
            `endif
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
            systolicArray.verticalData[i].put(3.3);
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
                systolicArray.horizontalData[i].put(1.7);
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
                systolicArray.verticalData[i].put(0.0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;
    endrule

    rule sendActivation2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(FilterSize); i = i + 1) begin
            if ((fromInteger(i) <= counter) && (heightCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.horizontalData[i].put(1.7);
                heightCounter[i] <= heightCounter[i] + 1;
            end
        end

        counter <= counter + 1;
    endrule

    rule sendPsum2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
            if ((fromInteger(i) <= counter2) && (widthCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.verticalData[i].put(0.0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;

        if (widthCounter[valueOf(FiltersCount) - 1] >= fromInteger(valueOf(InputLength))) begin
            simulationState <= 6;
        end
    endrule

    rule waitForComputation if (simulationState == 6);
        if (resultsCount[valueOf(FiltersCount) - 1] % fromInteger(valueOf(InputLength)) == 0) begin
            simulationState <= 7;
        end
    endrule

    rule clearSystolicArray if (simulationState == 7);
        systolicArray.control.setTo(Clear);

        for (Integer i = 0; i < valueOf(FiltersCount); i = i + 1) begin
            widthCounter[i] <= 0;
        end

        for (Integer i = 0; i < valueOf(FilterSize); i = i + 1) begin
            heightCounter[i] <= 0;
        end
        
        simulationState <= 8;
    endrule

    rule resetSystolicArray if (simulationState == 8);
        systolicArray.control.setTo(Idle);
        simulationState <= 0;
    endrule
endmodule
