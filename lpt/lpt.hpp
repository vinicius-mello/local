#ifndef LPT_HPP
#define LPT_HPP

#ifdef LPT_USE_MAP
#include <map>
#else
#include <tr1/unordered_map>
#endif
#include <set>
#include <list>
#include <queue>
#include <utility>
#include <cassert>
#include <cstdio>
#define LPT_ABS(x) (((x)<0) ? -(x) : (x))
#define LPT_SGN(x) (((x)<0) ? -1 : 1)

inline int delete_bit(int byte, int i) {
    int mask=(~0)<<i;
    return ((byte>>1)&mask)|((~mask)&byte);
}

inline int insert_bit(int byte, int i) {
    int mask=(~0)<<i;
    return ((mask&byte)<<1)|((~mask)&byte);
}

//! Template for permutation tables.
template <int n>
struct lpt_table {
};

//! Template specialization for dimension 2.
template <>
struct lpt_table<2> {
    static const int orth[8];
    static const int sigma_inv[8][2];
    static const int sigma[8][2];
    static const int sigperm[8][2];
    static const int lft[8][2];
    static const int rgt[8][2];
    static const int nsw[8][1];
    static const int swp[8][1];
    static const int neg[8];
    static const int inverse[8];
};

//! Template specialization for dimension 3.
template <>
struct lpt_table<3> {
    static const int orth[48];
    static const int sigma_inv[48][3];
    static const int sigma[48][3];
    static const int sigperm[48][3];
    static const int lft[48][3];
    static const int rgt[48][3];
    static const int nsw[48][2];
    static const int swp[48][2];
    static const int neg[48];
    static const int inverse[48];
};

//! Template specialization for dimension 4.
template <>
struct lpt_table<4> {
    static const int orth[384];
    static const int sigma_inv[384][4];
    static const int sigma[384][4];
    static const int sigperm[384][4];
    static const int lft[384][4];
    static const int rgt[384][4];
    static const int nsw[384][3];
    static const int swp[384][3];
    static const int neg[384];
    static const int inverse[384];
};

#pragma pack(push,1)  //force struct packing

//! 32 bits encoding of LPT code in dimension 2.
class lpt2_32_bits {
    unsigned char level_ : 1;
    unsigned char sigperm_ : 3;
    unsigned char orthant_level_ : 4;
    unsigned short orthantx_ : 12;
    unsigned short orthanty_ : 12;
    public:
    static const int max_orthant_level=12;
    lpt2_32_bits() : level_(0), sigperm_(0), orthant_level_(0) {
        orthantx_=0;
        orthanty_=0;
    }
    lpt2_32_bits(int _sigperm) : level_(0), sigperm_(_sigperm<<2), orthant_level_(0) {
        orthantx_=0;
        orthanty_=0;
    }
    int level_get() const {
        return level_;
    }
    void level_set(int l) {
        level_=l;
    }
    int sigperm_get() const {
        return sigperm_;
    }
    void sigperm_set(int l) {
        sigperm_=l;
    }
    int orthant_level_get() const {
        return orthant_level_;
    }
    void orthant_level_set(int l) {
        orthant_level_=l;
    }
    int orthant_get(int i) const {
        return (i==0)?orthantx_:orthanty_;
    }
    void orthant_set(int i, int l) {
        if(i==0) orthantx_=l;
        else orthanty_=l;
    }
};

//! 48 bits encoding of LPT code in dimension 2.
class lpt2_48_bits {
    unsigned char level_ : 1;
    unsigned char sigperm_ : 3;
    unsigned char orthant_level_ : 4;
    unsigned short orthant_[2];
    public:
    static const int max_orthant_level=15;
    lpt2_48_bits() : level_(0), sigperm_(0), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
    }
    lpt2_48_bits(int _sigperm) : level_(0), sigperm_(_sigperm<<2), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
    }
    int level_get() const {
        return level_;
    }
    void level_set(int l) {
        level_=l;
    }
    int sigperm_get() const {
        return sigperm_;
    }
    void sigperm_set(int l) {
        sigperm_=l;
    }
    int orthant_level_get() const {
        return orthant_level_;
    }
    void orthant_level_set(int l) {
        orthant_level_=l;
    }
    int orthant_get(int i) const {
        return orthant_[i];
    }
    void orthant_set(int i, int l) {
        orthant_[i]=l;
    }
};

