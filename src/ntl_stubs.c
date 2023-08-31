#include <stdio.h>
#include <string.h>

extern "C" {
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
}

#include <NTL/ZZ.h>
#include <NTL/ZZX.h>
#include <NTL/ZZXFactoring.h>
#include <NTL/mat_ZZ.h>
#include <NTL/mat_poly_ZZ.h>
#include <NTL/pair_ZZX_long.h>

using namespace NTL;

#define ZZX_val(v) (*((ZZX**)Data_custom_val(v)))
#define ZZ_val(v) (*((ZZ**)Data_custom_val(v)))

void _delete_zzx(value v) {
    delete ZZX_val(v);
}

struct custom_operations zzx = {
    .identifier = NULL,
    .finalize = _delete_zzx,
    .compare = NULL,
    .hash = NULL,
    .serialize = NULL
};

void _delete_zz(value v) {
    delete ZZ_val(v);
}

struct custom_operations zz = {
    .identifier = NULL,
    .finalize = _delete_zz,
    .compare = NULL,
    .hash = NULL,
    .serialize = NULL
};

void _make_ZZX(value* vptr, ZZX* x) {
    *vptr = caml_alloc_custom(&zzx, sizeof(ZZX*), 0, 1);
    ZZX_val(*vptr) = x;
}

void _make_ZZ(value* vptr, ZZ* x) {
    *vptr = caml_alloc_custom(&zz, sizeof(ZZ*), 0, 1);
    ZZ_val(*vptr) = x;
}

static inline value pair(value a, value b) {
  CAMLparam2(a, b);
  CAMLlocal1(pair);

  pair = caml_alloc(2, 0);

  Store_field(pair, 0, a);
  Store_field(pair, 1, b);

  CAMLreturn(pair);
}

static inline value cons(value hd, value tl) {
  CAMLparam2(hd, tl);
  CAMLreturn(pair(hd, tl));
}

static inline size_t length (value l) {
  size_t len = 0;
  while (l != Val_emptylist) { len++ ; l = Field(l, 1); }
  return len;
}

extern "C" {

    /* ZZ ********************************************************************/
    value zz_equal (value x, value y) {
	CAMLparam2(x, y);
	CAMLreturn(Val_bool(*ZZ_val(x) == *ZZ_val(y)));
    }

    value zz_compare (value x, value y) {
	CAMLparam2(x, y);
	CAMLreturn(Val_int(compare(*ZZ_val(x), *ZZ_val(y))));
    }

    value zz_of_bytes (value bytes, value len) {
	CAMLparam2(bytes,len);
	CAMLlocal1(r);
	ZZ *c = new ZZ();
	ZZFromBytes(*c,
		    reinterpret_cast<const unsigned char *>(String_val(bytes)),
		    Int_val(len));
	_make_ZZ(&r, c);
	CAMLreturn(r);
    }

    value bytes_of_zz (value zz) {
	CAMLparam1(zz);
	CAMLlocal1(r);
	ZZ *c = ZZ_val(zz);
	long n = c->size()*(NTL_ZZ_NBITS/8);
	char * bytes = (char*) malloc(n);
	r = caml_alloc_string(n);
	BytesFromZZ((unsigned char *) r, *c, n);
	free(bytes);
	CAMLreturn(pair(r, Val_int(n)));
    }

    value zz_negate (value zz) {
	CAMLparam1(zz);
	CAMLlocal1(r);
	ZZ *c = new ZZ(-*ZZ_val(zz));
	_make_ZZ(&r, c);
	CAMLreturn(r);
    }

    value zz_sign (value zz) {
	CAMLparam1(zz);
	CAMLreturn(Val_int(sign(*ZZ_val(zz))));
    }

    value zz_add (value x, value y) {
	CAMLparam2(x, y);
	CAMLlocal1(r);
	ZZ *z = new ZZ(*ZZ_val(x) + *ZZ_val(y));
	_make_ZZ(&r, z);
	CAMLreturn(r);
    }

    value zz_sub (value x, value y) {
	CAMLparam2(x, y);
	CAMLlocal1(r);
	ZZ *z = new ZZ(*ZZ_val(x) - *ZZ_val(y));
	_make_ZZ(&r, z);
	CAMLreturn(r);
    }

    value zz_mul (value x, value y) {
	CAMLparam2(x, y);
	CAMLlocal1(r);
	ZZ *z = new ZZ(*ZZ_val(x) * *ZZ_val(y));
	_make_ZZ(&r, z);
	CAMLreturn(r);
    }

    /* ZZX *******************************************************************/
    value zzx_equal (value p, value q) {
	CAMLparam2(p, q);
	CAMLreturn(Val_bool(*ZZX_val(p) == *ZZX_val(q)));
    }

    value zzx_zero () {
	CAMLparam0();
	CAMLlocal1(p);
	ZZX *q = new ZZX();
	_make_ZZX(&p, q);
	CAMLreturn(p);
    }

    void zzx_set_coeff (value polynomial, value position, value coeff) {
	CAMLparam3(polynomial, position, coeff);
	SetCoeff(*ZZX_val(polynomial), Int_val(position), *ZZ_val(coeff));
	CAMLreturn0;
    }

    value zzx_get_coeff (value polynomial, value position) {
	CAMLparam2(polynomial, position);
	CAMLlocal1(r);
	ZZ *c = new ZZ(coeff(*ZZX_val(polynomial), Int_val(position)));
	_make_ZZ(&r, c);
	CAMLreturn(r);
    }

    value zzx_degree (value polynomial) {
	CAMLparam1(polynomial);
	CAMLreturn(Val_int(deg(*ZZX_val(polynomial))));
    }

    value zzx_add (value p, value q) {
	CAMLparam2(p, q);
	CAMLlocal1(r);
	ZZX *s = new ZZX(*ZZX_val(p) + *ZZX_val(q));
	_make_ZZX(&r, s);
	CAMLreturn(r);
    }

    value zzx_mul (value p, value q) {
	CAMLparam2(p, q);
	CAMLlocal1(r);
	ZZX *s = new ZZX(*ZZX_val(p) * *ZZX_val(q));
	_make_ZZX(&r, s);
	CAMLreturn(r);
    }

    value zzx_factor (value polynomial) {
	CAMLparam1(polynomial);
	CAMLlocal3(q, content, factor_list);
	ZZ *c = new ZZ();
	Vec<pair_ZZX_long> factors;
	factor(*c, factors, *ZZX_val(polynomial));
	factor_list = Val_emptylist;
	for(int i = factors.length() - 1; i >= 0; i--) {
	    _make_ZZX(&q, new ZZX(factors[i].a));
	    factor_list = cons(pair(q,Val_int(factors[i].b)), factor_list);
	}
	_make_ZZ(&content, c);
	CAMLreturn(pair(content, factor_list));
    }

    /* ZZMatrix **************************************************************/
    value charpoly (value matrix, value n) {
	CAMLparam2(matrix, n);
	CAMLlocal1(r);
	ZZX *p = new ZZX();
	mat_ZZ M;
	int dim = Int_val(n);
	M.SetDims(dim, dim);
	for (int i = 0; i < dim; i++) {
	    for (int j = 0; j < dim; j++) {
		M.put(i, j, *ZZ_val(Field(Field(matrix, i), j)));
	    }
	}
	CharPoly(*p, M, 1);
	_make_ZZX(&r, p);
	CAMLreturn(r);
    }
}
