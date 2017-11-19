(** Multi-precision integers *)
type zz

(** Univariate polynomials with integer coefficients *)
type zzx

(** Multi-precision integers *)
module ZZ : sig
  val equal : zz -> zz -> bool
  val compare : zz -> zz -> int

  (** Pretty print *)
  val pp : Format.formatter -> zz -> unit

  val zero : zz
  val one : zz

  val add : zz -> zz -> zz
  val mul : zz -> zz -> zz

  val sub : zz -> zz -> zz
  val negate : zz -> zz

  (** Convert from NTL integer to GMP integer *)
  val mpz_of : zz -> Mpzf.t

  (** Convert from GMP integer to NTL integer *)
  val of_mpz : Mpzf.t -> zz
end

(** Univariate polynomials with integer coefficients *)
module ZZX : sig
  val equal : zzx -> zzx -> bool

  (** Pretty print *)
  val pp : Format.formatter -> zzx -> unit

  val zero : unit -> zzx

  (** Given a list n[(d1,c1),...,(dn,cn)], construct the polynomial
      [c1 * x^d1 + ... + cn * x^dn].
      If degrees are repeated, only the right-most occurrence is used. *)
  val of_list : (int * zz) list -> zzx

  (** Given a polynomial [c1 * x^d1 + ... + cn * x^dn], return the list
      [(d1,c1),...,(dn,cn)].  Zero coefficients are supressed. *)
  val list_of : zzx -> (int * zz) list

  val set_coeff : zzx -> int -> zz -> unit
  val get_coeff : zzx -> int -> zz

  val degree : zzx -> int

  val add : zzx -> zzx -> zzx
  val mul : zzx -> zzx -> zzx
  val pow : zzx -> int -> zzx

  (** Given a polynomial p, compute a factorization (c,[(q1,d1), ...,
      (qn,dn)]) such that (1) p = c * q1^d1 * ... * qn^dn, (2) c is the
      content of p (gcd of its coefficients) (3) each qi is irreducible over
      the integers *)
  val factor : zzx -> zz * ((zzx * int) list)
end

module ZZMatrix : sig
  (** Compute the characteristic polynomial of a square integer matrix. *)
  val charpoly : (zz array) array -> zzx
end
