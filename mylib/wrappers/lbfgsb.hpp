#ifndef WRAP_LBFGSB_HPP
#define WRAP_LBFGSB_HPP

#include <string>
#include <cstring>
#include "lbfgsb.h"

using std::string;

class lbfgsb {
    int n,m;
    int max_n;
    int max_m;
    double * wa;
    int * iwa;
    char task[60];
    int iprint;
    char csave[60];
    int lsave[4];
    int isave[44];
    double dsave[29];
    double * lower, * upper;
    int * nbd;
    double * x;
    double f;
    const double * grad;
    double factr;
    double pgtol;
    public:
    lbfgsb(int _n, int _m, bool unbounded=true, double lim=1) : max_n(_n), max_m(_m) {
        wa=new double[(2*max_m + 5)*max_n + 11*max_m*max_m + 8*max_m];
        iwa=new int[3*max_n];
        lower=new double[max_n];
        upper=new double[max_n];
        nbd=new int[max_n];
        for(int i=0;i<max_n;++i) {
            lower[i]=-lim;
            upper[i]=lim;
            nbd[i]=(unbounded)?0:2;
        }
        factr=1.0e+4;
        pgtol=1.0e-5;
        iprint=-1;
    }
    ~lbfgsb() {
        delete [] wa;
        delete [] iwa;
        delete [] lower;
        delete [] upper;
        delete [] nbd;
    }
    void n_set(int i) {
        n=i;
    }
    void m_set(int i) {
        m=i;
    }
    void grad_set(const double * d) {
        grad=d;
    }
    void f_set(double d) {
        f=d;
    }
    void boundary_set(int i, int type, double l, double u) {
        lower[i]=l;
        upper[i]=u;
        nbd[i]=type;
    }
    void factr_set(double d) {
        factr=d;
    }
    void pgtol_set(double d) {
        pgtol=d;
    }
    void print_set(bool p) {
        if(p) iprint=1;
        else iprint=-1;
    }
    string start(double * init) {
        strcpy(task,"START");
        x=init;
        memset(task+5,' ',55);
        setulb_(&n,&m,x,lower,upper,nbd,&f,grad,
                &factr,&pgtol,wa,
                iwa, task, &iprint, csave,
                lsave,isave,dsave);
        return next_task();
    }
    string call() {
        setulb_(&n,&m,x,lower,upper,nbd,&f,grad,
                &factr,&pgtol,wa,
                iwa, task, &iprint, csave,
                lsave,isave,dsave);
        return next_task();
    }
    string next_task() {
        switch(task[0]) {
            case 'F': return "fg";
            case 'N': return "new_x";
            case 'C': return "conv";
            case 'A': return "abno";
            case 'E': return "error";
        }
    }
};

#endif // WRAP_LBFGSB_HPP
