/*
 * linterval.cpp
 * Vinicius Mello <vinicius.mello@ufba.br>
 * 03 Fev 2012
 * This code is hereby placed in the public domain.
 */

#include <boost/numeric/interval.hpp>
using namespace boost;
using namespace numeric;
using namespace interval_lib;

typedef interval<double, 
 policies<save_state<rounded_transc_exact<double> >, 
 checking_base<double> > > I;

extern "C" {
#include "lua.h"
#include "lauxlib.h"
}



#define MYNAME      "interval"
#define MYVERSION   MYNAME " library for " LUA_VERSION " / Fev 2014 / "\
    "using interval "
#define EXTYPE      "I " MYNAME

static I * Bnew(lua_State *L)
{
    I * x= new (lua_newuserdata(L, sizeof(I))) I();
    luaL_getmetatable(L,EXTYPE);
    lua_setmetatable(L,-2);
    return x;
}

static I * Bget(lua_State *L, int i) {
    switch (lua_type(L,i))
    {
        case LUA_TNUMBER:
            {
                I * x=Bnew(L);
                double d=lua_tonumber(L,i);
                *x=d;
                lua_replace(L,i);
                return x;
            }
        default:
            return ((I*)luaL_checkudata(L,i,EXTYPE));
    }
}

#define EX_FUNC(FUNC) \
    static int B ## FUNC(lua_State *L)  \
{\
    I * a=Bget(L,1);\
    I * c=Bnew(L);\
    *c=FUNC(*a);\
    return 1;\
}

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

#undef EX_FUNC

#define EX_FUNC2(FUNC) \
        static int B ## FUNC(lua_State *L)\
{\
    I * a=Bget(L,1);\
    I * b=Bget(L,2);\
    I * c=Bnew(L);\
    *c=FUNC(*a,*b);\
    return 1;\
}


#undef EX_FUNC2


static int Bneg(lua_State *L)           // neg(x)
{
    I * a=Bget(L,1);
    I * c=Bnew(L);
    *c=-(*a);
    return 1;
}


static int Btostring(lua_State *L)          // tostring(x)
{
    I * a=Bget(L,1);
    static char tmp[1024];
    sprintf(tmp,"[%g,%g]", a->lower(),a->upper());
    lua_pushstring(L,tmp);
    return 1;
}



static int Badd(lua_State *L)           // add(x,y)
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=(*a)+(*b);
    return 1;
}

static int Bsub(lua_State *L)           // sub(x,y)
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=(*a)-(*b);
    return 1;
}

static int Bmul(lua_State *L)           // mul(x,y)
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=(*a)*(*b);
    return 1;
}

static int Bdiv(lua_State *L)           // div(x,y)
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=(*a)/(*b);
    return 1;
}

static int Bpow(lua_State *L)           // pow(x,y)
{
    I * a=Bget(L,1);
    int e=(int)lua_tonumber(L,2);
    I * c=Bnew(L);
    *c=pow((*a),e);
    return 1;
}

static int Bcontains(lua_State *L)           
{
    I * a=Bget(L,1);
    double x=lua_tonumber(L,2);
    lua_pushboolean(L,in(x,*a));
    return 1;
}

static int Lcontained(lua_State *L)           
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    lua_pushboolean(L,subset(*a,*b));
    return 1;
}

static int Lmeet(lua_State *L)           
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=intersect(*a,*b);
    return 1;
}

static int Ljoin(lua_State *L)           
{
    I * a=Bget(L,1);
    I * b=Bget(L,2);
    I * c=Bnew(L);
    *c=hull(*a,*b);
    return 1;
}

static int Lextremes(lua_State *L)      /** extremes(x) */
{
 I * a=Bget(L,1);
 lua_pushnumber(L,a->lower());
 lua_pushnumber(L,a->upper());
 return 2;
}

static int Lmidrad(lua_State *L)        /** midrad(x) */
{
 I * a=Bget(L,1);
 double u=a->upper();
 double l=a->lower();
 lua_pushnumber(L,(u+l)/2.0);
 lua_pushnumber(L,(u-l)/2.0);
 return 2;
}

static int Ldiam(lua_State *L)          /** diam(x) */
{
 I * a=Bget(L,1);
 lua_pushnumber(L,width(*a));
 return 1;
}

static int Linf(lua_State *L)           /** inf(x) */
{
 I * a=Bget(L,1);
 lua_pushnumber(L,a->lower());
 return 1;
}

static int Lsup(lua_State *L)           /** sup(x) */
{
 I * a=Bget(L,1);
 lua_pushnumber(L,a->upper());
 return 1;
}

static int Lmid(lua_State *L)           /** mid(x) */
{
 I * a=Bget(L,1);
 lua_pushnumber(L,median(*a));
 return 1;
}


static int Bgc(lua_State *L)
{
    I * x=Bget(L,1);
    x->~I();
    lua_pushnil(L);
    lua_setmetatable(L,1);
    return 0;
}

static int Binew(lua_State *L)           // new(l,u)
{
    double l=lua_tonumber(L,1);
    double u=lua_tonumber(L,2);
    I * c=Bnew(L);
    c->assign(l,u);
    return 1;
}

#define REG_ENTRY(FUNC) { #FUNC, B ## FUNC },
static const luaL_Reg R[] =
{
    { "__add",  Badd    },      /** __add(x,y) */
    { "__div",  Bdiv    },      /** __div(x,y) */
    { "__gc",   Bgc },
    { "__mul",  Bmul    },      /** __mul(x,y) */
    { "__pow",  Bpow    },      /** __pow(x,y) */
    { "__sub",  Bsub    },      /** __sub(x,y) */
    { "__tostring", Btostring},     /** __tostring(x) */
    { "__unm",  Bneg    },      /** __unm(x) */
    { "new", Binew },
    { "contains", Bcontains },
    { "midrad", Lmidrad },
    { "diam", Ldiam },
    { "inf", Linf },
    { "sup", Lsup },
    { "mid", Lmid },
    { "contained", Lcontained },
    { "meet", Lmeet },
    { "join", Ljoin },
    { "extremes", Lextremes },
    
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
        { NULL,     NULL    }
};

#undef REG_ENTRY

    extern "C"
int luaopen_interval(lua_State *L)
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

    return 1;
}
