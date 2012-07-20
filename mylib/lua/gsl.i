%include "../swig/gsl.i"
namespace gsl {

%native(multimin_fminimize) int lua_multimin_fminimize(lua_State * L);
%native(multimin_fdfminimize) int lua_multimin_fdfminimize(lua_State * L);

};
%{

#include <gsl/gsl_multimin.h>

struct multimin_param {
  lua_State * L;
  int f_index;
  int df_index;
};

double multimin_f_cb(const gsl_vector *v, void *params) {
  lua_State * L=((multimin_param*)params)->L;
  int f_index=((multimin_param*)params)->f_index;
  lua_rawgeti(L,LUA_REGISTRYINDEX,f_index);
  //push the parameters and call it
  array<double> V(v->size,v->data);
  SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
  lua_pcall(L, 1, 1, 0); 
  double ret=lua_tonumber(L,-1);
  lua_pop(L,1);
  return ret;
}

void multimin_df_cb(const gsl_vector *v, void *params, gsl_vector * g) {
  lua_State * L=((multimin_param*)params)->L;
  int df_index=((multimin_param*)params)->df_index;
  lua_rawgeti(L,LUA_REGISTRYINDEX,df_index);
  //push the parameters and call it
  array<double> V(v->size,v->data);
  SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
  array<double> G(g->size,g->data);
  SWIG_NewPointerObj(L,(void *) &G,SWIGTYPE_p_arrayT_double_t,0);
  lua_pcall(L, 2, 0, 0); 
}

void multimin_fdf_cb(const gsl_vector *v, void *params, double * f, gsl_vector * g) {
  *f=multimin_f_cb(v,params);
  multimin_df_cb(v,params,g);
}

int lua_multimin_fminimize(lua_State * L) {
  double eps=0.00001;
  int maxiter=1000;
  bool print=false;
  array<double> * x=0;
  array<double> * ss=0;
  const gsl_multimin_fminimizer_type *T = 
    gsl_multimin_fminimizer_nmsimplex2;

  lua_pushstring(L,"algorithm");
  lua_gettable(L,-2);
  if(lua_isstring(L,-1)) {
    if(!strcmp(lua_tostring(L,-1),"nmsimplex")) {
      T = gsl_multimin_fminimizer_nmsimplex;
    } else if(!strcmp(lua_tostring(L,-1),"nmsimplex2rand")) {
      T = gsl_multimin_fminimizer_nmsimplex2rand;
    }
  }
  lua_pop(L,1);

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
  mp.f_index=luaL_ref(L, LUA_REGISTRYINDEX);
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
  minex_func.f = multimin_f_cb;
  minex_func.params = &mp;
     
  s = gsl_multimin_fminimizer_alloc (T, N);
  gsl_multimin_fminimizer_set (s, &minex_func, &X, &SS);
  if(print)  printf ("running algorithm '%s'\n",
                  gsl_multimin_fminimizer_name (s)); 
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
  luaL_unref(L, LUA_REGISTRYINDEX, mp.f_index);
  gsl_multimin_fminimizer_free (s);
}


int lua_multimin_fdfminimize(lua_State * L) {
  double eps=0.00001;
  double tol=0.0001;
  double step_size=0.01;
  int maxiter=1000;
  bool print=false;
  array<double> * x=0;
  array<double> * ss=0;
  const gsl_multimin_fdfminimizer_type *T = 
    gsl_multimin_fdfminimizer_conjugate_fr;

  lua_pushstring(L,"algorithm");
  lua_gettable(L,-2);
  if(lua_isstring(L,-1)) {
    if(!strcmp(lua_tostring(L,-1),"conjugate_pr")) {
      T = gsl_multimin_fdfminimizer_conjugate_pr;
    } else if(!strcmp(lua_tostring(L,-1),"steepest_descent")) {
      T = gsl_multimin_fdfminimizer_steepest_descent;
    } else if(!strcmp(lua_tostring(L,-1),"vector_bfgs")) {
      T = gsl_multimin_fdfminimizer_vector_bfgs;
    } else if(!strcmp(lua_tostring(L,-1),"vector_bfgs2")) {
      T = gsl_multimin_fdfminimizer_vector_bfgs2;
    }
  }
  lua_pop(L,1);

  lua_pushstring(L,"show_iterations");
  lua_gettable(L,-2);
  if(lua_isboolean(L,-1)) {
    print=(lua_toboolean(L,-1)==1);
  }
  lua_pop(L,1);

  lua_pushstring(L,"step_size");
  lua_gettable(L,-2);
  if(lua_isnumber(L,-1)) {
    step_size=lua_tonumber(L,-1);
  }
  lua_pop(L,1);

  lua_pushstring(L,"tol");
  lua_gettable(L,-2);
  if(lua_isnumber(L,-1)) {
    tol=lua_tonumber(L,-1);
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

  lua_pop(L,1);
  multimin_param mp;
  mp.L=L;
  mp.df_index=luaL_ref(L, LUA_REGISTRYINDEX);
  mp.f_index=luaL_ref(L, LUA_REGISTRYINDEX);
  gsl_multimin_fdfminimizer *s = NULL;
  gsl_vector X;
  gsl_multimin_function_fdf minex_func;
     
  size_t iter = 0;
  int status;
  double size;
  int N=x->size();
     
  /* Starting point */
	X.size=x->size();
	X.stride=1;
	X.data=x->data();
	X.owner=0;
     
  /* Initialize method and iterate */
  minex_func.n = N;
  minex_func.f = multimin_f_cb;
  minex_func.df = multimin_df_cb;
  minex_func.fdf = multimin_fdf_cb;
  minex_func.params = &mp;
     
  s = gsl_multimin_fdfminimizer_alloc (T, N);
  gsl_multimin_fdfminimizer_set (s, &minex_func, &X, step_size, tol);
  if(print)  printf ("running algorithm '%s'\n",
                  gsl_multimin_fdfminimizer_name (s)); 
  do
  {
    iter++;
    status = gsl_multimin_fdfminimizer_iterate(s);
           
    if (status) 
      break;
  
    status = gsl_multimin_test_gradient (s->gradient, eps);
     
    if (status == GSL_SUCCESS)
    {
      if(print) printf ("converged to minimum at\n");
    }
   
    if(print) printf ("%5d f() = %12.3f\n", 
      iter,
      s->f);
  } while (status == GSL_CONTINUE && iter < maxiter);
  for(int i=0;i<N;++i) x->set(i,gsl_vector_get(s->x,i));    
  luaL_unref(L, LUA_REGISTRYINDEX, mp.f_index);
  luaL_unref(L, LUA_REGISTRYINDEX, mp.df_index);
  gsl_multimin_fdfminimizer_free (s);
}

%}