//! 64 bits encoding of LPT code in dimension 3.
class lpt3_64_bits {
    unsigned char level_ : 2;
    unsigned char sigperm_ : 6;
    unsigned char orthant_level_ : 5;
    unsigned short orthant_[3];
    public:
    static const int max_orthant_level=16;
    lpt3_64_bits() : level_(0), sigperm_(0), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
        orthant_[2]=0;
    }
    lpt3_64_bits(int _sigperm) : level_(0), sigperm_(_sigperm<<3), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
        orthant_[2]=0;
    }
    int level_get() const {
        return level_;
    }
    void level_set(int l) {
        level_=l;
    }
    int sigperm_get() const {
        return sigperm_;
    }
    void sigperm_set(int l) {
        sigperm_=l;
    }
    int orthant_level_get() const {
        return orthant_level_;
    }
    void orthant_level_set(int l) {
        orthant_level_=l;
    }
    int orthant_get(int i) const {
        return orthant_[i];
    }
    void orthant_set(int i, int l) {
        orthant_[i]=l;
    }
};

//! 48 bits encoding of LPT code in dimension 4.
class lpt4_48_bits {
    unsigned char level_ : 2;
    unsigned short sigperm_ : 9;
    unsigned char orthant_level_ : 4;
    unsigned char orthant_[4];
    public:
    static const int max_orthant_level=8;
    lpt4_48_bits() : level_(0), sigperm_(0), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
        orthant_[2]=0;
        orthant_[3]=0;
    }
    lpt4_48_bits(int _sigperm) : level_(0), sigperm_(_sigperm<<4), orthant_level_(0) {
        orthant_[0]=0;
        orthant_[1]=0;
        orthant_[2]=0;
        orthant_[3]=0;
    }
    int level_get() const {
        return level_;
    }
    void level_set(int l) {
        level_=l;
    }
    int sigperm_get() const {
        return sigperm_;
    }
    void sigperm_set(int l) {
        sigperm_=l;
    }
    int orthant_level_get() const {
        return orthant_level_;
    }
    void orthant_level_set(int l) {
        orthant_level_=l;
    }
    int orthant_get(int i) const {
        return orthant_[i];
    }
    void orthant_set(int i, int l) {
        orthant_[i]=l;
    }
};

#pragma pack(pop) //ok

