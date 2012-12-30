#ifndef WRAP_LAPACK_HPP
#define WRAP_LAPACK_HPP
#include "array.hpp"

extern "C" {

  void dpptrf_(char * uplo, int *n, double *ap, int *info);
	
  void spptrf_(char * uplo, int *n, float *ap, int *info);

  void dpptrs_(char * uplo, int *n, int * nrhs, double *ap,
		double * b, int * ldb, int *info);

  void spptrs_(char * uplo, int *n, int * nrhs, float *ap,
		float * b, int * ldb, int *info);

  void dspev_(char * jobz, char * uplo, int *n, double *ap,
		double * w, double * z, int * ldz, double * work, int *info);

  void sspev_(char * jobz, char * uplo, int *n, float *ap,
		float * w, float * z, int * ldz, float * work, int *info);

}
 
int pptrf(int n_, array<double>& A) {
	int n=n_;
	int info;
	char uplo='U';
	dpptrf_(&uplo,&n,A.data(),&info);
	return info;
}

int pptrf(int n_, array<float>& A) {
	int n=n_;
	int info;
	char uplo='U';
	spptrf_(&uplo,&n,A.data(),&info);
	return info;
}

int pptrs(int n_, array<double>& A, array<double>& b) {
	int n=n_;
	int info;
	char uplo='U';
	int nrhs=1;
	int ldb=n;
	dpptrs_(&uplo,&n,&nrhs,A.data(),b.data(),&ldb,&info);
	return info;
}

int pptrs(int n_, array<float>& A, array<float>& b) {
	int n=n_;
	int info;
	char uplo='U';
	int nrhs=1;
	int ldb=n;
	spptrs_(&uplo,&n,&nrhs,A.data(),b.data(),&ldb,&info);
	return info;
}

int spev(int n_, array<double>& A, array<double>& w, double * work_=0) {
	int n=n_;
	int info;
	char uplo='U';
	char jobz='N';
	int ldz=n;
	double * work;
	if(work_) work=work_;
	else work=new double[3*n];
	dspev_(&jobz,&uplo,&n,A.data(),w.data(),0,&ldz,work,&info);
	if(!work_) delete [] work;
	return info;
}

int spev(int n_, array<double>& A, array<double>& w, array<double>& z, double * work_=0) {
	int n=n_;
	int info;
	char uplo='U';
	char jobz='V';
	int ldz=n;
	double * work;
	if(work_) work=work_;
	else work=new double[3*n];
	dspev_(&jobz,&uplo,&n,A.data(),w.data(),z.data(),&ldz,work,&info);
	if(!work_) delete [] work;
	return info;
}

int spev(int n_, array<float>& A, array<float>& w, float * work_=0) {
	int n=n_;
	int info;
	char uplo='U';
	char jobz='N';
	int ldz=n;
	float * work;
	if(work_) work=work_;
	else work=new float[3*n];
	sspev_(&jobz,&uplo,&n,A.data(),w.data(),0,&ldz,work,&info);
	if(!work_) delete [] work;
	return info;
}

int spev(int n_, array<float>& A, array<float>& w, array<float>& z, float * work_=0) {
	int n=n_;
	int info;
	char uplo='U';
	char jobz='V';
	int ldz=n;
	float * work;
	if(work_) work=work_;
	else work=new float[3*n];
	sspev_(&jobz,&uplo,&n,A.data(),w.data(),z.data(),&ldz,work,&info);
	if(!work_) delete [] work;
	return info;
}

#endif // WRAP_LAPACK_HPP
