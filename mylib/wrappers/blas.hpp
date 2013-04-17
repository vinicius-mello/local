#ifndef WRAP_BLAS_HPP
#define WRAP_BLAS_HPP
#include "array.hpp"

extern "C" {

    double ddot_(const int *n, const double *dx, const int *incx,
            const double *dy, const int *incy);

    float sdot_(const int *n, const float *dx, const int *incx,
            const float *dy, const int *incy);

    void daxpy_(const int *n, const double * da, const double *dx, const int *incx,
            double *dy, const int *incy);

    void saxpy_(const int *n, const float * da, const float *dx, const int *incx,
            float *dy, const int *incy);

    void dcopy_(const int *n, const double *dx, const int *incx,
            double *dy, const int *incy);

    void scopy_(const int *n, const float *dx, const int *incx,
            float *dy, const int *incy);

    void dswap_(const int *n, double *dx, const int *incx,
            double *dy, const int *incy);

    void sswap_(const int *n, float *dx, const int *incx,
            float *dy, const int *incy);

    double dnrm2_(const int *n, const double *dx, const int *incx);

    float snrm2_(const int *n, const float *dx, const int *incx);

    void dscal_(const int *n, const double *a, double *dx, const int *incx);

    int isamax_(const int *n, const float *dx, const int *incx);

    int idamax_(const int *n, const double *dx, const int *incx);

    void sscal_(const int *n, const float *a, float *dx, const int *incx);

    void dgemv_(const char * t, const int *m, const int *n, const double *alpha, const double *a, const int *lda,
            const double *x, const int *incx, const double *beta, double *y, const int *incy);

    void sgemv_(const char * t, const int *m, const int *n, const float *alpha, const float *a, const int *lda,
            const float *x, const int *incx, const float *beta, float *y, const int *incy);

    void dgemm_(const char * ta, const char *tb, const int *m, const int *n, const int *k, const double *alpha, const double *a,
            const int *lda, const double *b, const int *ldb, const double *beta, double *c, const int *ldc);

    void sgemm_(const char * ta, const char *tb, const int *m, const int *n, const int *k, const float *alpha, const float *a,
            const int *lda, const float *b, const int *ldb, const float *beta, float *c, const int *ldc);

}

double dot(const array<double>& x, const array<double>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    return ddot_(&n,x.data(),&incx,y.data(),&incy);
}

float dot(const array<float>& x, const array<float>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    return sdot_(&n,x.data(),&incx,y.data(),&incy);
}

void axpy(double a, const array<double>& x, array<double>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    daxpy_(&n,&a,x.data(),&incx,y.data(),&incy);
}

void axpy(float a, const array<float>& x, array<float>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    saxpy_(&n,&a,x.data(),&incx,y.data(),&incy);
}

void copy(int n, const array<double>& x, array<double>& y) {
    int incx=1;
    int incy=1;
    dcopy_(&n,x.data(),&incx,y.data(),&incy);
}

void copy(const array<double>& x, array<double>& y) {
    int n=x.size();
    copy(n,x,y);
}

void copy(int n, const array<float>& x, array<float>& y) {
    int incx=1;
    int incy=1;
    scopy_(&n,x.data(),&incx,y.data(),&incy);
}

void copy(const array<float>& x, array<float>& y) {
    int n=x.size();
    copy(n,x,y);
}

void swap(array<double>& x, array<double>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    dswap_(&n,x.data(),&incx,y.data(),&incy);
}

void swap(array<float>& x, array<float>& y) {
    int incx=1;
    int incy=1;
    int n=x.size();
    sswap_(&n,x.data(),&incx,y.data(),&incy);
}

double nrm2(const array<double>& x) {
    int incx=1;
    int n=x.size();
    return dnrm2_(&n,x.data(),&incx);
}

float nrm2(const array<float>& x) {
    int incx=1;
    int n=x.size();
    return snrm2_(&n,x.data(),&incx);
}

int imax(const array<double>& x) {
    int incx=1;
    int n=x.size();
    return idamax_(&n,x.data(),&incx);
}

int imax(const array<float>& x) {
    int incx=1;
    int n=x.size();
    return isamax_(&n,x.data(),&incx);
}

void scal(double a, array<double>& x) {
    int incx=1;
    int n=x.size();
    dscal_(&n,&a,x.data(),&incx);
}

void scal(float a, array<float>& x) {
    int incx=1;
    int n=x.size();
    sscal_(&n,&a,x.data(),&incx);
}

void gemv(double alpha, const array<double>& A,
        const array<double>& x, double beta, array<double>& y) {
    int incx=1;
    int incy=1;
    int m=A.rows();
    int n=A.columns();
    char t='T';
    dgemv_(&t,&n,&m,&alpha,A.data(),&n,x.data(),&incx,&beta,y.data(),&incy);
}

void gemv(float alpha, const array<float>& A,
        const array<float>& x, float beta, array<float>& y) {
    int incx=1;
    int incy=1;
    int m=A.rows();
    int n=A.columns();
    char t='T';
    sgemv_(&t,&n,&m,&alpha,A.data(),&n,x.data(),&incx,&beta,y.data(),&incy);
}

void gemm(double alpha, const array<double>& A, const array<double>& B,
        double beta, array<double>& C, bool trans=false) {
    int m=A.rows();
    int n=A.columns();
    int k=B.columns();
    char ta='N';
    char tb='N';
    if(trans) {
        ta='T';
        dgemm_(&tb,&ta,&k,&n,&m,&alpha,B.data(),&k,A.data(),&n,&beta,C.data(),&k);
    } else
        dgemm_(&tb,&ta,&k,&m,&n,&alpha,B.data(),&k,A.data(),&n,&beta,C.data(),&k);
}

void gemm(float alpha, const array<float>& A, const array<float>& B,
        float beta, array<float>& C, bool trans=false) {
    int m=A.rows();
    int n=A.columns();
    int k=B.columns();
    char ta='N';
    char tb='N';
    if(trans) {
        ta='T';
        sgemm_(&tb,&ta,&k,&n,&m,&alpha,B.data(),&k,A.data(),&n,&beta,C.data(),&k);
    } else
        sgemm_(&tb,&ta,&k,&m,&n,&alpha,B.data(),&k,A.data(),&n,&beta,C.data(),&k);
}

#endif // WRAP_BLAS_HPP
