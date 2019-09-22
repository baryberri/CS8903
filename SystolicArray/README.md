# Systolic Array
This is a Square N x N Systolic Array implementation that runs CNN inference.
This Systolic Array leverages Fixed-Point MAC in each PE.

## How to Use
Use `Makefile` to run simulation or compile into verilog.

- Running Simulation
```bash
$ make
```

- Running Simulation, with printing generated activations
```bash
$ make testprint
```

- Compiling into Verilog (Results will be stored at `./build/verilog`.)
```bash
$ make verilog
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