//! Generic LPT code template class.
//! \example example.cpp
template <int dimension, class code>
class lpt : public code {
    public:
        //! Mesh dimension
        static const int dim=dimension;
        //! Default constructor
        lpt() : code() {}
        //! Constructs a root simplex
        /** \param perm the root index ( 0 <= perm < (dim!) )*/
        lpt(int perm) : code(perm) {}
        int orth() const {
            return lpt_table<dim>::orth[code::sigperm_get()];
        }
        int sigma_inv(int l) const {
            return lpt_table<dim>::sigma_inv[code::sigperm_get()][l];
        }
        int sigma(int l) const {
            return lpt_table<dim>::sigma[code::sigperm_get()][l];
        }
        int lft(int l) const {
            return lpt_table<dim>::lft[code::sigperm_get()][l];
        }
        int rgt(int l) const {
            return lpt_table<dim>::rgt[code::sigperm_get()][l];
        }
        int sigperm(int i) const {
            return lpt_table<dim>::sigperm[code::sigperm_get()][i-1];
        }
        int inverse() const {
            return lpt_table<dim>::inverse[code::sigperm_get()];
        }
        int neg() const {
            return lpt_table<dim>::neg[code::sigperm_get()];
        }
        int nsw(int l) const {
            return lpt_table<dim>::nsw[code::sigperm_get()][l-1];
        }
        int swp(int i) const {
            return lpt_table<dim>::swp[code::sigperm_get()][i-1];
        }
        //! Tests if this code represents a root simplex
        bool is_root() const {
            return code::level_get()==0 && code::orthant_level_get()==0;
        }
        //! Returns the simplex orientation
        /** \return 1 for positive orientation, -1 otherwise*/
        int orientation() const {
            static const char ParityTable256[256] = // from Bit Twiddling Hacks
            {
#   define LPT_P2(n) n, n^1, n^1, n
#   define LPT_P4(n) LPT_P2(n), LPT_P2(n^1), LPT_P2(n^1), LPT_P2(n)
#   define LPT_P6(n) LPT_P4(n), LPT_P4(n^1), LPT_P4(n^1), LPT_P4(n)
                LPT_P6(0), LPT_P6(1), LPT_P6(1), LPT_P6(0)
            };
            int m=(1<<dim)-1;
            char parsig = ParityTable256[code::sigperm_get()&m];
            int perm=code::sigperm_get()>>dim;
            int parperm = ((perm & 2)>>1)^(perm&1); // in lex order,
            // permutation parity follows the pattern 0,1,1,0,...
            return (parperm^parsig)?-1:1;
        }
        //! Returns the simplex level
        /** \return level l ( 0 <= l < \c dim )*/
        int level() const {
            return code::level_get();
        }
        int orthant_level() const {
            return code::orthant_level_get();
        }
        int simplex_level() const {
            return orthant_level()*dim+level();
        }
        //! Returns the simplex children
        /** \param zo ( 0 or 1)*/
        lpt child(int zo) const {
            assert(zo==0 || zo==1);
            assert(code::orthant_level_get()<code::max_orthant_level
                    || code::level_get()<(dim-1));
            lpt r;
            r.level_set((code::level_get()+1)%dim);
            if(zo==0) r.sigperm_set(code::sigperm_get());
            else r.sigperm_set(sigma(code::level_get()));
            if(r.level_get()==0) {
                r.orthant_level_set(code::orthant_level_get()+1);
                int orth=r.orth();
                for(int i=0;i<dim;++i) {
                    r.orthant_set(i,code::orthant_get(i)<<1);
                    if(orth&(1<<i)) r.orthant_set(i,r.orthant_get(i)|1);
                }
            } else {
                r.orthant_level_set(code::orthant_level_get());
                for(int i=0;i<dim;++i)
                    r.orthant_set(i,code::orthant_get(i));
            }
            return r;
        }
        //! Tests if this code represents a 0 child
        bool is_child0() const {
            if(code::orthant_level_get()==0) {
                if(code::level_get()!=0) {
                    int s=sigperm(code::level_get());
                    return (s>0);
                } else return false; // error
            }	else if(code::orthant_level_get()==1) {
                if(code::level_get()!=0) {
                    int lstar=code::level_get();
                    int s=sigperm(lstar);
                    return LPT_SGN(s)==((code::orthant_get(LPT_ABS(s)-1)&1)?-1:1);
                } else {
                    int s=sigperm(dim);
                    return (s>0);
                }
            } else {
                int lstar=(code::level_get()==0)?dim:(code::level_get());
                int s=sigperm(lstar);
                if(code::level_get()!=0)
                    return LPT_SGN(s)==((code::orthant_get(LPT_ABS(s)-1)&1)?-1:1);
                else
                    return LPT_SGN(s)==((code::orthant_get(LPT_ABS(s)-1)&2)?-1:1);
            }
        }
        //! Returns the simplex parent
        lpt parent() const {
            assert(!is_root());
            lpt r;
            if(code::level_get()==0) {
                r.level_set(dim-1);
                r.orthant_level_set(code::orthant_level_get()-1);
                for(int i=0;i<dim;++i) r.orthant_set(i,code::orthant_get(i)>>1);
            } else {
                r.level_set(code::level_get()-1);
                r.orthant_level_set(code::orthant_level_get());
                for(int i=0;i<dim;++i) r.orthant_set(i,code::orthant_get(i));
            }
            if(is_child0()) {
                r.sigperm_set(code::sigperm_get());
            } else {
                r.sigperm_set(sigma_inv(r.level_get()));
            }
            return r;
        }
        //! Returns the neighbor simplex opposite to i-th face by reference
        /** \param i face index ( 0 <= i <= \c dim )
          \param r i-th neighbor (by reference)
          \return false if there is no neighbor */
        bool neighbor(int i, lpt& r) const {
            return neighbor_bd(i,r)==0;
        }
        int neighbor_bd(int i, lpt& r) const {
            assert(i>=0 && i<=dim);
            r.level_set(code::level_get());
            r.orthant_level_set(code::orthant_level_get());
            if(is_child0()) {
                if(i==0) {
                    r.sigperm_set(neg());
                } else if (i==dim) {
                    int lminus=(code::level_get()==0)?(dim-1):(code::level_get()-1);
                    r.sigperm_set(lft(lminus));
                } else {
                    r.sigperm_set(swp(i));
                }
            } else {
                int lstar=(code::level_get()==0)?(dim):(code::level_get());
                if(i==0) {
                    r.sigperm_set(neg());
                } else if(i==lstar) {
                    int lminus=(code::level_get()==0)?(dim-1):(code::level_get()-1);
                    r.sigperm_set(rgt(lminus));
                } else if(i==dim) {
                    r.sigperm_set(nsw(code::level_get()));
                } else {
                    r.sigperm_set(swp(i));
                }
            }
            int p=sigperm(1);
            if(code::orthant_level_get()==0) {
                if( i==0 || (code::level_get()==0 && i==dim)) return p;
                return 0;
            }
            if(i==0) {
                for(int j=0;j<dim;++j)
                    r.orthant_set(j,code::orthant_get(j));
                int d=LPT_SGN(p);
                int x=r.orthant_get(LPT_ABS(p)-1);
                int m;
                if(d==1) m=0;
                else m=(1<<code::orthant_level_get())-1;
                if(x==m) {
                    return p;
                } else {
                    int m=(1<<code::orthant_level_get())-1;
                    if(d==1) r.orthant_set(LPT_ABS(p)-1,m&(x-1));
                    else r.orthant_set(LPT_ABS(p)-1,m&(x+1));
                }
            } else if(code::level_get()==0 && i==dim) {
                int orth=r.orth();
                for(int j=0;j<dim;++j) {
                    r.orthant_set(j,((code::orthant_get(j)>>1)<<1));
                    if(orth&(1<<j))
                        r.orthant_set(j,r.orthant_get(j)|1);
                }
            } else {
                for(int j=0;j<dim;++j)
                    r.orthant_set(j,code::orthant_get(j));
            }
            return 0;
        }
        //! Prints the LPT code
        void print() const {
            printf("(%d,[ ",code::level_get());
            for(int i=1;i<=dim;++i) printf("%d ",sigperm(i));
            printf("], ");
            for(int i=0;i<code::orthant_level_get();++i) {
                printf("(");
                for(int j=0;j<dim;++j) {
                    if(code::orthant_get(j)&(1<<(code::orthant_level_get()-1-i))) printf("-");
                    else printf("+");
                }
                printf(")");
            }
            printf(")");
        }
        //! Emit the dim coordinates of the (dim + 1) vertices.
        void simplex(double * s) const {
            double t[dim];
            for(int j=0;j<dim;++j) t[j]=0.0;
            for(int i=0;i<code::orthant_level_get();++i) {
                for(int j=0;j<dim;++j) {
                    if(code::orthant_get(j)&(1<<(code::orthant_level_get()-1-i))) t[j]-=1.0/(2<<i);
                    else t[j]+=1.0/(2<<i);
                }
            }
            for(int i=0;i<=dim;++i) {
                for(int j=0;j<dim;++j) {
                    double v;
                    if(i>j) v=1.0;
                    else {
                        if(i<code::level_get()) v=0.0;
                        else v=-1.0;
                    }
                    v=v/(1<<code::orthant_level_get());
                    int p=sigperm(j+1);
                    s[i*dim+(LPT_ABS(p)-1)]=LPT_SGN(p)*v;
                }
                for(int j=0;j<dim;++j) {
                    s[i*dim+j]+=t[j];
                }
            }
        }
        //! Prints the simplex coordinates
        void print_simplex() const {
            double s[dim*(dim+1)];
            simplex(s);
            printf("(");
            for(int i=0;i<=dim;++i) {
                printf("(");
                for(int j=0;j<dim;++j) {
                    printf("%g",s[i*dim+j]);
                    if(j!=(dim-1)) printf(",");
                    else printf(")");
                }
            }
            printf(")");
        }
        bool operator<(const lpt& r) const {
            if(code::orthant_level_get()<r.orthant_level_get()) return true;
            else if(code::orthant_level_get()>r.orthant_level_get()) return false;
            for(int i=0;i<dim;++i)
                if(code::orthant_get(i)<r.orthant_get(i)) return true;
                else if(code::orthant_get(i)>r.orthant_get(i)) return false;
            if(code::level_get()<r.level_get()) return true;
            else if(code::level_get()>r.level_get()) return false;
            if(code::sigperm_get()<r.sigperm_get()) return true;
            else if(code::sigperm_get()>r.sigperm_get()) return false;
            return false;
        }
        bool operator==(const lpt& r) const {
            if(code::orthant_level_get()!=r.orthant_level_get()) return false;
            for(int i=0;i<dim;++i)
                if(code::orthant_get(i)!=r.orthant_get(i)) return false;
            if(code::level_get()!=r.level_get()) return false;
            if(code::sigperm_get()!=r.sigperm_get()) return false;
            return true;
        }

};

