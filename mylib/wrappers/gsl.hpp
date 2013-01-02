#include <iostream>
#include "array.hpp"
#include <gsl/gsl_math.h>
#include <gsl/gsl_poly.h>
#include <gsl/gsl_sf.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_sort_vector.h>
#include <gsl/gsl_multiroots.h>

using namespace std;

namespace gsl {

    inline bool isNaN (const double x) {
        return gsl_isnan(x)==1;
    }

    inline int isInf (const double x) {
        return gsl_isinf (x);
    }

    inline bool finite (const double x) {
        return gsl_finite(x)==1;
    }

    inline double log1p(const double x) {
        return gsl_log1p (x);
    }

    inline double expm1(const double x) {
        return gsl_expm1 (x);
    }

    inline double hypot(const double x, const double y) {
        return gsl_hypot (x,y);
    }

    inline double hypot3(const double x, const double y, const double z) {
        return gsl_hypot3(x,y,z);
    }

    inline double pow2(const double x) {
        return gsl_pow_2(x);
    }

    inline double pow3(const double x) {
        return gsl_pow_3(x);
    }

    inline double pow4(const double x) {
        return gsl_pow_4(x);
    }

    inline double pow5(const double x) {
        return gsl_pow_5(x);
    }

    inline double pow6(const double x) {
        return gsl_pow_6(x);
    }

    inline double pow7(const double x) {
        return gsl_pow_7(x);
    }

    inline double pow8(const double x) {
        return gsl_pow_8(x);
    }

    inline double pow9(const double x) {
        return gsl_pow_9(x);
    }

    inline double poly_eval(const array<double>& d, const double x) {
        return gsl_poly_eval(d.data(),d.size(),x);
    }

    inline int poly_eval_derivs(const array<double>& d, const double x, array<double>& res) {
        return gsl_poly_eval_derivs(d.data(),d.size(),x,res.data(),res.size());
    }

    inline double erf(const double x) {
        return gsl_sf_erf(x);
    }

    inline double Ei(const double x) {
        return gsl_sf_expint_Ei(x);
    }

    inline double Ci(const double x) {
        return gsl_sf_Ci(x);
    }

    inline double Si(const double x) {
        return gsl_sf_Si(x);
    }

    inline double gamma(const double x) {
        return gsl_sf_gamma(x);
    }

    inline double fact(const int n) {
        return gsl_sf_fact(n);
    }

    inline double choose(const unsigned int n, const unsigned int m) {
        return gsl_sf_choose(n,m);
    }

    inline double taylorcoeff(const int n, const double x) {
        return gsl_sf_taylorcoeff(n,x);
    }

    inline double zeta(const double x) {
        return gsl_sf_zeta(x);
    }

    inline void convert(array<size_t>& a, gsl_permutation& perm) {
        perm.data=a.data();
        perm.size=a.size();
    }

    inline void convert(array<double>& a, gsl_matrix& A) {
        A.size1=a.rows();
        A.tda=A.size2=a.columns();
        A.data=a.data();
        A.owner=0;
    }

    inline void convert(array<double>& v, gsl_vector& V) {
        V.size=v.size();
        V.stride=1;
        V.data=v.data();
        V.owner=0;
    }

    inline void permutation_init(array<size_t>& a) {
        gsl_permutation perm;
        convert(a,perm);
        gsl_permutation_init(&perm);
    }

    inline bool permutation_swap(array<size_t>& a, uint i, uint j) {
        gsl_permutation perm;
        convert(a,perm);
        return gsl_permutation_swap(&perm,i,j)==GSL_SUCCESS;
    }

    inline bool permutation_valid(array<size_t>& a) {
        gsl_permutation perm;
        convert(a,perm);
        return gsl_permutation_valid(&perm)==GSL_SUCCESS;
    }

    inline void permutation_reverse(array<size_t>& a) {
        gsl_permutation perm;
        convert(a,perm);
        gsl_permutation_reverse(&perm);
    }

    inline bool permutation_inverse(array<size_t>& ai, array<size_t>& a) {
        gsl_permutation perm_a;
        convert(a,perm_a);
        gsl_permutation perm_ai;
        convert(ai,perm_ai);
        return gsl_permutation_inverse(&perm_ai,&perm_a)==GSL_SUCCESS;
    }

