/* Half-Precision Floating-Point */
/* 1-bit Sign, 5-bit Exponent, 10-bit Mantissa */
typedef Bit#(16) FP16;

/* FP16 Breakdown */
typedef Bit#(1) FP16Sign;
typedef Bit#(5) FP16Exponent;
typedef Bit#(10) FP16Mantissa;

/* Types for Computation */
typedef Bit#(6) FP16ExponentAdded;  // Adding two 5-bit values yields a 6-bit value.

// Even though mantissa is represented as a 10-bit value,
// It's actually 11-bit (1.xxx or 0.xxx).
typedef Bit#(12) FP16MantissaAdded;  // Adding two 11-bit values yields a 12-bit value.
typedef Bit#(22) FP16MantissaMultiplied;  // Multiplying two 11-bit values yields a 22-bit value.


/* Latency Insensitive Interface */
interface LI_FP16ALU;
    method Action putArgA(FP16 argA_);
    method Action putArgB(FP16 argB_);
    method ActionValue#(FP16) getResult();
endinterface