inline void morton3_10(unsigned int& x) {
    x = (x | (x << 16)) & 0x030000FF;
    x = (x | (x <<  8)) & 0x0300F00F;
    x = (x | (x <<  4)) & 0x030C30C3;
    x = (x | (x <<  2)) & 0x09249249;
}

inline double morton3_10(double x, double y, double z) {
    double r=0.0;
    unsigned int xi;
    if(x==1.0) {
        xi=0;
        r+=1.0;
    } else {
        xi=(unsigned int)((x+1.0)/2.0*(1<<10));
        morton3_10(xi);
    }
    unsigned int yi;
    if(y==1.0) {
        yi=0;
        r+=2.0;
    } else {
        yi=(unsigned int)((y+1.0)/2.0*(1<<10));
        morton3_10(yi);
    }
    unsigned int zi;
    if(z==1.0) {
        zi=0;
        r+=4.0;
    } else {
        zi=(unsigned int)((z+1.0)/2.0*(1<<10));
        morton3_10(zi);
    }
    xi=xi | (yi << 1) | (zi << 2);
    r+=((double)xi)/(1<<30);
    return r;
}

inline void morton2_16(unsigned int& x) {
    x = (x | (x << 8)) & 0x00FF00FF;
    x = (x | (x << 4)) & 0x0F0F0F0F;
    x = (x | (x << 2)) & 0x33333333;
    x = (x | (x << 1)) & 0x55555555;
}

