import Fifo::*;
import Connectable::*;
import Vector::*;
import FixedPoint::*;
import SystolicArray::*;
import DataType::*;
import Configuration::*;


// Test mapping Size
typedef 8 FilterSize;  // Each filter's size; if filter is (2x2)x2, then 8
typedef 4 FiltersCount;  // Number of CNN filters; if there are 4 filters, then 4 (output channel)
typedef 9 OutputLength;  // Number of resulting activations CNN generate; if output is (3x3)x4, then 9
typedef 10000 FinalCycle;  // Simulation Length


// Datatype
typedef Bit#(32) SimulationInt;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

(* synthesize *)
module mkTestBenchInputStationary();
    // Unit Under Test
    let systolicArray <- mkSystolicArray();

    // Benchmarking Values
    Vector#(SystolicArraySize, Reg#(SimulationInt)) resultsCount <- replicateM(mkReg(0));
    Reg#(SimulationInt) processedBatchesCount <- mkReg(0);

    // Simulation Values
    Reg#(SimulationInt) cycleReg <- mkReg(0);
    Reg#(SimulationInt) simulationState <- mkReg(0);
    Reg#(SimulationInt) currentMappingSize <- mkReg(0);
    Reg#(SimulationInt) leftMappingSize <- mkReg(0);
    Reg#(SimulationInt) counter1 <- mkReg(0);
    Reg#(SimulationInt) counter2 <- mkReg(0);
    Vector#(SystolicArraySize, Reg#(SimulationInt)) horizontalCounter <- replicateM(mkReg(0));
    Vector#(SystolicArraySize, Reg#(SimulationInt)) verticalCounter <- replicateM(mkReg(0));
    
    rule runTestBench;
        cycleReg <= cycleReg + 1;
        if (cycleReg >= fromInteger(valueOf(FinalCycle))) begin
            $display("\n[Simulation Summary] ================================================\n");
            $display("[Cycle] Simulation terminated at cycle %d\n", cycleReg);

            for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
                $display("[Computation] PE %d generated total %d activations\n", i, resultsCount[i]); 
            end

            $display("[Batch] %d batches are processed\n", processedBatchesCount);

            $finish;
        end
    endrule

    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        rule printResult;
            let result <- systolicArray.verticalData[i].get();
            resultsCount[i] <= resultsCount[i] + 1;

            `ifdef PRINT_RESULT
            $display("[Result] PE %d, Generated Result:", i);
            fxptWrite(5, result);
            $display("\n");
            `endif
        endrule
    end

    for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
        rule throwAwayForwarededValue;
            let result <- systolicArray.horizontalData[i].get();
        endrule
    end

    rule startSystolicArray if (simulationState == 0);
        if (valueOf(SystolicArraySize) >= valueOf(OutputLength)) begin
            currentMappingSize <= fromInteger(valueOf(OutputLength));
            leftMappingSize <= fromInteger(valueOf(OutputLength));
        end else begin
            currentMappingSize <= fromInteger(valueOf(SystolicArraySize));
            leftMappingSize <= fromInteger(valueOf(OutputLength));
        end
        
        systolicArray.control.setTo(LoadWeight);
        counter1 <= 1;
        simulationState <= 1;
    endrule

    rule sendWeight if (simulationState == 1);
        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            if (fromInteger(i) < currentMappingSize) begin
                systolicArray.verticalData[i].put(3.3);
            end
        end
        counter1 <= counter1 + 1;
        if (counter1 >= fromInteger(valueOf(FilterSize))) begin
            counter2 <= 1;
            simulationState <= 2;
        end
    endrule

    rule waitForWeightDistribution if (simulationState == 2);
        counter2 <= counter2 + 1;
        if (counter2 >= fromInteger(valueOf(FilterSize))) begin
            simulationState <= 3;
        end
    endrule

    rule startComputation if (simulationState == 3);
        systolicArray.control.setTo(Compute);
        simulationState <= 4;

        SimulationInt len1 = fromInteger((valueOf(FilterSize) - 1) + valueOf(FiltersCount));
        SimulationInt len2 = (currentMappingSize - 1) + fromInteger(valueOf(FiltersCount));

        // number of cycles needed to put all values
        counter1 <= 1;
        counter2 <= (len1 > len2) ? len1 : len2;
    endrule
    
    rule sendValues if (simulationState == 4);
        counter1 <= counter1 + 1;

        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            // put psum
            if ((fromInteger(i) < currentMappingSize) && (fromInteger(i) < counter1)) begin
                if (verticalCounter[i] < fromInteger(valueOf(FiltersCount))) begin
                    systolicArray.verticalData[i].put(0.0);
                    verticalCounter[i] <= verticalCounter[i] + 1;
                end
            end

            // put activation
            if ((i < valueOf(FilterSize)) && (fromInteger(i) < counter1)) begin
                if (horizontalCounter[i] < fromInteger(valueOf(FiltersCount))) begin
                    systolicArray.horizontalData[i].put(1.7);
                    horizontalCounter[i] <= horizontalCounter[i] + 1;
                end
            end
        end

        // sending completed
        if (counter1 >= counter2) begin
            simulationState <= 5;
            counter2 <= 1;
        end
    endrule

    rule waitForComputation if (simulationState == 5);
        counter2 <= counter2 + 1;
        if (counter2 >= fromInteger(valueOf(SystolicArraySize))) begin
            counter1 <= 0;
            simulationState <= 6;
        end
    endrule

    rule clearSystolicArray if (simulationState == 6);
        systolicArray.control.setTo(Clear);
        leftMappingSize <= leftMappingSize - currentMappingSize;
        simulationState <= 7;
    endrule

    rule resetSystolicArray if (simulationState == 7);
        if (leftMappingSize <= 0) begin
            systolicArray.control.setTo(Idle);
            processedBatchesCount <= processedBatchesCount + 1;
            simulationState <= 0;
        end else begin
            if (leftMappingSize <= fromInteger(valueOf(SystolicArraySize))) begin
                currentMappingSize <= leftMappingSize;
            end else begin
                currentMappingSize <= fromInteger(valueOf(SystolicArraySize));
            end
            systolicArray.control.setTo(LoadWeight);
            simulationState <= 1;
        end

        counter1 <= 1;
        counter2 <= 1;
        for (Integer i = 0; i < valueOf(SystolicArraySize); i = i + 1) begin
            horizontalCounter[i] <= 0;
            verticalCounter[i] <= 0;
        end
    endrule
endmodule