    inline bool permutation_next(array<size_t>& a) {
        gsl_permutation perm;
        convert(a,perm);
        return gsl_permutation_next(&perm)==GSL_SUCCESS;
    }

    inline bool permutation_prev(array<size_t>& a) {
        gsl_permutation perm;
        convert(a,perm);
        return gsl_permutation_prev(&perm)==GSL_SUCCESS;
    }

    inline void matrix_set_zero(array<double>& a) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix_set_zero (&A);
    }

    inline void matrix_set_identity(array<double>& a) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix_set_identity(&A);
    }

    inline void matrix_set_all(array<double>& a, double x) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix_set_all(&A,x);
    }

    inline bool matrix_swap_rows(array<double>& a, uint i, uint j) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_swap_rows(&A,i,j)==GSL_SUCCESS;
    }

    inline bool matrix_swap_columns(array<double>& a, uint i, uint j) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_swap_columns(&A,i,j)==GSL_SUCCESS;
    }

    inline bool matrix_transpose(array<double>& a) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_transpose(&A)==GSL_SUCCESS;
    }

    inline bool matrix_transpose(array<double>& a, array<double>& b) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        return gsl_matrix_transpose_memcpy(&A,&B)==GSL_SUCCESS;
    }

    inline bool matrix_add(array<double>& a, array<double>& b) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        return gsl_matrix_add(&A,&B)==GSL_SUCCESS;
    }

    inline bool matrix_sub(array<double>& a, array<double>& b) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        return gsl_matrix_sub(&A,&B)==GSL_SUCCESS;
    }

    inline bool matrix_mul_elements(array<double>& a, array<double>& b) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        return gsl_matrix_mul_elements(&A,&B)==GSL_SUCCESS;
    }

    inline bool matrix_div_elements(array<double>& a, array<double>& b) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        return gsl_matrix_div_elements(&A,&B)==GSL_SUCCESS;
    }

    inline bool matrix_scale(array<double>& a, double x) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_scale(&A,x)==GSL_SUCCESS;
    }

    inline bool matrix_add_constant(array<double>& a, double x) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_add_constant(&A,x)==GSL_SUCCESS;
    }

    inline bool matrix_add_diagonal(array<double>& a, double x) {
        gsl_matrix A;
        convert(a,A);
        return gsl_matrix_add_diagonal(&A,x)==GSL_SUCCESS;
    }

    inline int LU_decomp(array<double>& a, array<size_t>& p) {
        gsl_matrix A;
        convert(a,A);
        gsl_permutation perm;
        convert(p,perm);
        int sig;
        if(gsl_linalg_LU_decomp (&A,&perm,&sig)!=GSL_SUCCESS) sig=0;
        return sig;
    }

    inline bool LU_solve(array<double>& a, array<size_t>& p, array<double>& b, array<double>& x) {
        gsl_matrix A;
        convert(a,A);
        gsl_permutation perm;
        convert(p,perm);
        gsl_vector B,X;
        convert(b,B);
        convert(x,X);
        return gsl_linalg_LU_solve(&A,&perm,&B,&X)==GSL_SUCCESS;
    }

    inline bool LU_solve(array<double>& a, array<size_t>& p, array<double>& bx) {
        gsl_matrix A;
        convert(a,A);
        gsl_permutation perm;
        convert(p,perm);
        gsl_vector BX;
        convert(bx,BX);
        return gsl_linalg_LU_svx(&A,&perm,&BX)==GSL_SUCCESS;
    }

    inline bool LU_invert(array<double>& a, array<size_t>& p, array<double>& inv) {
        gsl_matrix A;
        convert(a,A);
        gsl_permutation perm;
        convert(p,perm);
        gsl_matrix INV;
        convert(inv,INV);
        return gsl_linalg_LU_invert(&A,&perm,&INV)==GSL_SUCCESS;
    }

    inline bool LU_refine(array<double>& a, array<double>& lu, array<size_t>& p, array<double>& b, array<double>& x, array<double>& r) {
        gsl_matrix A,LU;
        convert(a,A);
        convert(lu,LU);
        gsl_permutation perm;
        convert(p,perm);
        gsl_vector B,X,R;
        convert(b,B);
        convert(x,X);
        convert(r,R);
        return gsl_linalg_LU_refine(&A,&LU,&perm,&B,&X,&R)==GSL_SUCCESS;
    }

    inline double LU_det(array<double>& a, int sig) {
        gsl_matrix A;
        convert(a,A);
        return gsl_linalg_LU_det (&A,sig);
    }

    inline bool QR_decomp(array<double>& a, array<double>& tau) {
        gsl_matrix A;
        convert(a,A);
        gsl_vector TAU;
        convert(tau,TAU);
        return gsl_linalg_QR_decomp(&A,&TAU)==GSL_SUCCESS;
    }

    inline bool QR_solve(array<double>& qr, array<double>& tau, array<double>& b, array<double>& x) {
        gsl_matrix QR;
        convert(qr,QR);
        gsl_vector TAU,B,X;
        convert(tau,TAU);
        convert(b,B);
        convert(x,X);
        return gsl_linalg_QR_solve(&QR,&TAU,&B,&X)==GSL_SUCCESS;
    }

    inline bool QR_solve(array<double>& qr, array<double>& tau, array<double>& bx) {
        gsl_matrix QR;
        convert(qr,QR);
        gsl_vector TAU,BX;
        convert(tau,TAU);
        convert(bx,BX);
        return gsl_linalg_QR_svx(&QR,&TAU,&BX)==GSL_SUCCESS;
    }

    inline bool QR_lssolve(array<double>& qr, array<double>& tau, array<double>& b, array<double>& x, array<double>& r) {
        gsl_matrix QR;
        convert(qr,QR);
        gsl_vector TAU,B,X,R;
        convert(tau,TAU);
        convert(b,B);
        convert(x,X);
        convert(r,R);
        return gsl_linalg_QR_lssolve(&QR,&TAU,&B,&X,&R)==GSL_SUCCESS;
    }

    inline bool cholesky_decomp(array<double>& a) {
        gsl_matrix A;
        convert(a,A);
        return gsl_linalg_cholesky_decomp(&A)==GSL_SUCCESS;
    }

    inline bool cholesky_solve(array<double>& chol, array<double>& b, array<double>& x) {
        gsl_matrix CHOL;
        convert(chol,CHOL);
        gsl_vector B,X;
        convert(b,B);
        convert(x,X);
        return gsl_linalg_cholesky_solve(&CHOL,&B,&X)==GSL_SUCCESS;
    }

    inline bool cholesky_solve(array<double>& chol, array<double>& bx) {
        gsl_matrix CHOL;
        convert(chol,CHOL);
        gsl_vector BX;
        convert(bx,BX);
        return gsl_linalg_cholesky_svx(&CHOL,&BX)==GSL_SUCCESS;
    }


    inline bool eigen_symm(array<double>& a, array<double>& eval) {
        gsl_matrix A;
        gsl_vector EVAL;
        convert(a,A);
        convert(eval,EVAL);
        gsl_eigen_symm_workspace * ws=gsl_eigen_symm_alloc(a.rows());
        bool result=gsl_eigen_symm(&A, &EVAL, ws)==GSL_SUCCESS;
        if(result) gsl_sort_vector(&EVAL);
        gsl_eigen_symm_free(ws);
        return result;
    }

    inline bool eigen_symm(array<double>& a, array<double>& eval, array<double>& evec) {
        gsl_matrix A,EVEC;
        gsl_vector EVAL;
        convert(a,A);
        convert(evec,EVEC);
        convert(eval,EVAL);
        gsl_eigen_symmv_workspace * ws=gsl_eigen_symmv_alloc(a.rows());
        bool result=gsl_eigen_symmv(&A, &EVAL, &EVEC, ws)==GSL_SUCCESS;
        if(result) gsl_eigen_symmv_sort(&EVAL, &EVEC, GSL_EIGEN_SORT_VAL_ASC);
        gsl_eigen_symmv_free(ws);
        return result;
    }

};