inline double morton2_16(double x, double y) {
    double r=0.0;
    unsigned int xi;
    if(x==1.0) {
        xi=0;
        r+=1.0;
    } else {
        xi=(unsigned int)((x+1.0)/2.0*(1<<16));
        morton2_16(xi);
    }
    unsigned int yi;
    if(y==1.0) {
        yi=0;
        r+=2.0;
    } else {
        yi=(unsigned int)((y+1.0)/2.0*(1<<16));
        morton2_16(yi);
    }      
    xi=xi | (yi << 1);
    r+=((double)xi)/(1UL<<32);
    return r;
}

inline void morton4_8(unsigned int& x) {
    const unsigned mor4[256]={
        0x00000000,0x00000001,0x00000010,0x00000011,0x00000100,0x00000101,0x00000110,0x00000111,0x00001000,
        0x00001001,0x00001010,0x00001011,0x00001100,0x00001101,0x00001110,0x00001111,0x00010000,
        0x00010001,0x00010010,0x00010011,0x00010100,0x00010101,0x00010110,0x00010111,0x00011000,
        0x00011001,0x00011010,0x00011011,0x00011100,0x00011101,0x00011110,0x00011111,0x00100000,
        0x00100001,0x00100010,0x00100011,0x00100100,0x00100101,0x00100110,0x00100111,0x00101000,
        0x00101001,0x00101010,0x00101011,0x00101100,0x00101101,0x00101110,0x00101111,0x00110000,
        0x00110001,0x00110010,0x00110011,0x00110100,0x00110101,0x00110110,0x00110111,0x00111000,
        0x00111001,0x00111010,0x00111011,0x00111100,0x00111101,0x00111110,0x00111111,0x01000000,
        0x01000001,0x01000010,0x01000011,0x01000100,0x01000101,0x01000110,0x01000111,0x01001000,
        0x01001001,0x01001010,0x01001011,0x01001100,0x01001101,0x01001110,0x01001111,0x01010000,
        0x01010001,0x01010010,0x01010011,0x01010100,0x01010101,0x01010110,0x01010111,0x01011000,
        0x01011001,0x01011010,0x01011011,0x01011100,0x01011101,0x01011110,0x01011111,0x01100000,
        0x01100001,0x01100010,0x01100011,0x01100100,0x01100101,0x01100110,0x01100111,0x01101000,
        0x01101001,0x01101010,0x01101011,0x01101100,0x01101101,0x01101110,0x01101111,0x01110000,
        0x01110001,0x01110010,0x01110011,0x01110100,0x01110101,0x01110110,0x01110111,0x01111000,
        0x01111001,0x01111010,0x01111011,0x01111100,0x01111101,0x01111110,0x01111111,0x10000000,
        0x10000001,0x10000010,0x10000011,0x10000100,0x10000101,0x10000110,0x10000111,0x10001000,
        0x10001001,0x10001010,0x10001011,0x10001100,0x10001101,0x10001110,0x10001111,0x10010000,
        0x10010001,0x10010010,0x10010011,0x10010100,0x10010101,0x10010110,0x10010111,0x10011000,
        0x10011001,0x10011010,0x10011011,0x10011100,0x10011101,0x10011110,0x10011111,0x10100000,
        0x10100001,0x10100010,0x10100011,0x10100100,0x10100101,0x10100110,0x10100111,0x10101000,
        0x10101001,0x10101010,0x10101011,0x10101100,0x10101101,0x10101110,0x10101111,0x10110000,
        0x10110001,0x10110010,0x10110011,0x10110100,0x10110101,0x10110110,0x10110111,0x10111000,
        0x10111001,0x10111010,0x10111011,0x10111100,0x10111101,0x10111110,0x10111111,0x11000000,
        0x11000001,0x11000010,0x11000011,0x11000100,0x11000101,0x11000110,0x11000111,0x11001000,
        0x11001001,0x11001010,0x11001011,0x11001100,0x11001101,0x11001110,0x11001111,0x11010000,
        0x11010001,0x11010010,0x11010011,0x11010100,0x11010101,0x11010110,0x11010111,0x11011000,
        0x11011001,0x11011010,0x11011011,0x11011100,0x11011101,0x11011110,0x11011111,0x11100000,
        0x11100001,0x11100010,0x11100011,0x11100100,0x11100101,0x11100110,0x11100111,0x11101000,
        0x11101001,0x11101010,0x11101011,0x11101100,0x11101101,0x11101110,0x11101111,0x11110000,
        0x11110001,0x11110010,0x11110011,0x11110100,0x11110101,0x11110110,0x11110111,0x11111000,
        0x11111001,0x11111010,0x11111011,0x11111100,0x11111101,0x11111110,0x11111111,};
    x=mor4[x];
}

