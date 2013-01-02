#ifndef WRAP_SPARSE_HPP
#define WRAP_SPARSE_HPP
#include "array.hpp"

class sparse {
    bool alloc;
    int * Ap;
    int * Ai;
    double * Ax;
    int n_,m_,nz_;
    bool sym_;
    public:
    sparse(int _m, int _n, int _nz, bool _sym=false) : m_(_m), n_(_n), nz_(_nz),
    sym_(_sym), alloc(true) {
        debug_print("sparse new(%p): alloc?%d\n",this,alloc?1:0);
        Ap=new int[n_+1];
        Ai=new int[nz_];
        Ax=new double[nz_];
    }
    sparse() : m_(0), n_(0), nz_(0), sym_(false), alloc(false) {
        debug_print("sparse default(%p): alloc?%d\n",this,alloc?1:0);
        Ap=0;
        Ai=0;
        Ax=0;
    }
    sparse(const sparse& b) : m_(b.m_), n_(b.n_), nz_(b.nz_), sym_(b.sym_), alloc(false) {
        debug_print("sparse copy_cons(%p): alloc?%d\n",this,alloc?1:0);
        Ap=b.Ap;
        Ai=b.Ai;
        Ax=b.Ax;
    }
    sparse& operator=(const sparse& b) {
        debug_print("sparse attrib(%p)=(%p): alloc?%d\n",this,&b,alloc?1:0);
        if(alloc) copy(b);
        else {
            Ap=b.Ap;
            Ai=b.Ai;
            Ax=b.Ax;
        }
        sym_=b.sym_;
        n_=b.n_;
        m_=b.m_;
        nz_=b.nz_;
        return (*this);
    }
    void ijv_col(array<int> ai, array<int> aj, array<double> av) {
        size_t idx=0;
        size_t col=0;
        for(size_t i=0;i<av.size();++i) {
            Ax[i]=av[i];
            Ai[i]=ai[i];
            if(aj[i]!=col) {
                Ap[col]=idx;
                col++;
                idx=i;
            }
        }
        Ap[col]=idx;
        Ap[col+1]=av.size();
    }
    ~sparse() {
        if(alloc) {
            delete [] Ap;
            delete [] Ai;
            delete [] Ax;
        }
        debug_print("~sparse(%p): alloc?%d\n",this,alloc?1:0);
    }
    double get(int i, int j) const {
        if(sym_ && i<j) { int t=i;i=j;j=t;}
        for(int k=Ap[j];k<Ap[j+1];k++) {
            if(i==Ai[k]) return Ax[k];
        }
        return 0.0;
    }
    double set(int i, int j, double v) {
        if(sym_ && i<j) { int t=i;i=j;j=t;}
        for(int k=Ap[j];k<Ap[j+1];k++) {
            if(i==Ai[k]) {
                Ax[k]=v;
                break;
            }
        }
        return v;
    }
    void report() const {
        for(int i=0;i<n_;++i) {
            printf("|");
            for(int j=0;j<m_;++j) {
                printf("  %8.4f",get(i,j));
            }
            printf("  |\n");
        }
        printf("\n");
    }
    void diag(array<int>& d) const {
        for(int j=0;j<n_;++j) {
            for(int k=Ap[j];k<Ap[j+1];k++) {
                int i=Ai[k];
                if(i==j) {
                    d.set(j,k);
                    break;
                }
                d.set(j,-1);
            }
        }
    }
    void shift(double sigma, const array<int>& diag) {
        for(int j=0;j<n_;++j) {
            int k=diag.get(j);
            if(k>=0) Ax[k]-=sigma;
            else printf("invalid shift\n");
        }
    }
    void shift(double sigma, const array<int>& diag, const array<double>& d) {
        for(int j=0;j<n_;++j) {
            int k=diag.get(j);
            if(k>=0) Ax[k]-=sigma*d.get(j);
            else printf("invalid shift\n");
        }
    }
    void shift_same(double sigma, const sparse& s) {
        for(int k=0;k<nz_;++k) Ax[k]-=sigma*s.Ax[k];
    }
    void copy(const sparse& s) {
        for(int j=0;j<(n_+1);++j) Ap[j]=s.Ap[j];
        for(int k=0;k<nz_;++k) Ai[k]=s.Ai[k];
        for(int k=0;k<nz_;++k) Ax[k]=s.Ax[k];
    }
    void times(const array<double>& x, array<double>& y) const {
        for (int i=0; i<m_; i++) y.set(i,0.0);
        for (int j=0; j<n_; j++) {
            double xj=x.get(j);
            for(int k=Ap[j];k<Ap[j+1];k++) {
                int i = Ai[k];
                double mij= Ax[k];
                y.set(i,y.get(i)+mij*xj);
            }
        }
        if(sym_) {
            for (int i=0; i<n_; i++) {
                double t=y.get(i);
                for(int k=Ap[i];k<Ap[i+1];k++) {
                    int j = Ai[k];
                    if(i==j) continue;
                    double mji= Ax[k];
                    t+=mji*x.get(j);
                }
                y.set(i,t);
            }
        }
    }
    int n() const {
        return n_;
    }
    int m() const {
        return m_;
    }
    int nz() const {
        return nz_;
    }
    bool sym() const {
        return sym_;
    }
    array<int> col_ptr() {
        return array<int>(n()+1,Ap);
    }
    array<int> row_ind() {
        return array<int>(nz(),Ai);
    }
    array<double> val() {
        return array<double>(nz(),Ax);
    }
    const array<int> col_ptr() const {
        return array<int>(n()+1,Ap);
    }
    const array<int> row_ind() const {
        return array<int>(nz(),Ai);
    }
    const array<double> val() const {
        return array<double>(nz(),Ax);
    }
};


#endif // WRAP_SPARSE_HPP
