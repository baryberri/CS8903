/* 1-bit Sign, 3-bit Exponent, 3-bit Mantissa */
typedef Bit#(7) FPSmall;

/* FPSmall Breakdown */
typedef Bit#(1) FPSmallSign;
typedef Bit#(3) FPSmallExponent;
typedef Bit#(3) FPSmallMantissa;

/* Types for Computation */
typedef Bit#(4) FPSmallExponentAdded;  // Adding two 3-bit values yields a 4-bit value.

// Even though mantissa is represented as a 3-bit value,
// It's actually 4-bit (1.xxx or 0.xxx).
typedef Bit#(5) FPSmallMantissaAdded;  // Adding two 4-bit values yields a 5-bit value.
typedef Bit#(8) FPSmallMantissaMultiplied;  // Multiplying two 4-bit values yields a 8-bit value.


/* Latency Insensitive Interface */
interface LI_FPSmallALU;
    method Action putArgA(FPSmall argA_);
    method Action putArgB(FPSmall argB_);
    method ActionValue#(FPSmall) getResult();
endinterface
