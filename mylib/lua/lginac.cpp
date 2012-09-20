/*
* lginac.c
* Vinicius Mello <vinicius.mello@ufba.br>
* 03 Fev 2012 
* This code is hereby placed in the public domain.
*/

#include <iostream>
#include <sstream>
#include <cmath>
#include <map>
#include <vector>
#include <ginac/ginac.h>
using namespace std;
using namespace GiNaC;
extern "C" {
#include "lua.h"
#include "lauxlib.h"
}
#include <wrappers/array.hpp>


bool is_integer(double k)
{
  return floor(k) == k;
}

#define MYNAME		"ginac"
#define MYVERSION	MYNAME " library for " LUA_VERSION " / Fev 2011 / "\
			"using ginac 1.6.2"
#define EXTYPE		"ex " MYNAME 

exhashmap<symbol> exsymtbl;
map<string,ex> symtbl;
vector<FUNCP_1P> func1;
vector<FUNCP_CUBA> funcn;

static ex * Bnew(lua_State *L)
{
 ex * x= new (lua_newuserdata(L, sizeof(ex))) ex();
 luaL_getmetatable(L,EXTYPE);
 lua_setmetatable(L,-2);
 return x;
}

static ex * Bget(lua_State *L, int i) {
 switch (lua_type(L,i))
 {
  case LUA_TNUMBER:
  {
   ex * x=Bnew(L);
   double d=lua_tonumber(L,i);
   if(is_integer(d)) {
     *x=(int)floor(d);
   } else {
     *x=d;
   }
   lua_replace(L,i);
   return x;
  }
  default:
   return ((ex*)luaL_checkudata(L,i,EXTYPE));
 }
}

static int compile_callback1(lua_State *L) {
  int id = (int)lua_tonumber(L, lua_upvalueindex(1));
  double x=lua_tonumber(L,1);
  lua_pushnumber(L,func1[id](x));
  return 1; 
}		

typedef struct {
  void *type;
  int     own;  
  void        *ptr;
} swig_lua_userdata;

static int compile_callbackn(lua_State *L) {
  int id = (int)lua_tonumber(L, lua_upvalueindex(1));
  swig_lua_userdata * usr=(swig_lua_userdata *)lua_touserdata(L,1);
  array<double> * a=(array<double> *)usr->ptr;
  int n=a->size();
  int m=1;
  double r;
  funcn[id](&n,a->data(),&m,&r);
  lua_pushnumber(L,r);
  return 1; 
}		

static int compile_callbacknm(lua_State *L) {
  int id = (int)lua_tonumber(L, lua_upvalueindex(1));
  swig_lua_userdata * usra=(swig_lua_userdata *)lua_touserdata(L,1);
  array<double> * a=(array<double> *)usra->ptr;
  swig_lua_userdata * usrb=(swig_lua_userdata *)lua_touserdata(L,2);
  array<double> * b=(array<double> *)usrb->ptr;
  int n=a->size();
  int m=b->size();
  funcn[id](&n,a->data(),&m,b->data());
  return 0; 
}		


static int Bdigits(lua_State *L)		/** digits([n]) */
{
 lua_pushinteger(L,(int)((long)Digits));
 Digits=(long)luaL_optint(L,1,(int)((long)Digits));
 return 1;
}

#define EX_FUNC(FUNC) \
static int B ## FUNC(lua_State *L)	\
{\
 ex * a=Bget(L,1);\
 ex * c=Bnew(L);\
 *c=FUNC(*a);\
 return 1;\
}

EX_FUNC(abs)
EX_FUNC(step)
EX_FUNC(csgn)
EX_FUNC(conjugate)
EX_FUNC(real_part)
EX_FUNC(imag_part)
EX_FUNC(sqrt)
EX_FUNC(sin)
EX_FUNC(cos)
EX_FUNC(tan)
EX_FUNC(asin)
EX_FUNC(acos)
EX_FUNC(atan)
EX_FUNC(sinh)
EX_FUNC(cosh)
EX_FUNC(tanh)
EX_FUNC(asinh)
EX_FUNC(acosh)
EX_FUNC(atanh)
EX_FUNC(exp)
EX_FUNC(log)
EX_FUNC(Li2)
EX_FUNC(zeta)
EX_FUNC(tgamma)
EX_FUNC(lgamma)
EX_FUNC(psi)
EX_FUNC(factorial)
EX_FUNC(Order)
EX_FUNC(eval)
EX_FUNC(evalf)
EX_FUNC(expand)

