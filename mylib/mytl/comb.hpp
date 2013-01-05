#ifndef MYTL_COMB_HPP
#define MYTL_COMB_HPP

#include <mytl/types.hpp>

namespace mytl {

    template <class NumericIt>
        bool
        next_combination(dim_t m, NumericIt v, NumericIt end) {
            dim_t n=end-v;
            if(v[0]==(m-n)) return false;
            dim_t i;
            for(i=n-1; i>0; --i) if(v[i]!=(m-n+i)) break;
            v[i]+=1;
            for(i=i+1;i<n;++i) v[i]=v[i-1]+1;
            return true;
        }

    template <class NumericIt>
        bool
        prev_combination(dim_t m, NumericIt v, NumericIt end) {
            dim_t n=end-v;
            if(v[n-1]==(n-1)) return false;
            dim_t i;
            for(i=n-1; i>0; --i) if((v[i-1]+1)!=v[i]) break;
            v[i]-=1;
            for(i=i+1;i<n;++i) v[i]=m-n+i;
            return true;
        }

    template <class ArrayIt>
        int signature(ArrayIt begin, ArrayIt end) {
            int inversions=0;
            for(ArrayIt i=begin;i!=end;++i) {
                for(ArrayIt j=i+1;j!=end;++j) {
                    if(*i>*j) inversions++;
                }
            }
            return (inversions%2) ? -1 : 1;
        }

    template <class NumericIt>
        bool
        next_triangular(dim_t m, NumericIt v, NumericIt end) {
            const dim_t N=end-v-1;
            if(v[N]==m) return false;
            dim_t r;
            for(r=N-1;r>=0;--r) if(v[r]!=0) break;
            v[r]=v[r]-1;
            for(dim_t j=r+1;j<=N;++j) v[j]=0;
            v[r+1]=m;
            for(dim_t j=0;j<=r;++j) v[r+1]-=v[j];
            return true;
        }

}

#endif // MYTL_COMB_HPP
