%module umfpack
%{
#include <wrappers/umfpack.hpp>
%}
/* Control [UMFPACK_STRATEGY] is one of the following: */
#define STRATEGY_AUTO 0         /* use sym. or unsym. strategy */
#define STRATEGY_UNSYMMETRIC 1  /* COLAMD(A), coletree postorder,
                                   not prefer diag*/
#define STRATEGY_OBSOLETE 2     /* 2-by-2 is no longer available */
#define STRATEGY_SYMMETRIC 3    /* AMD(A+A'), no coletree postorder,
                                   prefer diagonal */

/* Control [UMFPACK_SCALE] is one of the following: */
#define SCALE_NONE 0            /* no scaling */
#define SCALE_SUM 1             /* default: divide each row by sum (abs (row))*/
#define SCALE_MAX 2             /* divide each row by max (abs (row)) */

/* Control [UMFPACK_ORDERING] and Info [UMFPACK_ORDERING_USED] are one of: */
#define ORDERING_CHOLMOD 0      /* use CHOLMOD (AMD/COLAMD then METIS)*/
#define ORDERING_AMD 1          /* use AMD/COLAMD */
#define ORDERING_GIVEN 2        /* user-provided Qinit */
#define ORDERING_METIS 3        /* use METIS */
#define ORDERING_BEST 4         /* try many orderings, pick best */
#define ORDERING_NONE 5         /* natural ordering */
#define ORDERING_USER 6         /* user-provided function */

struct umfpack_options {
    double prl;             /* providedint level */
    /* used in UMFPACK_*symbolic only: */
    double dense_row;       /* dense row parameter */
    double dense_col;       /* dense col parameter */
    double array_size;      /* blas-3 array size */
    double strategy;        /* auto, symmetric, or unsym. */
    double ordering;        /* ordering method to use */
    double fixq;            /* -1: no fixq, 0: default, 1: fixq */
    double amd_dense;       /* for amd ordering */
    double aggressive;      /* whether or not to use aggressive */
    double singletons;       /* singleton filter on if true */

    /* used in UMFPACK__SCALEK_numeric only: */
    double pivot_tolerance; /* threshold partial pivoting setting */
    double alloc_init;      /* initial allocation ratio */
    double sym_pivot_tolerance; /* threshold, only for diag. entries */
    double scale;           /* what row scaling to do */
    double front_alloc_init;    /* frontal matrix allocation ratio */
    double droptol;         /* drop tolerance for entries in l,u */

    /* used in UMFPACK_*solve only: */
    double irstep;          /* max # of iterative refinements */
};


class umfpack {
    public:
        umfpack(const sparse& _S);
        ~umfpack();
        void set_options(const umfpack_options& opt);
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
};

