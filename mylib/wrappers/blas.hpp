#ifndef WRAP_BLAS_HPP
#define WRAP_BLAS_HPP
#include "array.hpp"

extern "C" {

  double ddot_(int *n, double *dx, int *incx,
    double *dy, int *incy);
	
  float sdot_(int *n, float *dx, int *incx,
    float *dy, int *incy);
	
  void daxpy_(int *n, double * da, double *dx, int *incx,
    double *dy, int *incy);
	
  void saxpy_(int *n, float * da, float *dx, int *incx,
    float *dy, int *incy);
	
  void dcopy_(int *n, double *dx, int *incx,
    double *dy, int *incy);
	
  void scopy_(int *n, float *dx, int *incx,
    float *dy, int *incy);
	
  void dswap_(int *n, double *dx, int *incx,
    double *dy, int *incy);
	
  void sswap_(int *n, float *dx, int *incx,
    float *dy, int *incy);
	
  double dnrm2_(int *n, double *dx, int *incx);
	
  float snrm2_(int *n, float *dx, int *incx);
	
  void dscal_(int *n, double *a, double *dx, int *incx);

  int isamax_(int *n, float *dx, int *incx);
	
  int idamax_(int *n, double *dx, int *incx);

  void sscal_(int *n, float *a, float *dx, int *incx);

  void dgemv_(char * t, int *m, int *n, double *alpha, double *a, int *lda,
	  double *x, int *incx, double *beta, double *y, int *incy);
	
  void sgemv_(char * t, int *m, int *n, float *alpha, float *a, int *lda,
	  float *x, int *incx, float *beta, float *y, int *incy);
	
  void dgemm_(char * ta, char *tb, int *m, int *n, int *k, double *alpha, double *a, 
	  int *lda, double *b, int *ldb, double *beta, double *c, int *ldc);
	
  void sgemm_(char * ta, char *tb, int *m, int *n, int *k, float *alpha, float *a, 
	  int *lda, float *b, int *ldb, float *beta, float *c, int *ldc);
	
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

void copy(const array<double>& x, array<double>& y) {
  int incx=1;
	int incy=1;
	int n=x.size();
  dcopy_(&n,x.data(),&incx,y.data(),&incy);
}

void copy(const array<float>& x, array<float>& y) {
  int incx=1;
	int incy=1;
	int n=x.size();
  scopy_(&n,x.data(),&incx,y.data(),&incy);
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

double nrm2(array<double>& x) {
  int incx=1;
	int n=x.size();
  return dnrm2_(&n,x.data(),&incx);
}

float nrm2(array<float>& x) {
  int incx=1;
	int n=x.size();
  return snrm2_(&n,x.data(),&incx);
}

int imax(array<double>& x) {
  int incx=1;
	int n=x.size();
  return idamax_(&n,x.data(),&incx);
}

int imax(array<float>& x) {
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
