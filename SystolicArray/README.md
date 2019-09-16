# Systolic Array
This is a Square N x N Systolic Array implementation that runs CNN inference.

## How to Use
Use `Makefile` to run simulation or compile into verilog.

- Running Simulation
```bash
$ make
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
```
