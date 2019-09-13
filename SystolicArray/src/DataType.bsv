typedef enum { Idle, LoadWeight, Compute} PE_State deriving (Bits, Eq);

typedef Bit#(32) Data;
