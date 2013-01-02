%module lbfgsb
%{
#include <wrappers/lbfgsb.hpp>
%}
%include <std_string.i>

using std::string;

class lbfgsb {
    public:
        lbfgsb(int _n, int _m, bool unbounded=true, double lim=1);
        ~lbfgsb();
        void n_set(int i);
        void m_set(int i);
        void grad_set(double * d);
        void f_set(double d);
        void boundary_set(int i, int type, double l, double u); 
        void factr_set(double d); 
        void pgtol_set(double d);
        void print_set(bool p);
        string start(double * init); 
        string call();
};

