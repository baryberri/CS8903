/*** BFloat16 16-bit floating point: 1-bit Sign, 8-bit Exponent, 7-bit Mantissa ***/
typedef Bit#(16) BFloat16;  // Explicit mantissa is 7-bit, meaning mantissa is actually 8-bit value.

typedef enum { Normal, Denormal, Inf, NaN } BFloat16State deriving (Bits, Eq);

typedef struct {
    BFloat16State state;
    Bit#(1) sign;
    Bit#(8) exponent;
    Bit#(9) mantissa;  // adding two 8-bit mantissa values can yield at most 9-bit.
} BFloat16AdderOperand deriving (Bits, Eq);

typedef struct {
    BFloat16AdderOperand a;
    BFloat16AdderOperand b;
} BFloat16AdderOperands deriving (Bits, Eq);


typedef struct {
    BFloat16State state;
    Bit#(1) sign;
    Bit#(9) exponent;  // adding two 8-bit exponent values can yield at most 9-bit.
    Bit#(16) mantissa;  // multiplying two 8-bit mantissa values can yield at most 16-bit.
} BFloat16MultiplierOperand deriving (Bits, Eq);

typedef struct {
    BFloat16MultiplierOperand a;
    BFloat16MultiplierOperand b;
} BFloat16MultiplierOperands deriving (Bits, Eq);
