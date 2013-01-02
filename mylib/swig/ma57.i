%module ma57
%{
#include <wrappers/ma57.hpp>
%}

class ma57 {
    public:
        ma57(const sparse& _S);
        ~ma57();
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
        int inertia() const;
};


