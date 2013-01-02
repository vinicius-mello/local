#ifndef WRAP_MA47_HPP
#define WRAP_MA47_HPP
extern "C" {

    void ma47id_(double * cntl, int * icntl);
    void ma47ad_(int * n, int * ne, int * irn, int * jcn,
            int * iw, int * liw, int * keep, int * icntl,
            double * rinfo, int * info);
    void ma47bd_(int * n, int * ne, int * jcn,
            double * a, int * la, int * iw, int *liw, int * keep, double * cntl, int * icntl,
            int * iw1, double * rinfo, int * info);
    void ma47cd_(int * n, double * a,
            int * la, int * iw, int * liw, double * w, double * rhs, int * iw1,
            int * icntl);

}
#include "array.hpp"
#include "sparse.hpp"

class ma47 {
    mutable	double * A;
    mutable	int la;
    mutable double cntl[2];
    mutable int icntl[7];
    mutable int info[24];
    mutable double rinfo[4];
    mutable int n;
    mutable int ne;
    mutable int * keep;
    mutable int * irn;
    mutable int * jcn;
    mutable	double * w;
    mutable int liw;
    mutable	int * iw;
    mutable	int * iw1;
    const sparse& S;
    bool alloc;
    void free() {
        if(alloc) {
            delete [] A;
            delete [] iw;
        }
        alloc=false;
    }
    public:
    ma47(const sparse& _S) : S(_S) {
        n=S.n();
        ne=S.nz();
        ma47id_(cntl,icntl);
        icntl[3-1]=2;
        keep=new int[ne+5*n+2];
        w=new double[n];
        iw1=new int[2*n+2];
        alloc=false;
    }
    ~ma47() {
        free();
        delete [] keep;
        delete [] w;
        delete [] iw1;
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
                //		printf("%d,%d\n",i+1,j+1);
            }
        }
        liw=3*ne+6*n+4;
        iw=new int[liw];
        ma47ad_(&n,&ne,irn,jcn,iw,&liw,keep,icntl,rinfo,info);
        delete [] iw;
        delete [] irn;
        la=2*info[6-1];
        liw=2*info[7-1];
        A=new double[la];
        iw=new int[liw];
        for(int k=0;k<ne;++k) {
            A[k]=(S.val().data())[k];
            //printf("%f\n",A[k]);
        }
        alloc=true;
        ma47bd_(&n,&ne,jcn,A,&la,iw,&liw,keep,cntl,icntl,iw1,rinfo,info);
        delete [] jcn;
    }
    void solve(const array<double>& b, array<double>& x) const {
        x.copy(b);
        ma47cd_(&n,A,&la,iw,&liw,w,x.data(),iw1,icntl);
    }
    int inertia() const {
        return info[23-1];
    }
};


#endif // WRAP_MA47_HPP
