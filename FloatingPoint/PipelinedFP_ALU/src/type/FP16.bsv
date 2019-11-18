/*** Half-precision: 1-bit Sign, 5-bit Exponent, 10-bit Mantissa ***/
typedef Bit#(16) FP16;  // Explicit mantissa is 10-bit, meaning mantissa is actually 11-bit value.

typedef enum { Normal, Denormal, Inf, NaN } FP16State deriving (Bits, Eq);

typedef struct {
    FP16State state;
    Bit#(1) sign;
    Bit#(5) exponent;
    Bit#(12) mantissa;  // adding two 11-bit mantissa values can yield at most 12-bit.
} FP16AdderOperand deriving (Bits, Eq);

typedef struct {
    FP16AdderOperand a;
    FP16AdderOperand b;
} FP16AdderOperands deriving (Bits, Eq);


typedef struct {
    FP16State state;
    Bit#(1) sign;
    Bit#(6) exponent;  // adding two 5-bit exponent values can yield at most 6-bit.
    Bit#(22) mantissa;  // multiplying two 11-bit mantissa values can yield at most 22-bit.
} FP16MultiplierOperand deriving (Bits, Eq);

typedef struct {
    FP16MultiplierOperand a;
    FP16MultiplierOperand b;
} FP16MultiplierOperands deriving (Bits, Eq);
