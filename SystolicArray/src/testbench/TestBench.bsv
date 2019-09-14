import SystolicArray::*;
import DataType::*;

(* synthesize *)
module mkTestBench();
    let systolicArray <- mkSystolicArray();
    Reg#(Bit#(32)) cycleReg <- mkReg(0);
    Reg#(Bit#(32)) simulationStage <- mkReg(0);

    rule incrementCycle;
        cycleReg <= cycleReg + 1;
        if (cycleReg >= 100) begin
            $finish;
        end
    endrule

    rule send if (simulationStage == 0);
        systolicArray.control.setTo(Idle);
        simulationStage <= 1;
    endrule
endmodule
