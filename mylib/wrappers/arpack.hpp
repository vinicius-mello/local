#ifndef WRAP_ARPACK_HPP
#define WRAP_ARPACK_HPP
extern "C" {

    void dsaupd_(int *ido, char *bmat, int *n, char *which,
            int *nev, double *tol, double *resid,
            int *ncv, double *V, int *ldv,
            int *iparam, int *ipntr, double *workd,
            double *workl, int *lworkl, int *info);

    void dseupd_(int * rvec, char * howmny, int * select,
            double * d, double * z, int * ldz, double * sigma,
            char *bmat, int *n, char *which,
            int *nev, double *tol, double *resid,
            int *ncv, double *V, int *ldv,
            int *iparam, int *ipntr, double *workd,
            double *workl, int *lworkl, int *info);

    void dnaupd_(int *ido, char *bmat, int *n, char *which,
            int *nev, double *tol, double *resid,
            int *ncv, double *V, int *ldv,
            int *iparam, int *ipntr, double *workd,
            double *workl, int *lworkl, int *info);

    void dneupd_(int * rvec, char * howmny, int * select,
            double * dr, double * di, double * z, int * ldz, double * sigmar, double * sigmai, double * workev,
            char *bmat, int *n, char *which,
            int *nev, double *tol, double *resid,
            int *ncv, double *V, int *ldv,
            int *iparam, int *ipntr, double *workd,
            double *workl, int *lworkl, int *info);

}

#include "array.hpp"

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
    int ido;
    char bmat;
    int n;
    char which[2];
    int nev;
    double tol;
    double * resid;
    int ncv;
    double * v;
    double * d;
    int ldv;
    int iparam[11];
    int maxitr;
    int ipntr[11];
    double * workd;
    double * workl;
    int lworkl;
    int info_;
    int rvec;
    char howmny;
    int * select;
    double sigma_;
    public:
    symmetric(int _n, int _nev, mode md, const char * _which="LM", int _maxitr=300, double _tol=0) : n(_n), nev(_nev), maxitr(_maxitr), tol(_tol) {
        //printf("symmetric\n");
        ido=0;
        ncv=2*nev+1;
        if(ncv>n-1) ncv=n-1;
        ldv=n;
        which[0]=_which[0];
        which[1]=_which[1];
        resid=new double[n];
        d=new double[nev];
        v=new double[ldv*ncv];
        lworkl=ncv*(ncv+8);
        workd=new double[3*n];
        workl=new double[lworkl];
        select=new int[ncv];
        iparam[0]=1;
        iparam[2]=maxitr;
        iparam[3]=1;
        rvec=1;
        howmny='A';
        info_=0;
        switch(md) {
            case standard_regular:
                bmat='I';
                iparam[6]=1;
                break;
            case standard_shift_invert:
                bmat='I';
                iparam[6]=3;
                break;
            case generalized_regular_inverse:
                bmat='G';
                iparam[6]=2;
                break;
            case generalized_shift_invert:
                bmat='G';
                iparam[6]=3;
                break;
            case generalized_buckling:
                bmat='G';
                iparam[6]=4;
                break;
            case generalized_cayley:
                bmat='G';
                iparam[6]=5;
                break;
        }
    }
    ~symmetric() {
        //printf("~symmetric\n");
        //printf("~symmetric: resid\n");
        delete [] resid;
        //printf("~symmetric: v\n");
        delete [] v;
        //printf("~symmetric: d\n");
        delete [] d;
        //printf("~symmetric: workd\n");
        delete [] workd;
        //printf("~symmetric: workl\n");
        delete [] workl;
        //printf("~symmetric: select\n");
        delete [] select;
    }
    int update() {
        dsaupd_(&ido,&bmat,&n,&which[0],&nev,&tol,resid,&ncv,v,&ldv,iparam,ipntr,workd,workl,&lworkl,&info_);
        return ido;
    }
    int post_process(double s=0.0) {
        sigma_=s;
        dseupd_(&rvec,&howmny,select,d,v,&ldv,&sigma_,&bmat,&n,&which[0],&nev,&tol,resid,&ncv,v,&ldv,iparam,ipntr,workd,workl,&lworkl,&info_);
        return info_;
    }
    int status() const {
        return ido;
    }
    int info() const {
        return info_;
    }
    void reset() {
        ido=0;
        info_=0;
        iparam[0]=1;
        iparam[2]=maxitr;
        iparam[3]=1;
    }
    double eigenvalue(int i) const {
        return d[i];
    }
    array<double> eigenvector(int i) const {
        array<double> b(n,&v[i*n]);
        return b;
    }
    array<double> x() {
        array<double> b(n,&workd[ipntr[0]-1]);
        return b;
    }
    array<double> y() {
        array<double> b(n,&workd[ipntr[1]-1]);
        return b;
    }
    array<double> bx() {
        array<double> b(n,&workd[ipntr[2]-1]);
        return b;
    }
};


