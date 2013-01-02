#ifndef WRAP_UMFPACK_HPP
#define WRAP_UMFPACK_HPP
#include <umfpack.h>
#include "array.hpp"
#include "sparse.hpp"

struct umfpack_options {
    double prl;         /* print level */
    /* used in UMFPACK_*symbolic only: */
    double dense_row;       /* dense row parameter */
    double dense_col;       /* dense col parameter */
    double array_size;      /* blas-3 array size */
    double strategy;        /* auto, symmetric, or unsym. */
    double ordering;             /* ordering method to use */
    double fixq;            /* -1: no fixq, 0: default, 1: fixq */
    double amd_dense;       /* for amd ordering */
    double aggressive;      /* whether or not to use aggressive */
    double singletons;           /* singleton filter on if true */

    /* used in UMFPACK_numeric only: */
    double pivot_tolerance; /* threshold partial pivoting setting */
    double alloc_init;      /* initial allocation ratio */
    double sym_pivot_tolerance; /* threshold, only for diag. entries */
    double scale;       /* what row scaling to do */
    double front_alloc_init;    /* frontal matrix allocation ratio */
    double droptol;     /* drop tolerance for entries in l,u */

    /* used in UMFPACK_*solve only: */
    double irstep;      /* max # of iterative refinements */

    umfpack_options() {
        prl=1;
        dense_row=0.2;
        dense_col=0.2;
        array_size=32;
        strategy=0;
        ordering=1;
        fixq=0;
        amd_dense=10;
        aggressive=1;
        singletons=1;
        pivot_tolerance=0.1;
        alloc_init=0.7;
        sym_pivot_tolerance=0.001;
        scale=1;
        front_alloc_init=0.5;
        droptol=0;
        irstep=2;
    }
};

class umfpack {
    int status;
    int sys;
    double Control[UMFPACK_CONTROL];
    double Info[UMFPACK_INFO];
    void * Symbolic;
    void * Numeric;
    umfpack_options uoptions;
    const sparse& S;
    public:
    umfpack(const sparse& _S) : S(_S) {
        Symbolic=Numeric=0;
    }
    ~umfpack() {
        if(Symbolic) umfpack_di_free_symbolic(&Symbolic);
        if(Numeric) umfpack_di_free_numeric(&Numeric);
    }
    void set_options(const umfpack_options& opt) {
        uoptions=opt;
        //  printf("%f\n",opt.scale);
        Control[UMFPACK_PRL]=opt.prl;
        Control[UMFPACK_DENSE_ROW]=opt.dense_row;
        Control[UMFPACK_DENSE_COL]=opt.dense_col;
        Control[UMFPACK_BLOCK_SIZE]=opt.array_size;
        Control[UMFPACK_STRATEGY]=opt.strategy;
        Control[UMFPACK_ORDERING]=opt.ordering;
        Control[UMFPACK_FIXQ]=opt.fixq;
        Control[UMFPACK_AMD_DENSE]=opt.amd_dense;
        Control[UMFPACK_AGGRESSIVE]=opt.aggressive;
        Control[UMFPACK_SINGLETONS]=opt.singletons;
        Control[UMFPACK_PIVOT_TOLERANCE]=opt.pivot_tolerance;
        Control[UMFPACK_ALLOC_INIT]=opt.alloc_init;
        Control[UMFPACK_SYM_PIVOT_TOLERANCE]=opt.sym_pivot_tolerance;
        Control[UMFPACK_SCALE]=opt.scale;
        Control[UMFPACK_FRONT_ALLOC_INIT]=opt.front_alloc_init;
        Control[UMFPACK_DROPTOL]=opt.droptol;
        Control[UMFPACK_IRSTEP]=opt.irstep;
    }
    void factor() {
        double * null=(double*) NULL;
        if(Symbolic) umfpack_di_free_symbolic(&Symbolic);
        umfpack_di_symbolic(S.n(),S.m(),S.col_ptr().data(),S.row_ind().data(),S.val().data(),&Symbolic,Control,null);
        if(Numeric) umfpack_di_free_numeric(&Numeric);
        umfpack_di_numeric(S.col_ptr().data(),S.row_ind().data(),S.val().data(),Symbolic,&Numeric,Control,null);
    }
    //void solve(double * b, double * x) const {
    void solve(const array<double>& b, array<double>& x) const {
        double * null=(double*) NULL;
        //umfpack_di_solve (UMFPACK_A, S.Ap, S.Ai, S.Ax, x, b, Numeric, null, null) ;
        umfpack_di_solve (UMFPACK_A, S.col_ptr().data(), S.row_ind().data(), S.val().data(), x.data(), b.data(), Numeric, Control, null) ;
    }
};

#endif // WRAP_UMFPACK_HPP
