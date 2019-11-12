import FixedPoint::*;
import FixedPointExamples::*;
import DataType::*;


(* synthesize *)
module mkTestBench();
    // Unit Under Test
    let uut <- mkFixedPointExamples();
    
    // Simulation variables
    Reg#(Bit#(32)) simulationState <- mkReg(0);

    rule inputData if (simulationState == 0);
        uut.putA(3.5);
        uut.putB(2.3);
        simulationState <= 1;
    endrule

    rule printResult if (simulationState == 1);
        let sum <- uut.getSum();
        $display("3.5 + 2.3 = (5.8)");
        fxptWrite(5, sum);
        $display("\n");

        let subtraction <- uut.getSubtraction();
        $display("3.5 - 2.3 = (1.2)");
        fxptWrite(5, subtraction);
        $display("\n");
        

        let multiplication <- uut.getMultiplication();
        $display("3.5 * 2.3 = (8.05)");
        fxptWrite(5, multiplication);
        $display("\n");

        $finish;
    endrule

endmodule