namespace std { namespace tr1 {

    //! Hash function object for 2 dimensions and 32 bits
    template <>
        struct hash<lpt<2,lpt2_32_bits> > {
            size_t operator()(const lpt<2,lpt2_32_bits>& l) const {
                unsigned int x=l.orthant_get(0);
                morton2_16(x);
                unsigned int y=l.orthant_get(1);
                morton2_16(y);
                x=x | (y << 1);
                y=(l.sigperm_get()|(l.level_get()<<3))<<28;
                return static_cast<size_t>(x|y);
            }
        };

    //! Hash function object for 2 dimensions and 48 bits
    template <>
        struct hash<lpt<2,lpt2_48_bits> > {
            size_t operator()(const lpt<2,lpt2_48_bits>& l) const {
                unsigned int x=l.orthant_get(0);
                morton2_16(x);
                unsigned int y=l.orthant_get(1);
                morton2_16(y);
                x=x | (y << 1);
                y=(l.sigperm_get()|(l.level_get()<<3))<<28;
                return static_cast<size_t>(x|y);
            }
        };

    //! Hash function object for 3 dimensions and 64 bits
    template <>
        struct hash<lpt<3,lpt3_64_bits> > {
            size_t operator()(const lpt<3,lpt3_64_bits>& l) const {
                unsigned int x=l.orthant_get(0);
                morton3_10(x);
                unsigned int y=l.orthant_get(1);
                morton3_10(y);
                unsigned int z=l.orthant_get(2);
                morton3_10(z);
                x=x | (y << 1) | (z << 2);
                y=(l.sigperm_get()|(l.level_get()<<6))<<24;
                return static_cast<size_t>(x|y);
            }
        };

    //! Hash function object for 4 dimensions and 48 bits
    template <>
        struct hash<lpt<4,lpt4_48_bits> > {
            size_t operator()(const lpt<4,lpt4_48_bits>& l) const {
                unsigned int x=l.orthant_get(0);
                morton4_8(x);
                unsigned int y=l.orthant_get(1);
                morton4_8(y);
                unsigned int z=l.orthant_get(2);
                morton4_8(z);
                unsigned int w=l.orthant_get(3);
                morton4_8(w);
                x=x | (y << 1) | (z << 2) | (w << 3);
                y=l.level_get()<<30;
                return static_cast<size_t>(x|y);
            }
        };

} }