#undef EX_FUNC

#define EX_FUNC2(FUNC) \
static int B ## FUNC(lua_State *L)\
{\
 ex * a=Bget(L,1);\
 ex * b=Bget(L,2);\
 ex * c=Bnew(L);\
 *c=FUNC(*a,*b);\
 return 1;\
}

EX_FUNC2(atan2)

#undef EX_FUNC2

#define NUMERIC_FUNC(FUNC) \
static int B ## FUNC(lua_State *L)\
{\
 ex * a=Bget(L,1);\
 ex * c=Bnew(L);\
 *c=FUNC(ex_to<numeric>(*a));\
 return 1;\
}

NUMERIC_FUNC(real)
NUMERIC_FUNC(imag)
NUMERIC_FUNC(numer)
NUMERIC_FUNC(denom)
NUMERIC_FUNC(isqrt)
NUMERIC_FUNC(bernoulli)
NUMERIC_FUNC(fibonacci)

#undef NUMERIC_FUNC

#define NUMERIC_FUNC2(FUNC) \
static int B ## FUNC(lua_State *L)\
{\
 ex * a=Bget(L,1);\
 ex * b=Bget(L,2);\
 ex * c=Bnew(L);\
 *c=FUNC(ex_to<numeric>(*a), ex_to<numeric>(*b));\
 return 1;\
}

NUMERIC_FUNC2(binomial)
NUMERIC_FUNC2(mod)
NUMERIC_FUNC2(smod)
NUMERIC_FUNC2(irem)
NUMERIC_FUNC2(iquo)
NUMERIC_FUNC2(gcd)
NUMERIC_FUNC2(lcm)

#undef NUMERIC_FUNC2

static int Bneg(lua_State *L)			// neg(x) 
{
 ex * a=Bget(L,1);
 ex * c=Bnew(L);
 *c=-(*a);
 return 1;
}

static int Bnumeric(lua_State *L)			// numeric(x) 
{
 numeric n(lua_tostring(L,1));
 ex * c=Bnew(L);
 *c=n;
 return 1;
}

static void substable(lua_State *L, int i, exmap& m) {
 lua_pushnil(L);  /* first key */
 while (lua_next(L, i) != 0) {
   /* uses 'key' (at index -2) and 'value' (at index -1) */
   string str(lua_tostring(L,-2));
   m[symtbl[str]]=*(Bget(L,lua_gettop(L)));
   /* removes 'value'; keeps 'key' for next iteration */
   lua_pop(L, 1);
 }
}

static void lsttable(lua_State *L, int i, lst& l) {
  int len=lua_objlen(L,i);
  for(int j=1;j<=len;++j) {
    lua_pushinteger(L,j);
    lua_gettable(L,i);
    l.append(*(Bget(L,lua_gettop(L))));
    lua_pop(L, 1);
  }
}

static void lstlsttable(lua_State *L, int i, lst& l) {
  int len=lua_objlen(L,i);
  for(int j=1;j<=len;++j) {
    lst li;
    lua_pushinteger(L,j);
    lua_gettable(L,i);
    lsttable(L,lua_gettop(L),li);
    l.append(li);
    lua_pop(L, 1);
  }
}

