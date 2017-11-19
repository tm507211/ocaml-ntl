# ocaml-ntl
OCaml bindings to [NTL](http://www.shoup.net/ntl/): a Number Theory Library.

Currently, ocaml-ntl provides bindings to a minimal set of routines to support
factorization of integer polynomials (`ZZX.factor`) and computation of
characteristic polynomials (`charpoly`).

# Installing

ocaml-ntl requires an installation of [NTL](http://www.shoup.net/ntl/) and
[GMP](https://gmplib.org/).  On Ubuntu, this can be done with:
```
 sudo apt-get install libntl-dev libgmp-dev libmpfr-dev
```

## Installing from OPAM

opam-ntl is available in the [sv-opam](https://github.com/zkincaid/sv-opam) OPAM repository.  It can be installed as follows:
```
 opam remote add sv git://github.com/zkincaid/sv-opam.git
 opam install ntl
```


## Installing from source

ocaml-ntl also require OCaml bindings for GMP.  The easiest way to install is
via opam:
```
 opam install mlgmpidl
```

After installing ocaml-ntl's dependencies, it can be built with `make` and
installed with `make install`.  Unit tests can be executed with `test.native`.
