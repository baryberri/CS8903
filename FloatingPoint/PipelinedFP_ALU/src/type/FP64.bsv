/*** Double-precision: 1-bit Sign, 11-bit Exponent, 52-bit Mantissa ***/
typedef Bit#(64) FP64;  // Explicit mantissa is 52-bit, meaning mantissa is actually 53-bit value.

typedef enum { Normal, Denormal, Inf, NaN } FP64State deriving (Bits, Eq);

typedef struct {
    FP64State state;
    Bit#(1) sign;
    Bit#(11) exponent;
    Bit#(54) mantissa;  // adding two 53-bit mantissa values can yield at most 54-bit.
} FP64AdderOperand deriving (Bits, Eq);

typedef struct {
    FP64AdderOperand a;
    FP64AdderOperand b;
} FP64AdderOperands deriving (Bits, Eq);


typedef struct {
    FP64State state;
    Bit#(1) sign;
    Bit#(12) exponent;  // adding two 11-bit exponent values can yield at most 12-bit.
    Bit#(106) mantissa;  // multiplying two 53-bit mantissa values can yield at most 106-bit.
} FP64MultiplierOperand deriving (Bits, Eq);

typedef struct {
    FP64MultiplierOperand a;
    FP64MultiplierOperand b;
} FP64MultiplierOperands deriving (Bits, Eq);
