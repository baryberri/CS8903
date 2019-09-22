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


// Datatype
typedef Bit#(32) SimulationInt;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

(* synthesize *)
module mkTestBenchInputStationary();
    // TODO: Implement Input Stationary Test Bench
endmodule