int Bcompile(lua_State *L) {
  if(lua_istable(L,1)) {
    lst le;
    lst l;
    lsttable(L,1,le);
    lsttable(L,2,l);
    FUNCP_CUBA f;
    funcn.push_back(f);
    int id=funcn.size()-1;
    compile_ex(le,l,funcn[id]);
    lua_pushnumber(L, id);
    lua_pushcclosure(L, &compile_callbacknm, 1);
  } else if(lua_istable(L,2)) {
    ex * e=Bget(L,1);
    lst le(*e);
    lst l;
    lsttable(L,2,l);
    FUNCP_CUBA f;
    funcn.push_back(f);
    int id=funcn.size()-1;
    compile_ex(le,l,funcn[id]);
    lua_pushnumber(L, id);
    lua_pushcclosure(L, &compile_callbackn, 1);
  } else {
    ex * e=Bget(L,1);
    ex * s=Bget(L,2);
    FUNCP_1P f;
    func1.push_back(f);
    int id=func1.size()-1;
    compile_ex(*e,exsymtbl[*s],func1[id]);
    lua_pushnumber(L, id);
    lua_pushcclosure(L, &compile_callback1, 1);
  }
  return 1;
}

static int Blst(lua_State *L)
{
 lst l;
 lsttable(L,1,l);
 ex * c=Bnew(L);
 *c = l; 
 return 1;
}

static int Blsolve(lua_State *L)
{
 lst eqs;
 lst vars;
 lsttable(L,1,eqs);
 lsttable(L,2,vars);
 ex * c=Bnew(L);
 *c = lsolve(eqs,vars); 
 return 1;
}

static int Bmatrix(lua_State *L)
{
 lst l;
 lstlsttable(L,1,l);
 ex * c=Bnew(L);
 *c = lst_to_matrix(l); 
 return 1;
}

#define MATRIX_FUNC(FUNC) \
static int B ## FUNC (lua_State *L) \
{\
 ex * a=Bget(L,1);\
 ex * c=Bnew(L);\
 *c = FUNC(ex_to<matrix>(*a)); \
 return 1;\
}

MATRIX_FUNC(determinant)
MATRIX_FUNC(trace)
MATRIX_FUNC(rank)

#undef MATRIX_FUNC 

static int Bsubs(lua_State *L)			// subs(x) 
{
 ex * a=Bget(L,1);
 if(lua_istable(L,2)) {
   exmap m;
   substable(L,2,m);
   ex * c=Bnew(L);
   *c=a->subs(m);
 } else {
   ex * b=Bget(L,2);
   ex * c=Bnew(L);
   *c=a->subs(*b);
 }
 return 1;
}

static int Bsymbol(lua_State *L)			// symbol(x) 
{
  string str;
  if(lua_gettop(L)==0) {
    symbol s;   
    ex a=s;
    str=s.get_name();
    symtbl[str]=a;
    exsymtbl[a]=s;
  } else {
    const char * name=lua_tostring(L,1);
    str=name;
    if(symtbl.count(str)==0) {
      if(lua_gettop(L)==2) {
        const char * tex=lua_tostring(L,2);
        symbol s(name,tex);   
        ex a=s;
        symtbl[str]=a;
        exsymtbl[a]=s;
      } else {
        symbol s(name);   
        ex a=s;
        symtbl[str]=a;
        exsymtbl[a]=s;
      }
    }
  }
  ex * c=Bnew(L);
  *c=symtbl[str];
  return 1;
}

static int Bintegral(lua_State *L)
{
 ex * x=Bget(L,1);
 ex * a=Bget(L,2);
 ex * b=Bget(L,3);
 ex * f=Bget(L,4);
 ex * c=Bnew(L);
 *c=integral(*x,*a,*b,*f);
 return 1;
}

static int Bdiff(lua_State *L)			// diff(x) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=a->diff(exsymtbl[*b]);
 return 1;
}

static int Bprint(lua_State *L)			// print(x) 
{
 ex * a=Bget(L,1);
 cout<<(*a)<<endl;
 return 0;
}

static int Btostring(lua_State *L)			// tostring(x) 
{
 ex * a=Bget(L,1);
 ostringstream o;
 o<<(*a);
 lua_pushstring(L,o.str().c_str());
 return 1;
}

static int Btolatex(lua_State *L)			// tolatex(x) 
{
 ex * a=Bget(L,1);
 ostringstream o;
 o<<latex<<(*a);
 lua_pushstring(L,o.str().c_str());
 return 1;
}

