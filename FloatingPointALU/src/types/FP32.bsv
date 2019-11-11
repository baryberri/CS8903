/* Single-Precision Floating-Point */
/* 1-bit Sign, 8-bit Exponent, 23-bit Mantissa */
typedef Bit#(32) FP32;

/* FP32 Breakdown */
typedef Bit#(1) FP32Sign;
typedef Bit#(8) FP32Exponent;
typedef Bit#(23) FP32Mantissa;

/* Types for Computation */
typedef Bit#(9) FP32ExponentAdded;  // Adding two 8-bit values yields a 9-bit value.

// Even though mantissa is represented as a 23-bit value,
// It's actually 24-bit (1.xxx or 0.xxx).
typedef Bit#(25) FP32MantissaAdded;  // Adding two 24-bit values yields a 25-bit value.
typedef Bit#(48) FP32MantissaMultiplied;  // Multiplying two 24-bit values yields a 48-bit value.


/* Latency Insensitive Interface */
interface LI_FP32ALU;
    method Action putArgA(FP32 argA_);
    method Action putArgB(FP32 argB_);
    method ActionValue#(FP32) getResult();
endinterface
