(lang dune 2.0)
(name ntl)
(source (github zkincaid/ocaml-ntl))

(generate_opam_files true)

(package
 (name ntl)
 (synopsis "Number Theory Library")
 (description "Bindings for Number Theory Library: https://libntl.org/")
 (depends
  (dune (>= 2.0))
  (ocaml (>= 4.10))
  mlgmpidl
  conf-ntl
  (ounit :with-test)))
