%module blas
%{
#include <wrappers/blas.hpp>
%}

double dot(const array<double>& x, const array<double>& y);
float dot(const array<float>& x, const array<float>& y);
void axpy(double a, const array<double>& x, array<double>& y);
void axpy(float a, const array<float>& x, array<float>& y);
void copy(int n, const array<double>& x, array<double>& y);
void copy(const array<double>& x, array<double>& y);
void copy(int n, const array<float>& x, array<float>& y);
void copy(const array<float>& x, array<float>& y);
void swap(array<double>& x, array<double>& y);
void swap(array<float>& x, array<float>& y);
double nrm2(const array<double>& x);
float nrm2(const array<float>& x);
int imax(const array<double>& x);
int imax(const array<float>& x);
void scal(double a, array<double>& x);
void scal(float a, array<float>& x);
void gemv(double alpha, const array<double>& A, 
        const array<double>& x, double beta, array<double>& y);
void gemv(float alpha, const array<float>& A, 
        const array<float>& x, float beta, array<float>& y);
void gemm(double alpha, const array<double>& A, const array<double>& B,
        double beta, array<double>& C, bool trans=false);
void gemm(float alpha, const array<float>& A, const array<float>& B,
        float beta, array<float>& C, bool trans=false);

