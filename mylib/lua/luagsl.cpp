#include <gsl/gsl_multimin.h>
#include <gsl/gsl_integration.h>

struct multi_param {
    lua_State * L;
    int f_index;
    int df_index;
    int fdf_index;
};

double multimin_f_cb(const gsl_vector *v, void *params) {
    lua_State * L=((multi_param*)params)->L;
    int f_index=((multi_param*)params)->f_index;
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
    lua_State * L=((multi_param*)params)->L;
    int df_index=((multi_param*)params)->df_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,df_index);
    //push the parameters and call it
    array<double> V(v->size,v->data);
    SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
    array<double> G(g->size,g->data);
    SWIG_NewPointerObj(L,(void *) &G,SWIGTYPE_p_arrayT_double_t,0);
    lua_pcall(L, 2, 0, 0);
}

void multimin_fdf_cb(const gsl_vector *v, void *params, double * f, gsl_vector * g) {
    lua_State * L=((multi_param*)params)->L;
    int fdf_index=((multi_param*)params)->fdf_index;
    if(fdf_index<0) {
        *f=multimin_f_cb(v,params);
        multimin_df_cb(v,params,g);
    } else {
        lua_rawgeti(L,LUA_REGISTRYINDEX,fdf_index);
        //push the parameters and call it
        array<double> V(v->size,v->data);
        SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
        array<double> G(g->size,g->data);
        SWIG_NewPointerObj(L,(void *) &G,SWIGTYPE_p_arrayT_double_t,0);
        lua_pcall(L, 2, 1, 0);
        *f=lua_tonumber(L,-1);
        lua_pop(L,1);
    }
}

int lua_multimin_minimize(lua_State * L) {
    bool ssdel=false;
    double eps=0.00001;
    double tol=0.0001;
    double step_size=0.01;
    int maxiter=1000;
    bool print=false;
    array<double> * x=0;
    array<double> * ss=0;
    const gsl_multimin_fminimizer_type *Tf = 0;
    const gsl_multimin_fdfminimizer_type *Tdf = 0;


    multi_param mp;
    mp.L=L;
    mp.fdf_index=-1;

    lua_pushstring(L,"f");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.f_index=luaL_ref(L, LUA_REGISTRYINDEX);
    } else {
        luaL_error(L,"%s\n","missing function");
    }

    lua_pushstring(L,"df");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.df_index=luaL_ref(L, LUA_REGISTRYINDEX);
        Tdf= gsl_multimin_fdfminimizer_conjugate_fr;
    } else {
        lua_pop(L,1);
        Tf= gsl_multimin_fminimizer_nmsimplex2;
    }

    lua_pushstring(L,"fdf");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.fdf_index=luaL_ref(L, LUA_REGISTRYINDEX);
    } else {
        lua_pop(L,1);
        mp.fdf_index=-1;
    }

    lua_pushstring(L,"algorithm");
    lua_gettable(L,-2);
    if(lua_isstring(L,-1)) {
        if(Tf!=0) {
            if(!strcmp(lua_tostring(L,-1),"nmsimplex")) {
                Tf = gsl_multimin_fminimizer_nmsimplex;
            } else if(!strcmp(lua_tostring(L,-1),"nmsimplex2rand")) {
                Tf = gsl_multimin_fminimizer_nmsimplex2rand;
            } else if(!strcmp(lua_tostring(L,-1),"nmsimplex2")) {
                Tf = gsl_multimin_fminimizer_nmsimplex2;
            } else {
                luaL_error(L,"%s\n","invalid algorithm");
            }
        } else {
            if(!strcmp(lua_tostring(L,-1),"conjugate_pr")) {
                Tdf = gsl_multimin_fdfminimizer_conjugate_pr;
            } else if(!strcmp(lua_tostring(L,-1),"steepest_descent")) {
                Tdf = gsl_multimin_fdfminimizer_steepest_descent;
            } else if(!strcmp(lua_tostring(L,-1),"vector_bfgs")) {
                Tdf = gsl_multimin_fdfminimizer_vector_bfgs;
            } else if(!strcmp(lua_tostring(L,-1),"vector_bfgs2")) {
                Tdf = gsl_multimin_fdfminimizer_vector_bfgs2;
            } else if(!strcmp(lua_tostring(L,-1),"conjugate_fr")) {
                Tdf = gsl_multimin_fdfminimizer_conjugate_fr;
            } else {
                luaL_error(L,"%s\n","invalid algorithm");
            }
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
        luaL_error(L,"%s\n","missing starting point");
    }
    lua_pop(L,1);

    if(Tf) {
        lua_pushstring(L,"step_sizes");
        lua_gettable(L,-2);
        if(lua_isuserdata(L,-1)) {
            if (!SWIG_IsOK(SWIG_ConvertPtr(L,-1,(void**)&ss,SWIGTYPE_p_arrayT_double_t,0))){
                lua_error(L);
            }
        } else {
            ssdel=true;
            ss=new array<double>(x->size());
            ss->set_all(1.0);
            if(lua_isnumber(L,-1)) {
                double v=lua_tonumber(L,-1);
                ss->set_all(v);
            }
        }
        lua_pop(L,1);
    }

    lua_pop(L,1);

    if(Tf) {
        gsl_multimin_fminimizer *s = NULL;
        gsl_vector SS, X;
        gsl_multimin_function minex_func;

        int iter = 0;
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

        s = gsl_multimin_fminimizer_alloc (Tf, N);
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
    } else {
        gsl_multimin_fdfminimizer *s = NULL;
        gsl_vector X;
        gsl_multimin_function_fdf minex_func;

        int iter = 0;
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

        s = gsl_multimin_fdfminimizer_alloc (Tdf, N);
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
    if(mp.fdf_index>=0) {
        luaL_unref(L, LUA_REGISTRYINDEX, mp.fdf_index);
    }
    if(ssdel) {
        delete ss;
    }
    return 0;
}

#include <gsl/gsl_multiroots.h>

int multiroot_f_cb(const gsl_vector *v, void *params, gsl_vector *f) {
    lua_State * L=((multi_param*)params)->L;
    int f_index=((multi_param*)params)->f_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,f_index);
    //push the parameters and call it
    array<double> V(v->size,v->data);
    SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
    array<double> F(f->size,f->data);
    SWIG_NewPointerObj(L,(void *) &F,SWIGTYPE_p_arrayT_double_t,0);
    lua_pcall(L, 2, 0, 0);
    return GSL_SUCCESS;
}

