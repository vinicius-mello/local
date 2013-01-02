%module lapack
%{
#include <wrappers/lapack.hpp>
%}

int pptrf(int n_, array<double>& A);
int pptrf(int n_, array<float>& A);
int pptrs(int n_, const array<double>& A, array<double>& b);
int pptrs(int n_, const array<float>& A, array<float>& b);
int spev(int n_, array<double>& A, array<double>& w, double * work_=0);
int spev(int n_, array<double>& A, array<double>& w, array<double>& z, double * work_=0);
int spev(int n_, array<float>& A, array<float>& w, float * work_=0);
int spev(int n_, array<float>& A, array<float>& w, array<float>& z, float * work_=0);

