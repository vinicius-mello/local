#ifndef WRAP_TRIPLETS_HPP
#define WRAP_TRIPLETS_HPP
#include <map>
#include <utility>
#include "sparse.hpp"

typedef std::map<std::pair<int,int>,double> sparse_table;

class triplets {
    int n_,m_;
    mutable sparse_table st;
    sparse_table::const_iterator iter;
    public:
    triplets() : n_(0),m_(0) {}
    bool exists(int i, int j) const {
        return st.count(std::make_pair(j,i))!=0;
    }
    double get(int i, int j) const {
        if(!exists(i,j)) {
            return 0;
        } else {
            return st[std::make_pair(j,i)];
        }
    }
    double get(int i) const {
        return get(i,0);
    }
    void set(int i, int j, double v) {
        st[std::make_pair(j,i)]=v;
        m_=std::max(m_,i+1);
        n_=std::max(n_,j+1);
    }
    void set(int i, double v) {
        set(i,0,v);
    }
    void add_to(int i, int j, double v) {
        if(!exists(i,j)) {
            set(i,j,v);
        } else {
            st[std::make_pair(j,i)]+=v;
        }
    }
    void iter_reset() {
        iter=st.begin();
    }
    void iter_next() {
        iter++;
    }
    bool iter_end() const {
        return iter==st.end();
    }
    int iter_i() const {
        return iter->first.second;
    }
    int iter_j() const {
        return iter->first.first;
    }
    double iter_v() const {
        return iter->second;
    }
    int n() const {
        return n_;
    }
    int m() const {
        return m_;
    }
    int size() const {
        return st.size();
    }
    void fill(sparse& s) const {
        bool sym=s.sym();
        int idx=0,col=0,kk=0;
        array<int> col_ptr=s.col_ptr();
        array<int> row_ind=s.row_ind();
        array<double> val=s.val();
        for(sparse_table::const_iterator k=st.begin();k!=st.end();++k) {
            std::pair<int,int> ji=k->first;
            int j=ji.first;
            int i=ji.second;
            if(sym && i<j) continue;
            double v=k->second;
            val.set(kk,v);
            row_ind.set(kk,i);
            if(col!=j) {
                col_ptr.set(col,idx);
                col=col+1;
                idx=kk;
            }
            ++kk;
        }
        col_ptr.set(col,idx);
        col_ptr.set(col+1,kk);
    }
};

#endif // WRAP_TRIPLETS_HPP
