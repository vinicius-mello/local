%include "../swig/gsl.i"
namespace gsl {

%native(multimin_nmsimplex2) int lua_multimin_nmsimplex2(lua_State * L);

};
%{

#include <gsl/gsl_multimin.h>

struct multimin_param {
  lua_State * L;
  int func_index;
};

double multimin_callback(const gsl_vector *v, void *params) {
  lua_State * L=((multimin_param*)params)->L;
  int func_index=((multimin_param*)params)->func_index;
  lua_rawgeti(L,LUA_REGISTRYINDEX,func_index);
  //push the parameters and call it
  array<double> V(v->size,v->data);
  SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
  lua_pcall(L, 1, 1, 0); // call a function with one argument and no return values
  double ret=lua_tonumber(L,-1);
  lua_pop(L,1);
  return ret;
}


int lua_multimin_nmsimplex2(lua_State * L) {
  double eps=0.00001;
  int maxiter=1000;
  bool print=false;
  array<double> * x=0;
  array<double> * ss=0;

  lua_pushstring(L,"show_iterations");
  lua_gettable(L,-2);
  if(lua_isboolean(L,-1)) {
    print=(lua_toboolean(L,-1)==1);
  }
  lua_pop(L,1);

  lua_pushstring(L,"eps");
  lua_gettable(L,-2);
  if(lua_isnumber(L,-1)) {
    eps=lua_tonumber(L,-1);
  }
  lua_pop(L,1);

  lua_pushstring(L,"maxiter");
  lua_gettable(L,-2);
  if(lua_isnumber(L,-1)) {
    maxiter=(int)lua_tonumber(L,-1);
  }
  lua_pop(L,1);

  lua_pushstring(L,"starting_point");
  lua_gettable(L,-2);
  if(!lua_isuserdata(L,-1)) lua_error(L);
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,-1,(void**)&x,SWIGTYPE_p_arrayT_double_t,0))){
    lua_error(L);
  }
  lua_pop(L,1);

  lua_pushstring(L,"step_sizes");
  lua_gettable(L,-2);
  if(!lua_isuserdata(L,-1)) lua_error(L);
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,-1,(void**)&ss,SWIGTYPE_p_arrayT_double_t,0))){
    lua_error(L);
  }
  lua_pop(L,1);

  lua_pop(L,1);
  multimin_param mp;
  mp.L=L;
  mp.func_index=luaL_ref(L, LUA_REGISTRYINDEX);
  const gsl_multimin_fminimizer_type *T = 
    gsl_multimin_fminimizer_nmsimplex2;
  gsl_multimin_fminimizer *s = NULL;
  gsl_vector SS, X;
  gsl_multimin_function minex_func;
     
  size_t iter = 0;
  int status;
  double size;
  int N=x->size();
     
  /* Starting point */
	X.size=x->size();
	X.stride=1;
	X.data=x->data();
	X.owner=0;
     
  /* Set initial step sizes */
	SS.size=ss->size();
	SS.stride=1;
	SS.data=ss->data();
	SS.owner=0;
     
  /* Initialize method and iterate */
  minex_func.n = N;
  minex_func.f = multimin_callback;
  minex_func.params = &mp;
     
  s = gsl_multimin_fminimizer_alloc (T, N);
  gsl_multimin_fminimizer_set (s, &minex_func, &X, &SS);
   
  do
  {
    iter++;
    status = gsl_multimin_fminimizer_iterate(s);
           
    if (status) 
      break;
  
    size = gsl_multimin_fminimizer_size (s);
    status = gsl_multimin_test_size (size, eps);
     
    if (status == GSL_SUCCESS)
    {
      if(print) printf ("converged to minimum at\n");
    }
   
    if(print) printf ("%5d f() = %12.3f size = %.9f\n", 
      iter,
      s->fval, size);
  } while (status == GSL_CONTINUE && iter < maxiter);
  for(int i=0;i<N;++i) x->set(i,gsl_vector_get(s->x,i));    
  luaL_unref(L, LUA_REGISTRYINDEX, mp.func_index);
  gsl_multimin_fminimizer_free (s);
}

%}
