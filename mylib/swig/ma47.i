%module ma47
%{
#include <wrappers/ma47.hpp>
%}

class ma47 {
    public:
        ma47(const sparse& _S);
        ~ma47();
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
        int inertia() const;
};


