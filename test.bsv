module mkAdder(Adder);
  rule doAddition;
    let operandA = argA.first;
    let operandB = argB.first;
    argA.deq;
    argB.deq;
    
    result.enq(operandA + operandB);
  endrule
endmodule
