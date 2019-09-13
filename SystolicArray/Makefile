buildbase = ./build
bindir = $(buildbase)/bin
bdir = $(buildbase)/bdir
simdir = $(buildbase)/simdir
srcdir = ./src

test: compile
	$(bindir)/sim

compile: make_directories
	bsc -u -sim -aggressive-conditions -no-warn-action-shadowing -bdir $(bdir) -simdir $(simdir) -p +:$(srcdir):$(srcdir)/lib $(srcdir)/testbench/TestBench.bsv
	bsc -u -sim -e mkTestBench -o $(bindir)/sim -bdir $(bdir) -simdir $(simdir)

make_directories: clean
	mkdir -p $(bdir)
	mkdir -p $(bindir)
	mkdir -p $(simdir)

clean:
	rm -rf $(buildbase)

all: 

.PHONY: clean
.DEFAULT_GOAL := test
