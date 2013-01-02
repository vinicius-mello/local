%module triplets

%{
#include <wrappers/triplets.hpp>
%}

class triplets {
    public:
        triplets();
        bool exists(int i, int j) const;
        double get(int i, int j) const;
        double get(int i) const;
        void set(int i, int j, double v);
        void set(int i, double v);
        void add_to(int i, int j, double v);
        void iter_reset();
        void iter_next();
        bool iter_end() const;
        int iter_i() const;
        int iter_j() const;
        double iter_v() const;
        int n() const;
        int m() const;
        int size() const;
        void fill(sparse& s) const;
};


