import Configuration::*;
import FixedPoint::*;


// Internal Data Types
typedef enum { Idle, LoadWeight, Compute, Clear } PE_State deriving (Bits, Eq);
typedef FixedPoint#(IntegerBits, FractionBits) Data;