int multiroot_df_cb(const gsl_vector *v, void *params, gsl_matrix * j) {
    lua_State * L=((multi_param*)params)->L;
    int df_index=((multi_param*)params)->df_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,df_index);
    //push the parameters and call it
    array<double> V(v->size,v->data);
    SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
    array<double> J(j->size1,j->size2,j->data);
    SWIG_NewPointerObj(L,(void *) &J,SWIGTYPE_p_arrayT_double_t,0);
    lua_pcall(L, 2, 0, 0);
    return GSL_SUCCESS;
}

int multiroot_fdf_cb(const gsl_vector *v, void *params, gsl_vector * f, gsl_matrix * j) {
    lua_State * L=((multi_param*)params)->L;
    int fdf_index=((multi_param*)params)->fdf_index;
    if(fdf_index<0) {
        multiroot_f_cb(v,params,f);
        multiroot_df_cb(v,params,j);
    } else {
        lua_rawgeti(L,LUA_REGISTRYINDEX,fdf_index);
        //push the parameters and call it
        array<double> V(v->size,v->data);
        SWIG_NewPointerObj(L,(void *) &V,SWIGTYPE_p_arrayT_double_t,0);
        array<double> F(f->size,f->data);
        SWIG_NewPointerObj(L,(void *) &F,SWIGTYPE_p_arrayT_double_t,0);
        array<double> J(j->size1,j->size2,j->data);
        SWIG_NewPointerObj(L,(void *) &J,SWIGTYPE_p_arrayT_double_t,0);
        lua_pcall(L, 3, 0, 0);
    }
    return GSL_SUCCESS;
}

