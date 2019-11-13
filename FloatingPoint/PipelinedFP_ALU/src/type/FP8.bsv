/*** Minifloat: 1-bit Sign, 4-bit Exponent, 3-bit Mantissa ***/
typedef Bit#(8) FP8;  // Explicit mantissa is 3-bit, meaning mantissa is actually 4-bit value.

typedef enum { Normal, Denormal, Inf, NaN } FP8State deriving (Bits, Eq);

typedef struct {
    FP8State state;
    Bit#(1) sign;
    Bit#(4) exponent;
    Bit#(5) mantissa;  // adding two 4-bit mantissa values can yield at most 5-bit.
} FP8AdderOperand deriving (Bits, Eq);

typedef struct {
    FP8AdderOperand a;
    FP8AdderOperand b;
} FP8AdderOperands deriving (Bits, Eq);


typedef struct {
    FP8State state;
    Bit#(1) sign;
    Bit#(5) exponent;  // adding two 4-bit exponent values can yield at most 5-bit.
    Bit#(8) mantissa;  // multiplying two 4-bit mantissa values can yield at most 8-bit.
} FP8MultiplierOperand deriving (Bits, Eq);

typedef struct {
    FP8MultiplierOperand a;
    FP8MultiplierOperand b;
} FP8MultiplierOperands deriving (Bits, Eq);