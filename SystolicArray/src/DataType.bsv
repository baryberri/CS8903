// Systolic Array Settings
typedef 2 CNNFiltersCount;     // Number of CNN filters
typedef 2 CNNFilterSize;       // CNN filter's size - meaning filter is 2x2
typedef 4 CNNInputSize;        // CNN input size - meaning input is 4x4


// Internal Data Types
typedef enum { Idle, LoadWeight, Compute, Clear } PE_State deriving (Bits, Eq);
typedef Bit#(32) Data;

typedef CNNFiltersCount SystolicArrayWidth;  // Number of CNN filters
typedef TMul#(CNNFilterSize, CNNFilterSize) SystolicArrayHeight; // CNN filter size e.g., if filter is 2x2, then 4
typedef TAdd#(TSub#(CNNInputSize, CNNFilterSize), 1) CNNOutputSize;    // CNN's output size
typedef TMul#(CNNOutputSize, CNNOutputSize) InputLength;    // input stream's length