int lua_multiroot_solve(lua_State * L) {
    double eps=0.00001;
    int maxiter=1000;
    bool print=false;
    array<double> * x=0;
    const gsl_multiroot_fsolver_type *Tf = 0;
    const gsl_multiroot_fdfsolver_type *Tdf = 0;

    multi_param mp;
    mp.L=L;
    mp.fdf_index=-1;

    lua_pushstring(L,"f");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.f_index=luaL_ref(L, LUA_REGISTRYINDEX);
    } else {
        luaL_error(L,"%s\n","missing function");
    }

    lua_pushstring(L,"df");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.df_index=luaL_ref(L, LUA_REGISTRYINDEX);
        Tdf= gsl_multiroot_fdfsolver_hybridsj;
    } else {
        lua_pop(L,1);
        Tf=  gsl_multiroot_fsolver_hybrids;
    }

    lua_pushstring(L,"fdf");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.fdf_index=luaL_ref(L, LUA_REGISTRYINDEX);
    } else {
        lua_pop(L,1);
        mp.fdf_index=-1;
    }

    lua_pushstring(L,"algorithm");
    lua_gettable(L,-2);
    if(lua_isstring(L,-1)) {
        if(Tf) {
            if(!strcmp(lua_tostring(L,-1),"hybrid")) {
                Tf = gsl_multiroot_fsolver_hybrid;
            } else if(!strcmp(lua_tostring(L,-1),"dnewton")) {
                Tf = gsl_multiroot_fsolver_dnewton;
            } else if(!strcmp(lua_tostring(L,-1),"hybrids")) {
                Tf = gsl_multiroot_fsolver_hybrids;
            } else if(!strcmp(lua_tostring(L,-1),"broyden")) {
                Tf = gsl_multiroot_fsolver_broyden;
            } else {
                luaL_error(L,"%s\n","invalid algorithm");
            }
        } else {
            if(!strcmp(lua_tostring(L,-1),"hybridj")) {
                Tdf = gsl_multiroot_fdfsolver_hybridj;
            } else if(!strcmp(lua_tostring(L,-1),"newton")) {
                Tdf = gsl_multiroot_fdfsolver_newton;
            } else if(!strcmp(lua_tostring(L,-1),"hybridsj")) {
                Tdf = gsl_multiroot_fdfsolver_hybridsj;
            } else if(!strcmp(lua_tostring(L,-1),"gnewton")) {
                Tdf = gsl_multiroot_fdfsolver_gnewton;
            } else {
                luaL_error(L,"%s\n","invalid algorithm");
            }
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

    lua_pop(L,1);
    if(Tf) {
        gsl_multiroot_fsolver *s = NULL;
        gsl_vector X;
        gsl_multiroot_function sol_func;

        int iter = 0;
        int status;
        double size;
        int N=x->size();

        /* Starting point */
        X.size=x->size();
        X.stride=1;
        X.data=x->data();
        X.owner=0;

        /* Initialize method and iterate */
        sol_func.n = N;
        sol_func.f = multiroot_f_cb;
        sol_func.params = &mp;

        s = gsl_multiroot_fsolver_alloc (Tf, N);
        gsl_multiroot_fsolver_set (s, &sol_func, &X);
        if(print)  printf ("running algorithm '%s'\n",
                gsl_multiroot_fsolver_name (s));
        do
        {
            iter++;
            status = gsl_multiroot_fsolver_iterate(s);

            if (status)
                break;

            status = gsl_multiroot_test_residual (s->f, eps);

            if(print) {
                printf ("%5d f() = ", iter);
                gsl_vector_fprintf(stdout,  s->f, "%f");
            }
        } while (status == GSL_CONTINUE && iter < maxiter);
        for(int i=0;i<N;++i) x->set(i,gsl_vector_get(s->x,i));
        luaL_unref(L, LUA_REGISTRYINDEX, mp.f_index);
        gsl_multiroot_fsolver_free (s);
    } else {
        gsl_multiroot_fdfsolver *s = NULL;
        gsl_vector X;
        gsl_multiroot_function_fdf sol_func;

        int iter = 0;
        int status;
        double size;
        int N=x->size();

        /* Starting point */
        X.size=x->size();
        X.stride=1;
        X.data=x->data();
        X.owner=0;

        /* Initialize method and iterate */
        sol_func.n = N;
        sol_func.f = multiroot_f_cb;
        sol_func.df = multiroot_df_cb;
        sol_func.fdf = multiroot_fdf_cb;
        sol_func.params = &mp;

        s = gsl_multiroot_fdfsolver_alloc (Tdf, N);
        gsl_multiroot_fdfsolver_set (s, &sol_func, &X);
        if(print)  printf ("running algorithm '%s'\n",
                gsl_multiroot_fdfsolver_name (s));
        do
        {
            iter++;
            status = gsl_multiroot_fdfsolver_iterate(s);

            if (status)
                break;

            status = gsl_multiroot_test_residual (s->f, eps);

            if(print) {
                printf ("%5d f() = ", iter);
                gsl_vector_fprintf(stdout,  s->f, "%f");
            }
        } while (status == GSL_CONTINUE && iter < maxiter);
        for(int i=0;i<N;++i) x->set(i,gsl_vector_get(s->x,i));
        luaL_unref(L, LUA_REGISTRYINDEX, mp.f_index);
        luaL_unref(L, LUA_REGISTRYINDEX, mp.df_index);
        gsl_multiroot_fdfsolver_free (s);
    }
    if(mp.fdf_index>=0) luaL_unref(L, LUA_REGISTRYINDEX, mp.fdf_index);
    return 0;
}

double int_f_cb(double x, void *params) {
    lua_State * L=((multi_param*)params)->L;
    int f_index=((multi_param*)params)->f_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,f_index);
    //push the parameters and call it
    lua_pushnumber(L,x);
    lua_pcall(L, 1, 1, 0);
    double ret=lua_tonumber(L,-1);
    lua_pop(L,1);
    return ret;
}

