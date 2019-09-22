# Systolic Array
This is a Square N x N Systolic Array implementation that runs CNN inference.
This Systolic Array leverages Fixed-Point MAC in each PE.

## How to Use
Use `./SystolicArray` to run simulation or compile into verilog.
```bash
$ ./SystolicArray  # Shows help message
```

## Configuration
You can configure this Systolic Array by editing the `src/Configuration.bsv` file.
```c
// Systolic Array Size; This Means 8x8 Systolic Array.
typedef 8 SystolicArraySize;

// Fixed-Point Numbers Quantization Factors
typedef 8 IntegerBits;  // 8 bits to represent Integer part
typedef 8 FractionBits; // 8 bits to represent Fraction part
```
