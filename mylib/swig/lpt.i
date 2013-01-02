%module lpt
%{
#include <lpt/lpt.hpp>
typedef lpt<2,lpt2_32_bits> lpt2d;
typedef lpt<3,lpt3_64_bits> lpt3d;
typedef lpt_tree<lpt2d> lpt2d_tree;
typedef lpt_tree<lpt3d> lpt3d_tree;
%}

class lpt2d {
    public:
        lpt2d();
        lpt2d(int sigperm);
        bool is_root() const;
        int level() const;
        int orientation() const;
        lpt2d child(int zo) const;
        bool is_child0() const;
        lpt2d parent() const;
        bool neighbor(int i, lpt2d& r) const;
        void print() const;
        void simplex(double * s) const;
        void print_simplex() const;
};

class lpt2d_tree {
    public:
        lpt2d_tree(); 
        bool exists(const lpt2d& r) const;
        bool is_leaf(const lpt2d& r) const;
        bool neighbor(const lpt2d& r, int i, lpt2d& n) const;
        void compat_bisect(const lpt2d& r);
        lpt2d find_root(double * p, double * w) const;
        lpt2d search(double * p) const;
        lpt2d search(double * p, double * w) const;
        void node_reset();
        bool node_next();
        bool node_is_leaf() const;
        lpt2d node_code() const;
        int node_id() const;
        int id(const lpt2d& r) const;
        bool recent_next();
        lpt2d recent_code() const;
        int recent_id() const;
        bool subdivided_next();
        lpt2d subdivided_code() const;
        int subdivided_id() const;
};

class lpt3d {
    public:
        lpt3d();
        lpt3d(int sigperm);
        bool is_root() const;
        int level() const;
        int orientation() const;
        lpt3d child(int zo) const;
        bool is_child0() const;
        lpt3d parent() const;
        bool neighbor(int i, lpt3d& r) const;
        void print() const;
        void simplex(double * s) const;
        void print_simplex() const;
};

class lpt3d_tree {
    public:
        lpt3d_tree(); 
        bool exists(const lpt3d& r) const;
        bool is_leaf(const lpt3d& r) const;
        bool neighbor(const lpt3d& r, int i, lpt3d& n) const;
        void compat_bisect(const lpt3d& r);
        lpt3d find_root(double * p, double * w) const;
        lpt3d search(double * p) const;
        lpt3d search(double * p, double * w) const;
        void node_reset();
        bool node_next();
        bool node_is_leaf() const;
        lpt3d node_code() const;
        int node_id() const;
        int id(const lpt3d& r) const;
        bool recent_next();
        lpt3d recent_code() const;
        int recent_id() const;
        bool subdivided_next();
        lpt3d subdivided_code() const;
        int subdivided_id() const;
};

