#ifndef MYTL_ALG_MODEL_POINT
#define MYTL_ALG_MODEL_POINT

/*! \file
 * \brief Models an Affine Space
 */

#include <algorithm>
#include <mytl/array_operators.hpp>
#include <mytl/vec.hpp>

namespace mytl {

    using std::swap;

    /*! \addtogroup alg
     * @{
     */

    //! Models a Affine Space
    /*! Provides the usual affine space operations.
     *
     * \b Example:
     * \include point.cpp
     * \b Output:
     * \include point.out
     */
    template <dim_t n, typename Scalar=double>
        class point : public array<Scalar,n> {
            public:
                void zero() {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]=0;
                    }
                }
                point() : array<Scalar,n>() {
                    zero();
                }
                explicit point(Scalar s) {
                    for(dim_t i=0; i<n; ++i) (*this)[i]=s;
                }
                point(const array<Scalar,n>& a) : array<Scalar,n>(a) {
                }
                template <class T>
                    explicit point(const point<n,T>& p) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]=Scalar(p[i]);
                        }
                    }
                template <class T>
                    explicit point(const array<T,n>& a) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]=Scalar(a[i]);
                        }
                    }
                /*template <class T>
                  point& operator=(const T& v) {
                  for(dim_t i=0; i<n; ++i) {
                  (*this)[i]+=Scalar(v[i]);
                  }
                  return (*this);
                  }*/
                template <class Scalar2>
                    point& operator=(const point<n,Scalar2>& v) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]+=Scalar(v[i]);
                        }
                        return (*this);
                    }
                point& operator+=(const vec<n,Scalar>& v) {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]+=v[i];
                    }
                    return (*this);
                }
                point& operator-=(const vec<n,Scalar>& v) {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]-=v[i];
                    }
                    return (*this);
                }
                point operator+(const vec<n,Scalar>& v) const {
                    point temp(*this);
                    temp+=v;
                    return temp;
                }
                point operator-(const vec<n,Scalar>& v) const {
                    point temp(*this);
                    temp-=v;
                    return temp;
                }
                vec<n,Scalar> operator-(const point& p) const {
                    vec<n,Scalar> temp;
                    for(dim_t i=0; i<n; ++i) {
                        temp[i]=(*this)[i]-p[i];
                    }
                    return temp;
                }
        };

    //! project(3,_(0,1,2,3,4,5))==_(0,1,2,4,5)
    template <dim_t n, typename Scalar>
        void project(dim_t j, const point<n, Scalar>&v , point<n-1, Scalar>& w) {
            for(dim_t i=0; i<j; ++i) w[i]=v[i];
            for(dim_t i=j+1; i<n; ++i) w[i-1]=v[i];
        }

    //! unproject(3,_(0,1,2,4,5))==_(0,1,2,0,4,5)
    template <dim_t n, typename Scalar>
        void unproject(dim_t j, const point<n, Scalar>&w , point<n+1, Scalar>& v) {
            for(dim_t i=0; i<j; ++i) v[i]=w[i];
            v[j]=0;
            for(dim_t i=j; i<n; ++i) v[i+1]=w[i];
        }

    template <typename Scalar>
        Scalar bracket(const array<point<1,Scalar>,2>& p) {
            return p[1][0]-p[0][0];
        }

    //! bracket(p)=\f$\det(p_1-p_0,p_2-p_0,\cdots,p_n-p_0)\f$
    template <dim_t n, typename Scalar>
        Scalar bracket(const array<point<n,Scalar>,n+1>& p) {
            Scalar result=0;
            Scalar sig=-1;
            array<point<n-1,Scalar>,n+1> t;
            for(dim_t i=0;i<=n;++i) project(0,p[i],t[i]);
            for(dim_t j=0;j<=n;++j,sig*=-1) {
                array<point<n-1,Scalar>,n> tt;
                for(dim_t i=0; i<j; ++i) tt[i]=t[i];
                for(dim_t i=j+1; i<=n; ++i) tt[i-1]=t[i];
                result+=sig*p[j][0]*bracket(tt);
            }
            return result;
        }

    //! Projects v to hyperplane \f$ x_1+x_2+\cdots+x_n=1\f$
    template <dim_t n, typename Scalar>
        point<n,Scalar> barycentric_project(const point<n, Scalar>&v) {
            Scalar s=0;
            point<n,Scalar> q;
            for(dim_t i=0; i<n; ++i) s+=v[i];
            q[n-1]=1;
            for(dim_t i=0; i<(n-1); ++i) {
                q[i]=v[i]/s;
                q[n-1]-=q[i];
            }
            return q;
        }

    //! Rescales each coordinate of v using weights from w
    template <dim_t n, typename Scalar>
        Scalar scale(const point<n, Scalar>& p, const array<Scalar,n>& w) {
            Scalar s=0;
            for(dim_t i=0; i<n; ++i) s+=p[i]*w[i];
            return s;
        }

    //! Forces coordinates of barycentric point v to be greater or equal zero
    template <dim_t n, typename Scalar>
        point<n,Scalar> barycentric_snap(const point<n, Scalar>&v) {
            Scalar s=0;
            point<n,Scalar> q;
            for(dim_t i=0; i<n; ++i)
                if(v[i]<0) {
                    q[i]=0;
                } else {
                    q[i]=v[i];
                    s+=v[i];
                }
            for(dim_t i=0; i<n; ++i) q[i]=q[i]/s;
            return q;
        }

    //! Computes barycentric combination of p using weights from w
    template <dim_t n, dim_t k, typename Scalar>
        point<n,Scalar> barycentric_combination(const point<k,Scalar>& w,
                const array<point<n,Scalar>,k>& p) {
            point<n,Scalar> q;
            for(dim_t j=0; j<n; ++j) for(dim_t i=0; i<k; ++i) q[j]+=w[i]*p[i][j];
            return q;
        }

    //! Computes barycentric combination of p using weights from w
    template <dim_t n, dim_t k, typename Scalar>
        vec<n,Scalar> barycentric_combination(const vec<k,Scalar>& w,
                const array<point<n,Scalar>,k>& p) {
            vec<n,Scalar> q;
            for(dim_t j=0; j<n; ++j) for(dim_t i=0; i<k; ++i) q[j]+=w[i]*p[i][j];
            return q;
        }

    template <dim_t n, dim_t k, typename Scalar>
        point<n,Scalar> barycentric_combination(const array<Scalar,k>& w,
                const array<point<n,Scalar>,k>& p) {
            vec<n,Scalar> q;
            for(dim_t j=0; j<n; ++j) for(dim_t i=0; i<k; ++i) q[j]+=w[i]*p[i][j];
            return q;
        }

    template <dim_t n, dim_t k, typename Scalar>
        vec<n,Scalar> barycentric_combination(const point<k,Scalar>& w,
                const array<vec<n,Scalar>,k>& p) {
            vec<n,Scalar> q;
            for(dim_t j=0; j<n; ++j) for(dim_t i=0; i<k; ++i) q[j]+=w[i]*p[i][j];
            return q;
        }

    //! Computes barycenter of p
    template <dim_t n, dim_t k, typename Scalar>
        point<n,Scalar> barycenter(const array<point<n,Scalar>,k>& p) {
            point<n,Scalar> q;
            Scalar s=1;
            s=s/k;
            for(dim_t j=0; j<n; ++j) for(dim_t i=0; i<k; ++i) q[j]+=s*p[i][j];
            return q;
        }

    //! Computes barycenter from container and stores it in bc
    template <dim_t n, typename Iterator, typename Scalar>
        void barycenter(Iterator begin, Iterator end, point<n,Scalar>& bc) {
            for(dim_t j=0; j<n; ++j) {
                bc[j]=0;
            }
            int l=0;
            for(Iterator i=begin;i!=end;++i,++l) {
                point<n,Scalar> p=*i;
                for(dim_t j=0; j<n; ++j) {
                    bc[j]+=p[j];
                }
            }
            for(dim_t j=0; j<n; ++j) {
                bc[j]/=l;
            }
        }

    //! Computes barycentric coordinates of r wrt p
    template <dim_t n, typename Scalar>
        point<n+1,Scalar>
        barycentric_coordinates(const point<n,Scalar>& r,
                const array<point<n,Scalar>,n+1>& p) {
            point<n+1,Scalar> w;
            Scalar s=1/bracket(p);
            array<point<n,Scalar>,n+1> q=p;
            point<n,Scalar> t=r;
            for(dim_t j=0; j<=n; ++j) {
                swap(q[j],t);
                w[j]=s*bracket(q);
                swap(q[j],t);
            }
            return w;
        }

    //! Utility class for computing weighted means while reading points
    template <dim_t n, typename Scalar>
        class weighted_mean {
            Scalar s;
            point<n,Scalar> p;
            public:
            weighted_mean() : s(0), p() {
            }
            void push(Scalar w, const point<n,Scalar>& q) {
                s+=w;
                for(dim_t i=0;i<n;++i) p[i]+=w*q[i];
            }
            point<n,Scalar> pop() {
                for(dim_t i=0;i<n;++i) p[i]/=s;
                return p;
            }
        };

    //! Verifies if r is inside simplex p
    template <dim_t n, typename Scalar>
        bool
        inside(const point<n,Scalar>& r,
                const array<point<n,Scalar>,n+1>& p) {
            Scalar s=1/bracket(p);
            array<point<n,Scalar>,n+1> q=p;
            point<n,Scalar> t=r;
            for(dim_t j=0; j<=n; ++j) {
                swap(q[j],t);
                if((s*bracket(q))<0) return false;
                swap(q[j],t);
            }
            return true;
        }

    /*! @} */

}
#endif
