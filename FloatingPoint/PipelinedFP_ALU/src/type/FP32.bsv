/*** Single-precision: 1-bit Sign, 8-bit Exponent, 23-bit Mantissa ***/
typedef Bit#(32) FP32;  // Explicit mantissa is 23-bit, meaning mantissa is actually 24-bit value.

typedef enum { Normal, Denormal, Inf, NaN } FP32State deriving (Bits, Eq);

typedef struct {
    FP32State state;
    Bit#(1) sign;
    Bit#(8) exponent;
    Bit#(25) mantissa;  // adding two 24-bit mantissa values can yield at most 25-bit.
} FP32AdderOperand deriving (Bits, Eq);

typedef struct {
    FP32AdderOperand a;
    FP32AdderOperand b;
} FP32AdderOperands deriving (Bits, Eq);


typedef struct {
    FP32State state;
    Bit#(1) sign;
    Bit#(9) exponent;  // adding two 8-bit exponent values can yield at most 9-bit.
    Bit#(48) mantissa;  // multiplying two 24-bit mantissa values can yield at most 48-bit.
} FP32MultiplierOperand deriving (Bits, Eq);

typedef struct {
    FP32MultiplierOperand a;
    FP32MultiplierOperand b;
} FP32MultiplierOperands deriving (Bits, Eq);
