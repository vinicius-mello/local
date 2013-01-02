#ifndef WRAP_MA57_HPP
#define WRAP_MA57_HPP
extern "C" {

    void ma57id_(double * cntl, int * icntl);
    void ma57ad_(int * n, int * ne, int * irn, int * jcn,
            int * lkeep, int * keep, int * iwork, int * icntl,
            int * info, double * rinfo);
    void ma57bd_(int * n, int * ne, double * a, double * fact,
            int * lfact, int * ifact, int * lifact,
            int * lkeep, int * keep, int * iwork, int * icntl,
            double * cntl, int * info, double * rinfo);
    void ma57cd_(int * job, int * n, double * fact,
            int * lfact, int * ifact, int * lifact,
            int * nhrs, double * rhs, int * lrhs,
            double * work, int * lwork, int * iwork,
            int * icntl, int * info);
    void ma57dd_(int * job, int * n, int * ne,
            double * a, int * irn, int * jcn, double * fact,
            int * lfact, int * ifact, int * lifact,
            double * rhs, double * x, double * resid,
            double * work, int * iwork,
            int * icntl, double * cntl, int * info, double * rinfo);

}
#include "array.hpp"
#include "sparse.hpp"

class ma57 {
    mutable	double * A;
    mutable double cntl[5];
    mutable int icntl[20];
    mutable int info[40];
    mutable double rinfo[20];
    mutable int n;
    mutable int ne;
    mutable int lkeep;
    mutable int * keep;
    mutable int lfact;
    mutable int lifact;
    mutable int * irn;
    mutable int * jcn;
    mutable double * fact;
    mutable int * ifact;
    mutable	double * work;
    mutable	double * resid;
    mutable	int * iwork;
    const sparse& S;
    bool alloc;
    void free() {
        if(alloc) {
            delete [] fact;
            delete [] ifact;
        }
        alloc=false;
    }
    public:
    ma57(const sparse& _S) : S(_S) {
        n=S.n();
        ne=S.nz();
        A=const_cast<double *>(S.val().data());
        ma57id_(cntl,icntl);
        icntl[5-1]=2;
        lkeep=6*n+2*ne+42;
        keep=new int[lkeep];
        iwork=new int[5*n];
        work=new double[n];
        alloc=false;
        //resid=new double[n];
    }
    ~ma57() {
        free();
        delete [] keep;
        delete [] work;
        delete [] iwork;
        //delete [] resid;
    }
    void factor() {
        free();
        irn=new int[ne];
        jcn=new int[ne];
        int * colptr=const_cast<int *>(S.col_ptr().data());
        int * rowind=const_cast<int *>(S.row_ind().data());
        for(int j=0;j<n;++j) {
            for(int k=colptr[j];k<colptr[j+1];k++) {
                int i=rowind[k];
                irn[k]=i+1;
                jcn[k]=j+1;
            }
        }
        ma57ad_(&n,&ne,irn,jcn,&lkeep,keep,iwork,icntl,info,rinfo);
        lfact=2*info[9-1];
        lifact=2*info[10-1];
        fact=new double[lfact];
        ifact=new int[lifact];
        alloc=true;
        ma57bd_(&n,&ne,A,fact,&lfact,ifact,&lifact,&lkeep,keep,iwork,icntl,cntl,info,rinfo);
        delete [] irn;
        delete [] jcn;
    }
    void solve(const array<double>& b, array<double>& x) const {
        int job=1;
        int nhrs=1;
        x.copy(b);
        int lwork=n;
        ma57cd_(&job,&n,fact,&lfact,ifact,&lifact,&nhrs,x.data(),&n,work,&lwork,
                iwork,icntl,info);

        /*   icntl[9-1]=1;
             ma57dd_(&job,&n,&ne,A,irn,jcn,fact,&lfact,ifact,&lifact,b.data(),x.data(),resid,work,iwork,icntl,cntl,info,rinfo);*/
    }
    int inertia() const {
        return info[24-1];
    }
};


#endif // WRAP_MA57_HPP
