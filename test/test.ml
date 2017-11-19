open Ntl
open OUnit

let k z = Mpz.of_int z
let zz z = ZZ.of_mpz (Mpz.of_int z)

let mk_show pp x =
  let b = Buffer.create 16 in
  let formatter = Format.formatter_of_buffer b in
  Format.fprintf formatter "@[<hov 0>%a@]@?" pp x;
  Buffer.sub b 0 (Buffer.length b)

let assert_equal_mpz x y = assert_equal ~printer:Mpz.to_string x y

let assert_equal_zz x y =
  assert_equal ~printer:(mk_show ZZ.pp) ~cmp:ZZ.equal x y

let assert_equal_zzx x y =
  assert_equal ~printer:(mk_show ZZX.pp) ~cmp:ZZX.equal x y

let zz_roundtrip () =
  assert_equal_mpz (k 1) (ZZ.mpz_of (ZZ.of_mpz (k 1)));
  assert_equal_mpz (k 42) (ZZ.mpz_of (ZZ.of_mpz (k 42)));
  assert_equal_mpz (k (-13)) (ZZ.mpz_of (ZZ.of_mpz (k (-13))));
  assert_equal_mpz (k 255) (ZZ.mpz_of (ZZ.of_mpz (k 255)));
  assert_equal_mpz (k 256) (ZZ.mpz_of (ZZ.of_mpz (k 256)));
  assert_equal_mpz (k 257) (ZZ.mpz_of (ZZ.of_mpz (k 257)));
  let big =
    let big0 = Mpzf.mul (k 1000000000) (k 2147483647) in
    let big1 = Mpzf.mul big0 big0 in
    let big2 = Mpzf.mul big1 big1 in
    Mpzf.add (Mpzf.add big0 (Mpzf.add big1 big2)) (k 13)
  in
  let neg_big = Mpzf.neg big in
  assert_equal_mpz big (ZZ.mpz_of (ZZ.of_mpz big));
  assert_equal_mpz neg_big (ZZ.mpz_of (ZZ.of_mpz neg_big))

let zzx_roundtrip () =
  let p = ZZX.zero () in
  assert_equal_zzx p (ZZX.of_list []);
  ZZX.set_coeff p 0 (zz 1);
  assert_equal_zzx p (ZZX.of_list [(0, zz 1)]);
  ZZX.set_coeff p 1 (zz (-1));
  assert_equal_zzx p (ZZX.of_list [(0, zz 1); (1, zz (-1))]);
  ZZX.set_coeff p 10 (zz 5);
  assert_equal_zzx p (ZZX.of_list [(0, zz 1); (1, zz (-1)); (10, zz 5)]);
  ZZX.set_coeff p 1 (zz 0);
  assert_equal_zzx p (ZZX.of_list [(0, zz 1); (10, zz 5)])

let zzx_degree () =
  let p = ZZX.zero () in
  assert_equal (-1) (ZZX.degree p);
  ZZX.set_coeff p 0 (zz 1);
  assert_equal 0 (ZZX.degree p);
  ZZX.set_coeff p 4 (zz 1);
  assert_equal 4 (ZZX.degree p)


let rec mul_factors = function
  | [] -> ZZX.of_list [(0, ZZ.one)]
  | (p,n)::factors ->
    ZZX.mul (ZZX.pow p n) (mul_factors factors)
  
let zzx_factor () =
  let correct_factorization p =
    let (content, factors) = ZZX.factor p in
    assert_equal_zzx p (ZZX.mul (ZZX.of_list [(0, content)]) (mul_factors factors))
  in
  begin match ZZX.factor (ZZX.of_list [(2, zz 1); (0, zz (-1))]) with
    | (c, [(x, 1); (y, 1)]) ->
      assert_equal_zz c (zz 1);
      if ZZX.equal x (ZZX.of_list [(1, zz 1); (0, zz 1)]) then
        assert_equal_zzx (ZZX.of_list [(1, zz 1); (0, zz (-1))]) y
      else begin
        assert_equal_zzx (ZZX.of_list [(1, zz 1); (0, zz 1)]) y;
        assert_equal_zzx (ZZX.of_list [(1, zz 1); (0, zz (-1))]) x
      end
    | (_, xs) ->
      print_endline (string_of_int (List.length xs));
      assert false
  end;
  correct_factorization (ZZX.of_list [(4, zz 1); (0, zz (-2))]);
  correct_factorization (ZZX.of_list [(4, zz 1); (2, zz 1)]);
  correct_factorization (ZZX.of_list [(3, zz 2); (2, zz 4)]);
  correct_factorization (ZZX.of_list [(3, zz 6);
                                      (2, zz 14);
                                      (1, zz 10);
                                      (0, zz 2)])

let charpoly () =
  assert_equal_zzx
    (ZZX.of_list [(2,zz 1); (1, zz (-3)); (0, zz (-2))])
    (ZZMatrix.charpoly [| [| zz 0; zz 1 |];
                          [| zz 2; zz 3 |] |]);
  assert_equal_zzx
    (ZZX.of_list [(2,zz 1); (1, zz (-2)); (0, zz 1)])
    (ZZMatrix.charpoly [| [| zz 2; zz 1 |];
                          [| zz (-1); zz 0 |] |]);
  assert_equal_zzx
    (ZZX.of_list [(3,zz 1); (2, zz (-5)); (1, zz (-4)); (0, zz 15)])
    (ZZMatrix.charpoly [| [| zz 0; zz 1; zz 2 |];
                          [| zz (-1); zz 2; zz 1 |];
                          [| zz 4; zz 3; zz 3 |] |])


let suite = "Main" >::: [
    "zz_roundtrip" >:: zz_roundtrip;
    "zzx_roundtrip" >:: zzx_roundtrip;
    "zzx_degree" >:: zzx_degree;
    "zzx_factor" >:: zzx_factor;
    "charpoly" >:: charpoly;
  ]

let _ =
  Printexc.record_backtrace true;
  Printf.printf "Running test suite";
  ignore (run_test_tt_main suite)