//! Hierachical mesh of simplices
//! \example example.cpp
template <class lpt>
class lpt_tree {
    //! Mesh dimension
    static const int dim=lpt::dim;
#ifdef LPT_USE_MAP
    std::map<lpt,int> tree;
    typename std::map<lpt,int>::const_iterator cur;
#else
    std::tr1::unordered_map<lpt,int> tree;
    typename std::tr1::unordered_map<lpt,int>::const_iterator cur;
#endif
    std::set<lpt> pending;
    std::list<std::pair<lpt,int> > recent;
    typename std::list<std::pair<lpt,int> >::const_iterator rec;
    std::list<std::pair<lpt,int> > subdivided;
    typename std::list<std::pair<lpt,int> >::const_iterator sub;
    int next_id;
    public:
    //! Default constructor
    lpt_tree() : tree(), pending(), recent(), subdivided() {
        int fact[6]={1,1,2,6,24};
        for(int i=0;i<fact[dim];++i) {
            lpt r(i);
            tree[r]=i+1;
        }
        next_id=fact[dim]+1;
    }
    //! Tests if the simplex is in the mesh.
    bool exists(const lpt& r) const {
        return tree.count(r)!=0;
    }
    //! Tests if the simplex is a leaf.
    bool is_leaf(const lpt& r) const {
        assert(exists(r));
        return tree.find(r)->second>0;
    }
    private:
    void simple_bisect(const lpt& r) {
        assert(exists(r));
        assert(is_leaf(r));
        int id=(tree[r]*=-1);
        subdivided.push_back(std::make_pair(r,-id));
        lpt c;
        c=r.child(0);
        recent.push_back(std::make_pair(c,next_id));
        tree[c]=next_id;++next_id;
        c=r.child(1);
        recent.push_back(std::make_pair(c,next_id));
        tree[c]=next_id;++next_id;
    }
    public:
    //! Returns the neighbor simplex opposite to i-th face in the mesh
    /** \param r the simplex code
      \param i face index ( 0 <= i <= dim )
      \param n i-th neighbor (by reference)
      \return false if there is no neighbor */
    bool neighbor(const lpt& r, int i, lpt& n) const {
        return neighbor_bd(r,i,n)==0;
    }
    int neighbor_bd(const lpt& r, int i, lpt& n) const {
        int l=r.level();
        int p=r.neighbor_bd(i,n);
        if(p==0) {
            if(i==dim) {
                if(exists(n.child(0))) r.child(1).neighbor_bd(l,n);
            } else if(i==l) {
                if(exists(n.child(0))) r.child(0).neighbor_bd(l,n);
            } else {
                if(!exists(n)) n=n.parent();
            }
        }
        return p;
    }
    int neighbor_index(const lpt& r, const lpt& n) const {
        for(int j=0;j<=dim;++j) {
            lpt rr;
            if(neighbor(n,j,rr)) {
                if(rr==r) return j;
            }
        }
        return -1;
    }
    //! Performs a compatible bisection
    /** \param r simplex to be bisected */
    void compat_bisect(const lpt& r) {
        assert(exists(r));
        assert(is_leaf(r));
        pending.clear();
        recent.clear();
        subdivided.clear();
        compat_bisect_rec(r);
        rec=recent.begin();
        sub=subdivided.begin();
        //printf("load factor:%f\n",tree.load_factor());
    }
    private:
    void compat_bisect_rec(const lpt& r) {
        pending.insert(r);
        for(int i=0;i<=dim;++i) {
            if(i==dim || i==r.level()) continue;
            lpt n;
            if(r.neighbor(i,n)) {
                if(!exists(n)) compat_bisect_rec(n.parent());
                if(is_leaf(n) && pending.count(n)==0) compat_bisect_rec(n);
            }
        }
        simple_bisect(r);
    }
    public:
    //! Locates the root simplex that contains a point
    /** \param p pointer to dim point coordinates
     *  \param w pointer to (dim+1) barycentric coordinates (by reference) */
    lpt find_root(double * p, double * w) const {
        int a[dim];
        int fact[6]={1,1,2,6,24};
        int key,i;
        for(i=0;i<dim;++i) a[i]=i;
        for(int j=1;j<dim;++j) {  //insertion sort
            key=a[j];
            i=j-1;
            while(i>=0 && p[a[i]]<p[key]) { //descending order
                a[i+1]=a[i];
                i--;
            }
            a[i+1]=key;
        }
        int code=0;
        for(i=0;i<dim;++i) { // Lehmer code
            int k=0;
            for(int j=i+1;j<dim;++j) if(a[j]<a[i]) ++k;
            code+=fact[dim-i-1]*k;
        }
        lpt r(code);
        w[0]=(1.0-p[a[1-1]])/2.0;
        for(i=1;i<dim;++i) w[i]=(p[a[i-1]]-p[a[(i+1)-1]])/2.0;
        w[dim]=(p[a[dim-1]]+1.0)/2.0;
        return r;
    }
    //! Locates the leaf simplex that contains a point
    /** \param p pointer to dim point coordinates*/
    lpt search(double * p) const {
        double w[dim+1];
        return search(p,w);
    }
    //! Locates the leaf simplex that contains a point
    /** \param p pointer to dim point coordinates
     *  \param w pointer to (dim+1) barycentric coordinates (by reference) */
    lpt search(double * p, double * w) const {
        lpt r=find_root(p,w);
        return search_rec(p,r,w);
    }
    void search_all(double * p) {
        double w[dim+1];
        lpt r=search(p,w);
        int faces=0;
        for(int i=0;i<=dim;++i) if(w[i]!=0.0) faces+= (1<<i);
        std::queue<std::pair<lpt,int> > q;
        q.push(std::make_pair(r,faces));
        pending.clear();
        while(!q.empty()) {
            std::pair<lpt,int> rf=q.front();
            q.pop();
            r=rf.first;
            faces=rf.second;
            pending.insert(r); 
            for(int i=0;i<=dim;++i) {
                if(((1<<i)&faces)==0) {
                    lpt n;
                    if(neighbor(r,i,n)) {
                        rf.first=n;
                        rf.second=insert_bit(delete_bit(faces,i),neighbor_index(r,n));
                        if(pending.count(n)==0) q.push(rf);
                    }
                }
            }
        }
        recent.clear();
        for(typename std::set<lpt>::iterator it=pending.begin();it!=pending.end();++it) {
            recent.push_back(std::make_pair(*it,id(*it)+1));
        }
        rec=recent.begin();
    }
    private:
    lpt search_rec(double * p, const lpt& r, double * w) const {
        if(is_leaf(r)) return r;
        int l=r.level();
        if(w[l]<=w[dim]) {
            double t=w[l];
            w[l]=2.0*w[l];
            w[dim]=w[dim]-t;
            return search_rec(p,r.child(0),w);
        } else {
            double t=w[dim];
            w[l]=w[l]-t;
            for(int i=dim;i>l;--i) w[i]=w[i-1];
            w[l]=2.0*t;
            return search_rec(p,r.child(1),w);
        }
    }
    public:
    //! Resets the iterator to the tree nodes
    void node_reset() {
        cur=tree.begin();
    }
    //! Advances the iterator to the tree nodes
    bool node_next() {
        cur++;
        return cur!=tree.end();
    }
    //! Tests if the current iterator point to a leaf node
    bool node_is_leaf() const {
        return cur->second>0;
    }
    //! Returns the code of the current node
    lpt node_code() const {
        return cur->first;
    }
    //! Returns the id of the current node
    int node_id() const {
        return LPT_ABS(cur->second)-1;
    }
    //! Returns the id of a simplex
    /** \param r simplex code */
    int id(const lpt& r) const {
        return LPT_ABS(tree.find(r)->second)-1;
    }
    //! Advances the iterator to the nodes generated by a bisection
    bool recent_next() {
        rec++;
        return rec!=recent.end();
    }
    //! Returns the code of the current recent node
    lpt recent_code() const {
        return rec->first;
    }
    //! Returns the id of the current recent node
    int recent_id() const {
        return LPT_ABS(rec->second)-1;
    }
    //! Advances the iterator to the bisected nodes
    bool subdivided_next() {
        sub++;
        return sub!=subdivided.end();
    }
    //! Returns the code of the current subdivided node
    lpt subdivided_code() const {
        return sub->first;
    }
    //! Returns the id of the current subdivided node
    int subdivided_id() const {
        return LPT_ABS(sub->second)-1;
    }
};

#endif // LPT_HPP
