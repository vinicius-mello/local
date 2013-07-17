#ifndef WRAP_GSL_HPP
#define WRAP_GSL_HPP

#include <iostream>
#include "array.hpp"
#include <gsl/gsl_blas.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_poly.h>
#include <gsl/gsl_sf.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_sort_vector.h>
#include <gsl/gsl_multiroots.h>
#define GSL_DISABLE_DEPRECATED 1
#include <gsl/gsl_wavelet.h>
#include <gsl/gsl_wavelet2d.h>
#include <gsl/gsl_complex.h>
#include <gsl/gsl_complex_math.h>
#include <gsl/gsl_fft_complex.h>

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


    inline bool matrix_mul(array<double>& a, array<double>& b,
      array<double>& c) {
        gsl_matrix A;
        convert(a,A);
        gsl_matrix B;
        convert(b,B);
        gsl_matrix C;
        convert(c,C);
        return gsl_blas_dgemm (CblasNoTrans, CblasNoTrans,
                  1.0, &A, &B,
                  0.0, &C)==GSL_SUCCESS;
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


    enum wavelet_type {
        daubechies,
        daubechies_centered,
        haar,
        haar_centered,
        bspline,
        bspline_centered
    };

    class dwt {
        gsl_wavelet * w;
        gsl_wavelet_workspace * work;
        size_t n;
        public:
        dwt(wavelet_type t, size_t k) {
            const gsl_wavelet_type * T;
            switch(t) {
                case daubechies:
                    T=gsl_wavelet_daubechies;
                    break;
                case daubechies_centered:
                    T=gsl_wavelet_daubechies_centered;
                    break;
                case haar:
                    T=gsl_wavelet_haar;
                    break;
                case haar_centered:
                    T=gsl_wavelet_haar_centered;
                    break;
                case bspline:
                    T=gsl_wavelet_bspline;
                    break;
                case bspline_centered:
                    T=gsl_wavelet_bspline_centered;
                    break;
            }
            w=gsl_wavelet_alloc(T,k);
            work=0;
            n=0;
        }
        ~dwt() {
            if(n) gsl_wavelet_workspace_free(work);
            gsl_wavelet_free(w);
        }
        int forward(array<double>& a) {
            size_t n_=a.size();
            if(n_!=n) {
                if(n) gsl_wavelet_workspace_free(work);
                n=n_;
                work=gsl_wavelet_workspace_alloc(n);
            }
            return gsl_wavelet_transform_forward(w,a.data(),1,n,work);
        }
        int inverse(array<double>& a) {
            size_t n_=a.size();
            if(n_!=n) {
                if(n) gsl_wavelet_workspace_free(work);
                n=n_;
                work=gsl_wavelet_workspace_alloc(n);
            }
            return gsl_wavelet_transform_inverse(w,a.data(),1,n,work);
        }
        int forward2d(array<double>& a) {
            size_t n_=a.width();
            if(n_!=n) {
                if(n) gsl_wavelet_workspace_free(work);
                n=n_;
                work=gsl_wavelet_workspace_alloc(n);
            }
            return gsl_wavelet2d_transform_forward(w,a.data(),n,n,n,work);
        }
        int inverse2d(array<double>& a) {
            size_t n_=a.width();
            if(n_!=n) {
                if(n) gsl_wavelet_workspace_free(work);
                n=n_;
                work=gsl_wavelet_workspace_alloc(n);
            }
            return gsl_wavelet2d_transform_inverse(w,a.data(),n,n,n,work);
        }
    };


    class dct {
        size_t length;
        double * signal_workspace;
        gsl_complex *forward_weights;
        gsl_complex *inverse_weights;
        gsl_fft_complex_wavetable *wavetable;
        gsl_fft_complex_workspace *workspace;
        public:
        dct(size_t l) : length(l) {
            forward_weights=new gsl_complex[length];
            inverse_weights=new gsl_complex[length];

            for (int n = 0; n < length; n++)
                forward_weights[n] =
                    gsl_complex_div_real(
                            gsl_complex_exp(gsl_complex_rect(0, (-n)*M_PI/2/length)),
                            sqrt(2.0 * length));
            forward_weights[0] =
                gsl_complex_div_real(forward_weights[0], M_SQRT2);

            for (int n = 0; n < length; n++)
                inverse_weights[n] =
                    gsl_complex_mul_real(gsl_complex_exp(gsl_complex_rect(0,
                                    n*M_PI/2/length)),
                            sqrt(2.0 * length));
            inverse_weights[0] =
                gsl_complex_div_real(inverse_weights[0], M_SQRT2);

            signal_workspace = new double[length * 4];
            wavetable = gsl_fft_complex_wavetable_alloc(length * 2);
            workspace = gsl_fft_complex_workspace_alloc(length * 2);
        }
        ~dct() {
            delete [] signal_workspace;
            delete [] forward_weights;
            delete [] inverse_weights;
            gsl_fft_complex_wavetable_free(wavetable);
            gsl_fft_complex_workspace_free(workspace);
        }
        int forward(const array<double>& input, array<double>& output) {
            int ret;
            for(size_t i=0;i<4*length;++i) signal_workspace[i]=0;
            for (size_t index = 0; index < length; index++)
            {
                signal_workspace[2 * index] = input.get(index);
                signal_workspace[2 * index + length * 2] =
                    input.get(length - index - 1);
            }

            ret= gsl_fft_complex_forward((gsl_complex_packed_array)
                    signal_workspace,
                    1,
                    length * 2,
                    wavetable,
                    workspace);
            for (size_t index = 0; index < length; index++)
                output.set(index,
                        GSL_REAL(gsl_complex_mul(
                                gsl_complex_rect(signal_workspace [2 * index],
                                    signal_workspace [2 * index + 1]),
                                forward_weights[index])));
            return ret;
        }
        int inverse(const array<double>& input, array<double>& output) {
            int ret;
            gsl_complex temp_value;
            for(size_t i=0;i<4*length;++i) signal_workspace[i]=0;
            for (size_t index = 0; index < length; index++)
            {
                temp_value =
                    gsl_complex_mul(gsl_complex_rect(input.get(index), 0),
                            inverse_weights[index]);
                signal_workspace[2 * index] = GSL_REAL(temp_value);
                signal_workspace[2 * index + 1] = GSL_IMAG(temp_value);
            }
            signal_workspace[0] *= 2;
            signal_workspace[1] *= 2;

            for (size_t index = 0; index < length - 1; index++)
            {
                temp_value =
                    gsl_complex_mul(gsl_complex_rect(0,
                                -input.get(length -
                                    index - 1) ),
                            inverse_weights[index + 1]);
                signal_workspace[2 * (index + length) + 2] =
                    GSL_REAL(temp_value);
                signal_workspace[2 * (index + length) + 3] =
                    GSL_IMAG(temp_value);
            }

            ret=gsl_fft_complex_inverse((gsl_complex_packed_array)
                    signal_workspace,
                    1,
                    length * 2,
                    wavetable,
                    workspace);

            for (size_t index = 0; index < length; index ++)
                output.set(index, signal_workspace[2 * index]);
            return ret;
        }
        int forward2d(const array<double>& input, array<double>& output) {
            array<double> temp(length);
            array<double> temp2(length);
            for(int i=0;i<length;++i) {
                array<double> out(output.row(i));
                array<double> in(input.row(i));
                forward(in,out);
            }
            for(int j=0;j<length;++j) {
                for(int i=0;i<length;++i)
                    temp.set(i,output.get(i,j));
                forward(temp,temp2);
                for(int i=0;i<length;++i)
                    output.set(i,j,temp2.get(i));
            }
            return GSL_SUCCESS;
        }
        int inverse2d(const array<double>& input, array<double>& output) {
            array<double> temp(length);
            array<double> temp2(length);
            for(int i=0;i<length;++i) {
                array<double> out(output.row(i));
                array<double> in(input.row(i));
                inverse(in,out);
            }
            for(int j=0;j<length;++j) {
                for(int i=0;i<length;++i)
                    temp.set(i,output.get(i,j));
                inverse(temp,temp2);
                for(int i=0;i<length;++i)
                    output.set(i,j,temp2.get(i));
            }
            return GSL_SUCCESS;
        }
    };

};

#endif // WRAP_GSL_HPP
