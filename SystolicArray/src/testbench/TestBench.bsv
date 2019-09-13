import PE::*;
import DataType::*;

(* synthesize *)
module mkTestBench();
    let uut <- mkPE;
    Reg#(Bit#(32)) cycleReg <- mkReg(0);
    Reg#(Bit#(3)) state <- mkReg(0);

    rule incrementCycle;
        cycleReg <= cycleReg + 1;

        if (cycleReg > 100) begin
            $finish;
        end
    endrule

    rule doIdle if (state == 0);
        uut.control.setTo(Idle);
        state <= 1;
    endrule

    rule doLoadWeight if (state == 1);
        if (cycleReg >= 10) begin
            uut.control.setTo(LoadWeight);
            state <= 2;
        end
    endrule

    rule doCompute if (state == 2);
        if (cycleReg >= 20) begin
            uut.control.setTo(Compute);
            state <= 3;
        end
    endrule

    rule doFinish if (state == 3);
        if (cycleReg >= 30) begin
            $display("Done!");
            $finish;
        end
    endrule

endmodule