static int Btonumber(lua_State *L)			// tonumber(x) 
{
 ex * a=Bget(L,1);
 lua_pushnumber(L,ex_to<numeric>(*a).to_double());
 return 1;
}


static int Badd(lua_State *L)			// add(x,y) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)+(*b);
 return 1;
}

static int Bsub(lua_State *L)			// sub(x,y) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)-(*b);
 return 1;
}

static int Bmul(lua_State *L)			// mul(x,y) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)*(*b);
 return 1;
}

static int Bdiv(lua_State *L)			// div(x,y) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)/(*b);
 return 1;
}

static int Bpow(lua_State *L)			// pow(x,y) 
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=pow((*a),(*b));
 return 1;
}

static int Beq(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 lua_pushboolean(L,static_cast<bool>((*a)==(*b)));
 return 1;
}

static int Blt(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 lua_pushboolean(L,static_cast<bool>((*a)<(*b)));
 return 1;
}

static int Ble(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 lua_pushboolean(L,static_cast<bool>((*a)<=(*b)));
 return 1;
}

static int Beqf(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)==(*b);
 return 1;
}

static int Bltf(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)<(*b);
 return 1;
}

static int Blef(lua_State *L)
{
 ex * a=Bget(L,1);
 ex * b=Bget(L,2);
 ex * c=Bnew(L);
 *c=(*a)<=(*b);
 return 1;
}

#define NUMERIC_TEST(TEST) \
static int B ## TEST (lua_State *L)\
{\
 ex * a=Bget(L,1);\
 lua_pushboolean(L, TEST  (ex_to<numeric>(*a)));\
 return 1;\
}

NUMERIC_TEST(is_zero)
NUMERIC_TEST(is_positive)
NUMERIC_TEST(is_negative)
NUMERIC_TEST(is_integer)
NUMERIC_TEST(is_pos_integer)
NUMERIC_TEST(is_nonneg_integer)
NUMERIC_TEST(is_even)
NUMERIC_TEST(is_odd)
NUMERIC_TEST(is_prime)
NUMERIC_TEST(is_rational)
NUMERIC_TEST(is_real)
NUMERIC_TEST(is_cinteger)
NUMERIC_TEST(is_crational)

#undef NUMERIC_TEST

static int Bgc(lua_State *L)
{
 ex * x=Bget(L,1);
 x->~ex();
 lua_pushnil(L);
 lua_setmetatable(L,1);
 return 0;
}

