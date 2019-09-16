# Systolic Array
This is a Systolic Array implementation that runs CNN inference.

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

## Data Type Definition
Data type is defined in `src/DataType.bsv` file.
```c
// Number of CNN's filter.
typedef 2 CNNFiltersCount;

// - This implementation assumes that filter and input activation are square.

// CNN filter's width, e.g., this means CNN filter is 2x2. 
typedef 2 CNNFilterSize;

// CNN's input activation width, e.g., this means CNN's input activation is 4x4.
typedef 4 CNNInputSize;
```