#ifndef WRAP_TAUCS_HPP
#define WRAP_TAUCS_HPP
extern "C" {
#include <taucs.h>
}
#include "array.hpp"
#include "sparse.hpp"

static const char * str_options[]={
    "taucs.approximate.sg=#0",
    "taucs.approximate.amwb=#1",
    "taucs.approximate.amwb.randomseed=#2",
    "taucs.approximate.amwb.subgraphs=#3",
    "taucs.factor=#4",
    "taucs.factor.symbolic=#5",
    "taucs.factor.numeric=#6",
    "taucs.factor.LLT=#7",
    "taucs.factor.LU=#8",
    "taucs.factor.mf=#9",
    "taucs.factor.ll=#10",
    "taucs.factor.ordering=#11",
    "taucs.maxdepth=#12",
    "taucs.ooc=#13",
    "taucs.ooc.basename=#14",
    "taucs.ooc.memory=#15",
    "taucs.solve.cg=#16",
    "taucs.solve.minres=#17",
    "taucs.solve.maxits=#18",
    "taucs.solve.convergetol=#19"
};

struct taucs_options {
    int approximate_sg;
    int approximate_amwb;
    double approximate_amwb_randomseed;
    double approximate_amwb_subgraphs;
    int factor;
    int factor_symbolic;
    int factor_numeric;
    int factor_LLT;
    int factor_LU;
    int factor_mf;
    int factor_ll;
    char * factor_ordering;
    double maxdepth;
    int ooc;
    char * ooc_basename;
    double ooc_memory;
    int solve_cg;
    int solve_minres;
    double solve_maxits;
    double solve_convergetol;
    taucs_options() {
        approximate_sg          = 0;
        approximate_amwb        = 0;
        approximate_amwb_subgraphs = 1;
        approximate_amwb_randomseed    = 170566;
        factor=  1;
        factor_symbolic  =  1;
        factor_numeric   =  1;
        factor_LLT=1;
        factor_LU=  0;
        factor_mf=  0;
        factor_ll=  0;
        factor_ordering=  0;
        maxdepth  = 0.0; /* default meaning no limit */
        ooc =  0;
        ooc_basename   = 0;
        ooc_memory = -1.0;
        solve_cg = 0;
        solve_minres = 0;
        solve_maxits = 300.0;
        solve_convergetol = 1e-6;
    }
};

class taucs {
    mutable void * F;
    mutable taucs_ccs_matrix A;
    mutable void * arguments[21];
    mutable taucs_options toptions;
    const sparse& S;
    public:
    taucs(const sparse& _S, int flags=(TAUCS_DOUBLE|TAUCS_SYMMETRIC|TAUCS_LOWER)) : S(_S) {
        A.n=S.n();
        A.m=S.m();
        A.colptr=const_cast<int *>(S.col_ptr().data());
        A.rowind=const_cast<int *>(S.row_ind().data());
        A.values.d=const_cast<double *>(S.val().data());
        A.flags=flags;
        F=0;
        arguments[0]=&toptions.approximate_sg;
        arguments[1]=&toptions.approximate_amwb;
        arguments[2]=&toptions.approximate_amwb_randomseed;
        arguments[3]=&toptions.approximate_amwb_subgraphs;
        arguments[4]=&toptions.factor;
        arguments[5]=&toptions.factor_symbolic;
        arguments[6]=&toptions.factor_numeric;
        arguments[7]=&toptions.factor_LLT;
        arguments[8]=&toptions.factor_LU;
        arguments[9]=&toptions.factor_mf;
        arguments[10]=&toptions.factor_ll;
        arguments[11]=&toptions.factor_ordering;
        arguments[12]=&toptions.maxdepth;
        arguments[13]=&toptions.ooc;
        arguments[14]=&toptions.ooc_basename;
        arguments[15]=&toptions.ooc_memory;
        arguments[16]=&toptions.solve_cg;
        arguments[17]=&toptions.solve_minres;
        arguments[18]=&toptions.solve_maxits;
        arguments[19]=&toptions.solve_convergetol;
    }
    ~taucs() {
        if(F) taucs_linsolve(0,&F,0,0,0,0,0);
    }
    void set_options(const taucs_options& opt) {
        toptions=opt;
    }
    void factor() {
        if(F) taucs_linsolve(0,&F,0,0,0,0,0);
        taucs_linsolve(&A,&F,0,0,0,(char **)str_options,arguments);
    }
    void solve(const array<double>& b, array<double>& x) const {
        int save=toptions.factor;
        toptions.factor=0;
        taucs_linsolve(&A,&F,1,x.data(),b.data(),(char **)str_options,arguments);
        //taucs_linsolve(&A,&F,1,x.data(),b.data(),0,0);
        toptions.factor=save;
    }
};

class taucs_ldlt {
    mutable taucs_ccs_matrix * L;
    mutable taucs_ccs_matrix A;
    const sparse& S;
    public:
    taucs_ldlt(const sparse& _S, int flags=(TAUCS_DOUBLE|TAUCS_SYMMETRIC|TAUCS_LOWER)) : S(_S) {
        A.n=S.n();
        A.m=S.m();
        A.colptr=const_cast<int *>(S.col_ptr().data());
        A.rowind=const_cast<int *>(S.row_ind().data());
        A.values.d=const_cast<double *>(S.val().data());
        A.flags=flags;
        L=0;
    }
    ~taucs_ldlt() {
        if(L) taucs_ccs_free(L);
    }
    void factor() {
        if(L) taucs_ccs_free(L);
        L=taucs_ccs_factor_ldlt(&A);
    }
    void solve(const array<double>& b, array<double>& x) const {
        taucs_ccs_solve_ldlt(L,x.data(),b.data());
    }
    int inertia() const {
        const double eps=-0.00000001;
        if(L) {
            int counter=0;
            for(int i=0;i<L->n;++i) {
                for(int j=L->colptr[i];j<L->colptr[i+1];j++) {
                    if(L->rowind[j]==i) {
                        double v=L->values.d[j];
                        if(v<eps) counter++;
                        break;
                    }
                }
            }
            return counter;
        } else {
            return -1;
        }
    }
};


#endif // WRAP_TAUCS_HPP
