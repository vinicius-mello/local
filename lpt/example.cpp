#include <iostream>
#include <cstdlib>
#include "lpt.hpp"

using namespace std;

#if   DIM==2
#define CODE lpt2_32_bits
#elif DIM==3
#define CODE lpt3_64_bits
#elif DIM==4
#define CODE lpt4_48_bits
#endif

typedef lpt<DIM,CODE> lptcode;
typedef lpt_tree<lptcode> lpttree;

int main() {
    cout<<"sizeof(lptcode)="<<sizeof(lptcode)<<endl;
    lpttree tree;
    for(int i=0;i<100;++i) {
        double p[DIM];
        for(int j=0;j<DIM;++j) p[j]=(rand() % 200)/100.0-1.0;
        cout<<"Random point: ";
        for(int j=0;j<DIM;++j) cout<<p[j]<<" ";
        cout<<endl;
        lptcode c=tree.search(&p[0]);
        cout<<"Simplex :";
        c.print_simplex();
        cout<<endl;
        tree.compat_bisect(c);
        cout<<"Subdivided:"<<endl;
        do {
            cout<<tree.subdivided_id()<<" - ";
            tree.subdivided_code().print_simplex();
            cout<<endl;
        } while(tree.subdivided_next());
        cout<<"Recent:"<<endl;
        do {
            cout<<tree.recent_id()<<" - ";
            cout<<"parent: "<<tree.id(tree.recent_code().parent());
            cout<<endl;
        } while(tree.recent_next());
    }
    cout<<"Leaf nodes:"<<endl;
    tree.node_reset();
    do {
        if(tree.node_is_leaf()) {
            cout<<tree.node_id()<<" - ";
            tree.node_code().print_simplex();
            cout<<endl;
        }
    } while(tree.node_next());
}


