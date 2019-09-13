typedef enum { Idle, LoadWeight, Compute, Clear } PE_State deriving (Bits, Eq);

typedef Bit#(32) Data;
