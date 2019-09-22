buildbase = ./build
bindir = $(buildbase)/bin
bdir = $(buildbase)/bdir
simdir = $(buildbase)/simdir
libpath=+:$(srcdir):$(srcdir)/lib
srcdir = ./src


test: compile_testbench_input_stationary
	$(bindir)/sim_input_stationary

testprint: compile_testbench_input_stationary_print_result
	$(bindir)/sim_input_stationary_print_result

compile_testbench_input_stationary_print_result: make_directories
	bsc -u -sim -aggressive-conditions -no-warn-action-shadowing -D PRINT_RESULT -bdir $(bdir) -simdir $(simdir) -p $(libpath) $(srcdir)/testbench/TestBenchInputStationary.bsv
	bsc -u -sim -e mkTestBenchInputStationary -o $(bindir)/sim_input_stationary_print_result -bdir $(bdir) -simdir $(simdir)

compile_testbench_input_stationary: make_directories
	bsc -u -sim -aggressive-conditions -no-warn-action-shadowing -bdir $(bdir) -simdir $(simdir) -p $(libpath) $(srcdir)/testbench/TestBenchInputStationary.bsv
	bsc -u -sim -e mkTestBenchInputStationary -o $(bindir)/sim_input_stationary -bdir $(bdir) -simdir $(simdir)

verilog: make_directories
	bsc -verilog -g mkSystolicArray -aggressive-conditions -no-warn-action-shadowing -bdir $(bdir) -simdir $(simdir) -p $(libpath) -u $(srcdir)/SystolicArray.bsv
	mkdir -p $(buildbase)/verilog
	mv $(srcdir)/*.v $(buildbase)/verilog

make_directories:
	mkdir -p $(bdir)
	mkdir -p $(bindir)
	mkdir -p $(simdir)

clean:
	rm -rf $(buildbase)

all: 

.PHONY: clean
.DEFAULT_GOAL := test
