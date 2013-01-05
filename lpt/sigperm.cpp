#include <iostream>
#include <stdio.h>
#include <algorithm>
#define ABS(x) (((x)<0) ? -(x) : (x))
#define SGN(x) (((x)<0) ? -1 : 1)

using std::next_permutation;
using std::cout;
using std::endl;

const int fact[]={1,1,2,6,24,120,720};

bool sigperm_next(int d, int * a) {
    int * perm=new int[d];
    int * refl=new int[d];
    int c=0;
    for(int i=0;i<d;++i) {
        int v=a[i];
        bool b=v<0;
        perm[i]=b? -v : v;
        refl[i]=b? -1 : 1;
        if(b) c=c+(1<<i);
    }
    c=c+1;
    for(int i=0;i<d;++i) {
        if(c&(1<<i)) refl[i]=-1;
        else refl[i]=1;
    }
    bool cont=true;
    if(c==(1<<d))
        cont=next_permutation(perm,perm+d);
    for(int i=0;i<d;++i) {
        a[i]=perm[i]*refl[i];
    }
    delete [] refl;
    delete [] perm;
    return cont;
}

bool sigperm_comp(int d, int * a, int * b) {
    bool res=true;
    for(int i=0;i<d;++i) res=res&&(a[i]==b[i]);
    return res;
}

void  sigperm_identity(int d, int * a) {
    for(int i=0;i<d;++i) a[i]=i+1;
}

int sigperm_code(int d, int * a) {
    int * b=new int[d];
    int c=0;
    sigperm_identity(d,b);
    do {
        if(sigperm_comp(d,a,b)) break;
        c++;
    } while(sigperm_next(d,b));
    delete [] b;
    return c;
}

void sigperm_action(int d, int * a, double * v) {
    double * res=new double[d];
    for(int i=0;i<d;++i) res[i]=SGN(a[i])*v[i];
    for(int i=0;i<d;++i) v[ABS(a[i])-1]=res[i];
    delete [] res;
}

void  sigperm_compose(int d, int * a, int * b, int * c) {
    for(int i=0;i<d;++i) c[i]=SGN(b[i])*a[ABS(b[i])-1];
}

void sigperm_inverse(int d, int * a, int * b) {
    int * c=new int[d];
    int * id=new int[d];
    sigperm_identity(d,id);
    sigperm_identity(d,b);
    do {
        sigperm_compose(d,a,b,c);
        if(sigperm_comp(d,c,id)) break;
    } while(sigperm_next(d,b));
    delete [] id;
    delete [] c;
}

void  sigperm_print(int d, int * a) {
    for(int i=0;i<d;++i) cout<<a[i]<<" ";
}

void  vector_print(int d, double * v) {
    for(int i=0;i<d;++i) cout<<v[i]<<" ";
}

void sigperm_lft(int d, int l, int * a) {
    for(int i=0;i<l;++i) a[i]=i+1;
    for(int i=l+1;i<d;++i) a[i]=i;
    a[l]=-d;
}

void sigperm_rgt(int d, int l, int * a) {
    for(int i=0;i<l;++i) a[i]=i+1;
    for(int i=l;i<(d-1);++i) a[i]=i+2;
    a[d-1]=-(l+1);
}

void sigperm_sigma(int d, int l, int * a) {
    sigperm_lft(d,l,a);
}

void sigperm_neg(int d, int * a) {
    sigperm_identity(d,a);
    a[0]=-a[0];
}

void sigperm_swp(int d, int i, int * a) {
    sigperm_identity(d,a);
    int t=a[i-1];
    a[i-1]=a[i];
    a[i]=t;
}

void sigperm_nsw(int d, int l, int * a) {
    sigperm_identity(d,a);
    int t=a[d-1];
    a[d-1]=-a[l-1];
    a[l-1]=-t;
}

void format_table(int dim, int * table, const char * name, int rows, int cols) {
    cout<<"const int lpt_table<"<<dim<<">::"<<name<<"["<<rows<<"]"<<"["<<cols<<"]={"<<endl;
    for(int i=0;i<rows;++i) {
        cout<<"  { ";
        for(int j=0;j<cols;++j) {
            cout<<table[cols*i+j];
            if(j!=(cols-1)) cout<<", ";
        }
        cout<<" },"<<endl;
    }
    cout<<"};"<<endl;
}