int lua_integration_integrate(lua_State * L) {
    double a=0.0;
    double b=1.0;
    double c=0.5;
    double epsabs=0.0;
    double epsrel=0.0000001;
    double alpha=0.0;
    double beta=0.0;
    int mu=0;
    int nu=0;
    size_t limit=100;
    size_t n=0;
    int key=1;
    double result=0;
    double abserr=0;
    size_t neval=0;

    gsl_integration_workspace * w=0;

    multi_param mp;
    mp.L=L;

    lua_pushstring(L,"f");
    lua_gettable(L,-2);
    if(lua_isfunction(L,-1)) {
        mp.f_index=luaL_ref(L, LUA_REGISTRYINDEX);
    } else {
        luaL_error(L,"%s\n","missing function");
    }
    gsl_function F;
    F.function = &int_f_cb;
    F.params = &mp;

    lua_pushstring(L,"epsabs");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        epsabs=lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"epsrel");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        epsrel=lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"a");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        a=lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"b");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        b=lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"c");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        c=lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"limit");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        limit=(size_t)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"n");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        n=(size_t)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    if(limit>n) n=limit;

    lua_pushstring(L,"key");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        key=(int)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"alpha");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        alpha=(double)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"beta");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        beta=(double)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"mu");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        mu=(int)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"nu");
    lua_gettable(L,-2);
    if(lua_isnumber(L,-1)) {
        nu=(int)lua_tonumber(L,-1);
    }
    lua_pop(L,1);

    lua_pushstring(L,"algorithm");
    lua_gettable(L,-2);
    if(lua_isstring(L,-1)) {
        if(!strcmp(lua_tostring(L,-1),"qng")) {
            gsl_integration_qng(&F,a,b,epsabs,epsrel,&result,&abserr,&neval);
        } else if(!strcmp(lua_tostring(L,-1),"qag")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qag(&F,a,b,epsabs,epsrel,limit,key,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qags")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qags(&F,a,b,epsabs,epsrel,limit,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qagi")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qagi(&F,epsabs,epsrel,limit,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qagiu")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qagiu(&F,a,epsabs,epsrel,limit,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qagil")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qagil(&F,b,epsabs,epsrel,limit,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qawc")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qawc(&F,a,b,c,epsabs,epsrel,limit,w,&result,&abserr);
        } else if(!strcmp(lua_tostring(L,-1),"qaws")) {
            w=gsl_integration_workspace_alloc(n);
            gsl_integration_qaws_table * table=gsl_integration_qaws_table_alloc(alpha,beta,mu,nu);
            gsl_integration_qaws(&F,a,b,table,epsabs,epsrel,limit,w,&result,&abserr);
            gsl_integration_qaws_table_free(table);
        } else if(!strcmp(lua_tostring(L,-1),"cquad")) {
            gsl_integration_cquad_workspace * w=gsl_integration_cquad_workspace_alloc(n);
            gsl_integration_cquad(&F,a,b,epsabs,epsrel,w,&result,&abserr,&neval);
            gsl_integration_cquad_workspace_free(w);
        } else {
            luaL_error(L,"%s\n","invalid algorithm");
        }
    } else {
        gsl_integration_cquad_workspace * w=gsl_integration_cquad_workspace_alloc(n);
        gsl_integration_cquad(&F,a,b,epsabs,epsrel,w,&result,&abserr,&neval);
        gsl_integration_cquad_workspace_free(w);
    }
    lua_pop(L,1);

    lua_pop(L,1);

    lua_pushnumber(L,result);
    lua_pushnumber(L,abserr);
    lua_pushnumber(L,neval);
    if(mp.fdf_index>=0) luaL_unref(L, LUA_REGISTRYINDEX, mp.fdf_index);
    if(w) gsl_integration_workspace_free(w);
    return 3;
}
