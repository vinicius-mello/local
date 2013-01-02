%module arpack
%{
#include <wrappers/arpack.hpp>
%}

enum mode {
  standard_regular=1,
    standard_shift_invert,
    generalized_regular_inverse,
    generalized_shift_invert,
    generalized_buckling,
    generalized_cayley
};

enum status {
    init=0,
    compute_opx=-1,
    compute_opx_with_bx=1,
    compute_bx=2,
    compute_shifts=3,
    done=99
};

class symmetric {
public:
      symmetric(int _n, int _nev, mode md, char * _which="LM", int maxitr=300, double _tol=0);
    ~symmetric();
    int update();
    int post_process(double s=0.0);
    int status() const;
    int info() const;
    void reset();
    double eigenvalue(int i) const;
    array<double> eigenvector(int i) const;
    array<double> x();
    array<double> y();
    array<double> bx();
};

class non_symmetric {
public:
    non_symmetric(int _n, int _nev, mode md, char * _which="LM", int maxitr=300, double _tol=0);
    ~non_symmetric();
    int update();
    int post_process(double sr=0.0, double si=0.0);
    int status() const;
    void reset();
    double eigenvalue_re(int i) const;
    double eigenvalue_im(int i) const;
    array<double> eigenvector(int i) const;
    array<double> x();
    array<double> y();
    array<double> bx();
};


