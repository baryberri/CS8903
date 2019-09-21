# Fixed Point Examples
This is to show Fixed-Point operations in Bluespec.
- Fixed-Point Addition
- Fixed-Point Subtraction
- Fixed-Point Multiplication
- Printing Fixed-Point using `fxptWrite()` function

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
You can configure this example by editing the `src/Configuration.bsv` file.
```c
// A Fixed-Point number uses 16 bits in total.
typedef 8 IntegerBit;  // Integer uses 8 bits
typedef 8 FractionBit;  // Fraction uses 8 bits
```