#define REG_ENTRY(FUNC) { #FUNC, B ## FUNC },
static const luaL_Reg R[] =
{
	{ "__add",	Badd	},		/** __add(x,y) */
	{ "__div",	Bdiv	},		/** __div(x,y) */
	{ "__eq",	Beq	},		/** __eq(x,y) */
	{ "__gc",	Bgc	},
	{ "__lt",	Blt	},		/** __lt(x,y) */
	{ "__le",	Ble	},		/** __le(x,y) */
	{ "__mul",	Bmul	},		/** __mul(x,y) */
	{ "__pow",	Bpow	},		/** __pow(x,y) */
	{ "__sub",	Bsub	},		/** __sub(x,y) */
	{ "__tostring",	Btostring},		/** __tostring(x) */
	{ "__unm",	Bneg	},		/** __unm(x) */
	{ "lt",	Bltf	},
	{ "le",	Blef	},
	{ "eq",	Beqf	},
  REG_ENTRY(tolatex)
  REG_ENTRY(tonumber)
  REG_ENTRY(numeric)
  REG_ENTRY(digits)
  REG_ENTRY(symbol)
  REG_ENTRY(subs)
  REG_ENTRY(diff)
  REG_ENTRY(print)
  REG_ENTRY(compile)

  REG_ENTRY(abs)
  REG_ENTRY(step)
  REG_ENTRY(csgn)
  REG_ENTRY(conjugate)
  REG_ENTRY(real_part)
  REG_ENTRY(imag_part)
  REG_ENTRY(sqrt)
  REG_ENTRY(sin)
  REG_ENTRY(cos)
  REG_ENTRY(tan)
  REG_ENTRY(asin)
  REG_ENTRY(acos)
  REG_ENTRY(atan)
  REG_ENTRY(sinh)
  REG_ENTRY(cosh)
  REG_ENTRY(tanh)
  REG_ENTRY(asinh)
  REG_ENTRY(acosh)
  REG_ENTRY(atanh)
  REG_ENTRY(exp)
  REG_ENTRY(log)
  REG_ENTRY(Li2)
  REG_ENTRY(zeta)
  REG_ENTRY(tgamma)
  REG_ENTRY(lgamma)
  REG_ENTRY(psi)
  REG_ENTRY(factorial)
  REG_ENTRY(Order)
  REG_ENTRY(eval)
  REG_ENTRY(evalf)
  REG_ENTRY(expand)
  REG_ENTRY(integral)
  REG_ENTRY(matrix)
  REG_ENTRY(lst)
  REG_ENTRY(lsolve)
  REG_ENTRY(determinant)
  REG_ENTRY(trace)
  REG_ENTRY(rank)

  REG_ENTRY(atan2)

  REG_ENTRY(real)
  REG_ENTRY(imag)
  REG_ENTRY(numer)
  REG_ENTRY(denom)
  REG_ENTRY(isqrt)
  REG_ENTRY(bernoulli)
  REG_ENTRY(fibonacci)

  REG_ENTRY(binomial)
  REG_ENTRY(mod)
  REG_ENTRY(smod)
  REG_ENTRY(irem)
  REG_ENTRY(iquo)
  REG_ENTRY(gcd)
  REG_ENTRY(lcm)

  REG_ENTRY(is_zero)
  REG_ENTRY(is_positive)
  REG_ENTRY(is_negative)
  REG_ENTRY(is_integer)
  REG_ENTRY(is_pos_integer)
  REG_ENTRY(is_nonneg_integer)
  REG_ENTRY(is_even)
  REG_ENTRY(is_odd)
  REG_ENTRY(is_prime)
  REG_ENTRY(is_rational)
  REG_ENTRY(is_real)
  REG_ENTRY(is_cinteger)
  REG_ENTRY(is_crational)
	{ NULL,		NULL	}
};

#undef REG_ENTRY

extern "C"
int luaopen_ginac(lua_State *L)
{
 luaL_newmetatable(L,EXTYPE);
 lua_setglobal(L,MYNAME);
 luaL_register(L,MYNAME,R);
 lua_pushliteral(L,"version");		
 lua_pushliteral(L,MYVERSION);
 lua_settable(L,-3);
 lua_pushliteral(L,"__index");
 lua_pushvalue(L,-2);
 lua_settable(L,-3);
 ex * e;
 lua_pushliteral(L,"Pi");
 e=Bnew(L);
 *e=Pi;
 lua_settable(L,-3);

 lua_pushliteral(L,"Catalan");
 e=Bnew(L);
 *e=Catalan;
 lua_settable(L,-3);

 lua_pushliteral(L,"Euler");
 e=Bnew(L);
 *e=Euler;
 lua_settable(L,-3);

 lua_pushliteral(L,"I");
 e=Bnew(L);
 *e=I;
 lua_settable(L,-3);

 lua_pushliteral(L,"_0");
 e=Bnew(L);
 *e=wild(0);
 lua_settable(L,-3);

 lua_pushliteral(L,"_1");
 e=Bnew(L);
 *e=wild(1);
 lua_settable(L,-3);

 lua_pushliteral(L,"_2");
 e=Bnew(L);
 *e=wild(1);
 lua_settable(L,-3);

 lua_pushliteral(L,"_3");
 e=Bnew(L);
 *e=wild(1);
 lua_settable(L,-3);

 lua_pushliteral(L,"_4");
 e=Bnew(L);
 *e=wild(1);
 lua_settable(L,-3);

 return 1;
}