void format_array(int dim, int * table, const char * name, int rows) {
    cout<<"const int lpt_table<"<<dim<<">::"<<name<<"["<<rows<<"]={ ";
    for(int i=0;i<rows;++i) {
        cout<<table[i];
        if(i!=(rows-1)) cout<<", ";
        if(i>0&&(i%10==0)) cout<<endl<<"  ";
    }
    cout<<"};"<<endl;
}

int main(int argc, char * argv[]) {

    int d=argv[1][0]-'0';
    int nperm=fact[d];
    int nrefl=1<<d;

    int * a=new int[d];
    int * b=new int[d];
    int * c=new int[d];
    int k;

    printf("//! \\file lpt_table%d\n",d);

    int * table_sigma=new int[nperm*nrefl*d];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<d;++l) {
            sigperm_sigma(d,l,b);
            sigperm_compose(d,a,b,c);
            table_sigma[k*d+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_sigma,"sigma",nperm*nrefl,d);
    delete [] table_sigma;
    cout<<endl;

    int * table_sigma_inv=new int[nperm*nrefl*d];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<d;++l) {
            sigperm_sigma(d,l,c);
            sigperm_inverse(d,c,b);
            sigperm_compose(d,a,b,c);
            table_sigma_inv[k*d+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_sigma_inv,"sigma_inv",nperm*nrefl,d);
    delete [] table_sigma_inv;
    cout<<endl;

    int * table_lft=new int[nperm*nrefl*d];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<d;++l) {
            sigperm_lft(d,l,b);
            sigperm_compose(d,a,b,c);
            table_lft[k*d+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_lft,"lft",nperm*nrefl,d);
    delete [] table_lft;
    cout<<endl;

    int * table_rgt=new int[nperm*nrefl*d];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<d;++l) {
            sigperm_rgt(d,l,b);
            sigperm_compose(d,a,b,c);
            table_rgt[k*d+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_rgt,"rgt",nperm*nrefl,d);
    delete [] table_rgt;
    cout<<endl;

    int * table_swp=new int[nperm*nrefl*(d-1)];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<(d-1);++l) {
            sigperm_swp(d,l+1,b);
            sigperm_compose(d,a,b,c);
            table_swp[k*(d-1)+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_swp,"swp",nperm*nrefl,d-1);
    delete [] table_swp;
    cout<<endl;


    int * table_nsw=new int[nperm*nrefl*(d-1)];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int l=0;l<(d-1);++l) {
            sigperm_nsw(d,l+1,b);
            sigperm_compose(d,a,b,c);
            table_nsw[k*(d-1)+l]=sigperm_code(d,c);
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_nsw,"nsw",nperm*nrefl,d-1);
    delete [] table_nsw;
    cout<<endl;

    int * table_neg=new int[nperm*nrefl];
    k=0;
    sigperm_identity(d,a);
    sigperm_neg(d,b);
    do {
        sigperm_compose(d,a,b,c);
        table_neg[k]=sigperm_code(d,c);
        k++;
    } while(sigperm_next(d,a));
    format_array(d,table_neg,"neg",nperm*nrefl);
    delete [] table_neg;
    cout<<endl;

    int * table_sigperm=new int[nperm*nrefl*d];
    k=0;
    sigperm_identity(d,a);
    do {
        for(int i=0;i<d;++i) {
            table_sigperm[k*d+i]=a[i];
        }
        k++;
    } while(sigperm_next(d,a));
    format_table(d,table_sigperm,"sigperm",nperm*nrefl,d);
    delete [] table_sigperm;
    cout<<endl;

    int * table_inverse=new int[nperm*nrefl];
    k=0;
    sigperm_identity(d,a);
    do {
        sigperm_inverse(d,a,b);
        table_inverse[k]=sigperm_code(d,b);
        k++;
    } while(sigperm_next(d,a));
    format_array(d,table_inverse,"inverse",nperm*nrefl);
    delete [] table_inverse;
    cout<<endl;

    int * table_orth=new int[nperm*nrefl];
    k=0;
    sigperm_identity(d,a);
    do {
        sigperm_inverse(d,a,b);
        int code=0;
        for(int i=0;i<d;++i) {
            if(b[i]<0) code|=(1<<i);
        }
        table_orth[k]=code;
        k++;
    } while(sigperm_next(d,a));
    format_array(d,table_orth,"orth",nperm*nrefl);
    delete [] table_orth;
    cout<<endl;

    delete [] c;
    delete [] b;
    delete [] a;
}
