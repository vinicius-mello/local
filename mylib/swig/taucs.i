%module taucs
%{
#include <wrappers/taucs.hpp>
%}

struct taucs_options {
    int approximate_sg; 
    int approximate_amwb;
    double approximate_amwb_randomseed; 
    double approximate_amwb_subgraphs; 
    int factor; 
    int factor_symbolic; 
    int factor_numeric; 
    int factor_LLT; 
    int factor_LU; 
    int factor_mf; 
    int factor_ll; 
    char * factor_ordering; 
    double maxdepth; 
    int ooc; 
    char * ooc_basename; 
    double ooc_memory; 
    int solve_cg; 
    int solve_minres; 
    double solve_maxits; 
    double solve_convergetol; 
};

class taucs {
    public:
        taucs(const sparse& _S, int flags=(TAUCS_DOUBLE|TAUCS_SYMMETRIC|TAUCS_LOWER)); 
        ~taucs();
        void set_options(const taucs_options& opt);
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
};

class taucs_ldlt {
    public:
        taucs_ldlt(const sparse& _S, int flags=(TAUCS_DOUBLE|TAUCS_SYMMETRIC|TAUCS_LOWER));
        ~taucs_ldlt();
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
        int inertia() const;
};


