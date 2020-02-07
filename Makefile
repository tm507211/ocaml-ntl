.PHONY: test build clean uninstall install doc

all: build

build:
	dune build

clean:
	dune clean

test:
	dune runtest

uninstall:
	dune uninstall

install:
	dune install

doc:
	dune build @doc