class non_symmetric {
    int ido;
    char bmat;
    int n;
    char which[2];
    int nev;
    double tol;
    double * resid;
    int ncv;
    double * v;
    double * dr;
    double * di;
    int ldv;
    int iparam[11];
    int maxitr;
    int ipntr[14];
    double * workd;
    double * workl;
    double * workev;
    int lworkl;
    int info_;
    int rvec;
    char howmny;
    int * select;
    double sigmar_;
    double sigmai_;
    public:
    non_symmetric(int _n, int _nev, mode md, const char * _which="LM", int _maxitr=300, double _tol=0) : n(_n), nev(_nev), maxitr(_maxitr), tol(_tol) {
        ido=0;
        ncv=2*nev+2;
        ldv=n;
        which[0]=_which[0];
        which[1]=_which[1];
        resid=new double[n];
        dr=new double[nev+1];
        di=new double[nev+1];
        v=new double[ldv*ncv];
        lworkl=3*ncv*(ncv+2);
        workd=new double[3*n];
        workl=new double[lworkl];
        workev=new double[3*ncv];
        select=new int[ncv];
        iparam[0]=1;
        iparam[2]=maxitr;
        iparam[3]=1;
        rvec=1;
        howmny='A';
        info_=0;
        switch(md) {
            case standard_regular:
                bmat='I';
                iparam[6]=1;
                break;
            case standard_shift_invert:
                bmat='I';
                iparam[6]=3;
                break;
            case generalized_regular_inverse:
                bmat='G';
                iparam[6]=2;
                break;
            case generalized_shift_invert:
                bmat='G';
                iparam[6]=3;
                break;
        }
    }
    ~non_symmetric() {
        delete [] resid;
        delete [] v;
        delete [] dr;
        delete [] di;
        delete [] workev;
        delete [] workd;
        delete [] workl;
        delete [] select;
    }
    int update() {
        dnaupd_(&ido,&bmat,&n,&which[0],&nev,&tol,resid,&ncv,v,&ldv,iparam,ipntr,workd,workl,&lworkl,&info_);
        return ido;
    }
    int post_process(double sr=0.0, double si=0.0) {
        sigmar_=sr;
        sigmai_=si;
        dneupd_(&rvec,&howmny,select,dr,di,v,&ldv,&sigmar_,&sigmai_,workev,&bmat,&n,&which[0],&nev,&tol,resid,&ncv,v,&ldv,iparam,ipntr,workd,workl,&lworkl,&info_);
        return info_;
    }
    int status() const {
        return ido;
    }
    void reset() {
        ido=0;
        info_=0;
        iparam[0]=1;
        iparam[2]=maxitr;
        iparam[3]=1;
    }
    double eigenvalue_re(int i) const {
        return dr[i];
    }
    double eigenvalue_im(int i) const {
        return di[i];
    }
    array<double> eigenvector(int i) const {
        array<double> b(n,&v[i*n]);
        return b;
    }
    array<double> x() {
        array<double> b(n,&workd[ipntr[0]-1]);
        return b;
    }
    array<double> y() {
        array<double> b(n,&workd[ipntr[1]-1]);
        return b;
    }
    array<double> bx() {
        array<double> b(n,&workd[ipntr[2]-1]);
        return b;
    }
};

#endif // WRAP_ARPACK_HPP
