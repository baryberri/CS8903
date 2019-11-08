/* 1-bit Sign, 3-bit Exponent, 3-bit Mantissa */
typedef Bit#(7) FPSmall;

typedef Bit#(1) FPSmallSign;
typedef Bit#(3) FPSmallExponent;
typedef Bit#(3) FPSmallMantissa;

typedef Bit#(TAdd#(TAdd#(3, 1), 1)) FPSmallMantissaAdded;  // 1.xxx + 1.xxx could be at most 5 digits
typedef Bit#(TMul#(TAdd#(3, 1), 2)) FPSmallMantissaMultiplied;  // 1.xxx * 1.xxx could be at most 8 digits


/* Latency Insensitive Interface */
interface LI_FPSmallAdder;
    method Action putArgA(FPSmall argA_);
    method Action putArgB(FPSmall argB_);
    method ActionValue#(FPSmall) getResult();
endinterface