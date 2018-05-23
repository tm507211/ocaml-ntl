type zz
type zzx

module ZZ = struct
  external equal : zz -> zz -> bool = "zz_equal"
  external compare : zz -> zz -> int = "zz_compare"

  external of_bytes : bytes -> int -> zz = "zz_of_bytes"
  external bytes_of : zz -> bytes * int = "bytes_of_zz"

  external add : zz -> zz -> zz = "zz_add"
  external sub : zz -> zz -> zz = "zz_sub"
  external mul : zz -> zz -> zz = "zz_mul"
  external negate : zz -> zz = "zz_negate"

  external sign : zz -> int = "zz_sign"

  let maxbyte = Mpzf._mpzf (Mpz.of_int 256)

  let mpz_of zz =
    let (neg, (bytes, len)) =
      if sign zz < 0 then
        (true, bytes_of (negate zz))
      else
        (false, bytes_of zz)
    in
    let mpz = Mpz.init () in
    for i = len -1 downto 0 do
      Mpz.mul mpz mpz maxbyte;
      Mpz.add mpz mpz (Mpz.of_int (Char.code (Bytes.get bytes i)))
    done;
    if neg then Mpz.neg mpz mpz;
    Mpzf._mpzf mpz

  let of_mpz mpz =
    let buf = Buffer.create 16 in
    let byte = Mpz.init () in
    let m = Mpz.init () in
    Mpz.abs m mpz;
    while Mpz.cmp m maxbyte >= 0 do
      Mpz.fdiv_r_2exp byte m 8;
      Buffer.add_char buf (Char.chr (Mpz.get_int byte));
      Mpz.fdiv_q_2exp m m 8;
    done;
    Buffer.add_char buf (Char.chr (Mpz.get_int m));
    let zz = of_bytes (Buffer.to_bytes buf) (Buffer.length buf) in
    if Mpz.sgn mpz < 0 then negate zz
    else zz

  let zero = of_mpz (Mpz.of_int 0)
  let one = of_mpz (Mpz.of_int 1)

  let pp formatter zz = Mpz.print formatter (mpz_of zz)
end

module ZZX = struct
  external zero : unit -> zzx = "zzx_zero"
  external set_coeff : zzx -> int -> zz -> unit = "zzx_set_coeff"
  external get_coeff : zzx -> int -> zz = "zzx_get_coeff"
  external equal : zzx -> zzx -> bool = "zzx_equal"
  external factor : zzx -> zz * ((zzx * int) list) = "zzx_factor"
  external degree : zzx -> int = "zzx_degree"
  external mul : zzx -> zzx -> zzx = "zzx_mul"
  external add : zzx -> zzx -> zzx = "zzx_add"

  let of_list xs =
    let p = zero () in
    List.iter (fun (i, coeff) -> set_coeff p i coeff) xs;
    p

  let list_of p =
    let rec go xs i =
      if i < 0 then
        xs
      else
        let coeff = get_coeff p i in
        if ZZ.equal coeff ZZ.zero then
          go xs (i - 1)
        else
          go ((i, coeff)::xs) (i - 1)
    in
    go [] (degree p)

  let pp formatter p =
    let open Format in
    let rec pp_list = function
      | [] -> pp_print_string formatter "0"
      | [(i,coeff)] ->
        fprintf formatter "%a*x^%d" ZZ.pp coeff i
      | (i,coeff)::xs ->
        fprintf formatter "%a*x^%d@ + " ZZ.pp coeff i;
        pp_list xs
    in
    pp_list (list_of p)

  let rec pow p n =
    if n = 0 then (of_list [(0, ZZ.one)])
    else if n = 1 then p
    else begin
      let q = pow p (n / 2) in
      let q_squared = mul q q in
      if n mod 2 = 0 then q_squared
      else mul q q_squared
    end
end

module ZZMatrix = struct
  external _charpoly : (zz array) array -> int -> zzx = "charpoly"
  let charpoly matrix =
    let d = Array.length matrix in
    if d == 0 then
      invalid_arg "charpoly: Matrix must have dimension > 0";
    for i = 0 to d - 1 do
      if (Array.length matrix.(i) != d) then
        invalid_arg "charpoly: Not a square matrix";
    done;
    _charpoly matrix (Array.length matrix)
end
