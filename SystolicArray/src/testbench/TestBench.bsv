import Fifo::*;
import Connectable::*;
import Vector::*;
import SystolicArray::*;
import DataType::*;

(* synthesize *)
module mkTestBench();
    Reg#(Bit#(32)) cycleReg <- mkReg(0);
    Reg#(Bit#(32)) simulationState <- mkReg(0);
    Reg#(Bit#(32)) counter <- mkReg(0);
    Reg#(Bit#(32)) counter2 <- mkReg(0);
    Reg#(Bool) flag <- mkReg(False);
    Vector#(SystolicArrayWidth, Reg#(Bit#(32))) widthCounter <- replicateM(mkReg(0));
    Vector#(SystolicArrayHeight, Reg#(Bit#(32))) heightCounter <- replicateM(mkReg(0));
    
    // Unit Under Test
    let systolicArray <- mkSystolicArray();

    rule cycleCount;
        cycleReg <= cycleReg + 1;
        if (cycleReg >= 1000) begin
            $finish;
        end
    endrule

    for (Integer i = 0; i < valueOf(SystolicArrayWidth); i = i + 1) begin
        rule printResult;
            let result <- systolicArray.verticalData[i].get();
            $display("[Cycle %d] [At %d]: Result %d\n", cycleReg, i, result);
        endrule
    end

    for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
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
        for (Integer i = 0; i < valueOf(SystolicArrayWidth); i = i + 1) begin
            systolicArray.verticalData[i].put(fromInteger(i + 1));
        end

        counter <= counter + 1;

        if (counter >= fromInteger(valueOf(SystolicArrayHeight))) begin
            counter2 <= 0;
            simulationState <= 2;
        end
    endrule

    rule waitForWeightLoading if (simulationState == 2);
        counter2 <= counter2 + 1;
        if (counter2 >= fromInteger(valueOf(SystolicArrayHeight))) begin
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
        for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
            if ((fromInteger(i) <= counter) && (heightCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.horizontalData[i].put(counter);
                heightCounter[i] <= heightCounter[i] + 1;
            end
        end

        counter <= counter + 1;

        if (heightCounter[valueOf(SystolicArrayHeight) - 1] >= fromInteger(valueOf(InputLength))) begin
            simulationState <= 5;
        end
    endrule

    rule sendPsum1 if (simulationState == 4);
        for (Integer i = 0; i < valueOf(SystolicArrayWidth); i = i + 1) begin
            if ((fromInteger(i) <= counter2) && (widthCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.verticalData[i].put(0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;
    endrule

    rule sendActivation2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(SystolicArrayHeight); i = i + 1) begin
            if ((fromInteger(i) <= counter) && (heightCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.horizontalData[i].put(counter);
                heightCounter[i] <= heightCounter[i] + 1;
            end
        end

        counter <= counter + 1;
    endrule

    rule sendPsum2 if (simulationState == 5);
        for (Integer i = 0; i < valueOf(SystolicArrayWidth); i = i + 1) begin
            if ((fromInteger(i) <= counter2) && (widthCounter[i] < fromInteger(valueOf(InputLength)))) begin
                systolicArray.verticalData[i].put(0);
                widthCounter[i] <= widthCounter[i] + 1;
            end
        end

        counter2 <= counter2 + 1;

        if (widthCounter[valueOf(SystolicArrayWidth) - 1] >= fromInteger(valueOf(InputLength))) begin
            simulationState <= 6;
        end
    endrule
endmodule
