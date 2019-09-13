// Systolic Array Settings
typedef 2 SystolicArrayWidth;  // Number of CNN filters
typedef 4 SystolicArrayHeight; // CNN filter size e.g., if filter is 2x2, then 4


// Internal Data Types
typedef enum { Idle, LoadWeight, Compute, Clear } PE_State deriving (Bits, Eq);
typedef Bit#(32) Data;
