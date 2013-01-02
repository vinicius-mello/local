%module blzpack
%{
#include <wrappers/blzpack.hpp>
%}

enum mode {
    standard=0,
    generalized,
    generalized_buckling
};

enum status {
    error=-1,
    done=0,
    compute_opu=1,
    compute_bu=2,
    compute_shifts=3,
    compute_start_vectors=4,
    finalize=5
};

class symmetric {
    public:
        symmetric(int _n, int _nreig, mode md, double _eigl=0.0, double _eigr=1.0, 
                int _nvbset=6, double _thrsh=0.0);
        ~symmetric();
        int update(int nneig=0);
        int status() const;
        int info() const;
        int nvopu() const;
        double sigma() const;
        void reset(double _eigl=0.0, double _eigr=1.0);
        double eigenvalue(int i) const;
        array<double> eigenvector(int i) const;
        array<double> U(int i);
        array<double> V(int i);
};

