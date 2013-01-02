#ifndef WRAP_ARPACK_HPP
#define WRAP_ARPACK_HPP
extern "C" {

    void blzdrd_(int *istor, double *rstor, double *sigma,
            int *nneig, double * U, double *V,
            int *lflag, int *nvopu, double *eig, double *x);

}

#include "array.hpp"

enum mode {
    standard=0,
    generalized=1,
    generalized_buckling=2
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
    int *istor;
    double *rstor;
    double sigma_;
    int nneig;
    double *U_;
    double *V_;
    int lflag;
    int nvopu_;
    double *eig;
    double *x;
    int n;
    int nreig;
    double eigl,eigr;
    int nvbset;
    double thrsh;
    public:
    symmetric(int _n, int _nreig, mode md, double _thrsh=0.00000000000001, double _eigl=0.0, double _eigr=1.0,
            int _nvbset=6) : n(_n), nreig(_nreig), eigl(_eigl),
    eigr(_eigr), nvbset(_nvbset), thrsh(_thrsh) {
        if(nvbset>=n) nvbset=n-1;
        int listor;
        int nsteps=nreig*6;
        if(nsteps>n) nsteps=n;
        //int leig=(nreig+10<2*nreig)?(nreig+10):(2*nreig);
        int leig=(2*nreig);
        int k1,k2,k3,k4;
        if(nvbset*nsteps>0) k1=nvbset*nsteps;
        else k1=(n<180)?n:180;
        listor=123+k1*12;
        istor=new int[17+listor];
        k2=(nvbset>0)?nvbset:3;
        k4=(n<leig)?n:leig;
        k3=484+k1*(13+k1*2+k2+((k2+2)>18?(k2+2):18))+k2*k2*3+k4*2;
        int lrstor;
        if(md==standard) lrstor=n*k2*5+k3;
        else lrstor=n*(k2*6+1)+k3;
        rstor=new double[5+lrstor];
        istor[ 1-1]=n;
        istor[ 2-1]=n;
        istor[ 3-1]=nreig;
        istor[ 4-1]=leig;
        istor[ 5-1]=nvbset;
        istor[ 6-1]=nsteps;
        istor[ 7-1]=0;//nstart
        istor[ 8-1]=0;//ngeig
        istor[ 9-1]=md;
        istor[10-1]=1;//slice
        istor[11-1]=1;//purify
        istor[12-1]=0;//lprnt
        istor[13-1]=0;//lfile
        istor[14-1]=0;//lcomm
        istor[15-1]=listor;
        rstor[ 1-1]=eigl;
        rstor[ 2-1]=eigr;
        rstor[ 3-1]=thrsh;
        rstor[ 4-1]=lrstor;
        U_=new double[n*k2];
        V_=new double[n*k2];
        lflag=0;
        eig=new double[leig*2];
        x=new double[leig*n];
    }
    ~symmetric() {
        delete [] x;
        delete [] eig;
        delete [] V_;
        delete [] U_;
        delete [] rstor;
        delete [] istor;
    }
    int update(int nneig=0) {
        blzdrd_(istor,rstor,&sigma_,&nneig,U_,V_,&lflag,&nvopu_,eig,x);
        return lflag;
    }
    int status() const {
        return lflag;
    }
    int info() const {
        return istor[15];
    }
    int nvopu() const {
        return nvopu_;
    }
    double sigma() const {
        return sigma_;
    }
    void reset(double _eigl=0.0, double _eigr=1.0) {
        eigl=_eigl;
        eigr=_eigr;
        rstor[ 1-1]=eigl;
        rstor[ 2-1]=eigr;
        lflag=0;
    }
    double eigenvalue(int i) const {
        return eig[i];
    }
    array<double> eigenvector(int i) const {
        array<double> b(n,&x[i*n]);
        return b;
    }
    array<double> U(int i) {
        array<double> b(n,&U_[i*n]);
        return b;
    }
    array<double> V(int i) {
        array<double> b(n,&V_[i*n]);
        return b;
    }
};


#endif // WRAP_ARPACK_HPP
