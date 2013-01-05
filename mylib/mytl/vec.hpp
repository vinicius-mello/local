#ifndef MYTL_ALG_MODEL_VEC
#define MYTL_ALG_MODEL_VEC

/*! \file
 * \brief Model of Vector Space
 */

#include <algorithm>
#include <cmath>
#include <mytl/array_cons.hpp>

namespace mytl {

    using std::sqrt;

    /*! \addtogroup alg
     * @{
     */

    //! Models a Vector Space
    /*! Provides the usual vector space operations.
     *
     * \b Example:
     * \include vec.cpp
     * \b Output:
     * \include vec.out
     */
    template <dim_t n, typename Scalar=double>
        class vec : public array<Scalar,n> {
            public:
                void zero() {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]=0;
                    }
                }
                vec() : array<Scalar,n>() {
                    zero();
                }
                vec(const array<Scalar,n>& a) : array<Scalar,n>(a) {
                }
                explicit vec(Scalar s) {
                    for(dim_t i=0; i<n; ++i) (*this)[i]=s;
                }
                template <class T>
                    explicit vec(const vec<n,T>& _v) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]=Scalar(_v[i]);
                        }
                    }
                template <class T>
                    explicit vec(const array<T,n>& a) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]=Scalar(a[i]);
                        }
                    }
                /*  template <class T>
                    vec& operator=(const T& _v) {
                    for(dim_t i=0; i<n; ++i) {
                    (*this)[i]=Scalar(_v[i]);
                    }
                    return (*this);
                    }*/
                template <class Scalar2>
                    vec& operator=(const vec<n,Scalar2>& _v) {
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]=Scalar(_v[i]);
                        }
                        return (*this);
                    }
                vec& operator+=(const vec& v) {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]+=v[i];
                    }
                    return (*this);
                }
                vec& operator-=(const vec& v) {
                    for(dim_t i=0; i<n; ++i) {
                        (*this)[i]-=v[i];
                    }
                    return (*this);
                }
                vec operator+(const vec& v) const {
                    vec temp(*this);
                    temp+=v;
                    return temp;
                }
                vec operator-(const vec& v) const {
                    vec temp(*this);
                    temp-=v;
                    return temp;
                }
                vec operator-() const {
                    vec temp;
                    temp-=(*this);
                    return temp;
                }
                template <class Scalar2>
                    vec& operator*=(const Scalar2& s) {
                        Scalar ss=Scalar(s);
                        for(dim_t i=0; i<n; ++i) {
                            (*this)[i]*=ss;
                        }
                        return (*this);
                    }
                template <class Scalar2>
                    vec operator*(const Scalar2& s) const {
                        vec temp(*this);
                        temp*=s;
                        return temp;
                    }
        };

    template <dim_t n, typename Scalar, typename Scalar2>
        vec<n,Scalar> operator*(const Scalar2& s, const vec<n,Scalar>& v) {
            vec<n,Scalar> temp(v);
            temp*=s;
            return temp;
        }

    //! Computes dot product
    template <dim_t n, typename Scalar>
        Scalar dot(const vec<n, Scalar>&v , const vec<n, Scalar>& w) {
            Scalar result=0;
            for(dim_t i=0; i<n; ++i)
                result+=v[i]*w[i]; /*conj(w[i])*/
            return result;
        }

    //! project(3,_(0,1,2,3,4,5))==_(0,1,2,4,5)
    template <dim_t n, typename Scalar>
        void project(dim_t j, const vec<n, Scalar>&v , vec<n-1, Scalar>& w) {
            for(dim_t i=0; i<j; ++i) w[i]=v[i];
            for(dim_t i=j+1; i<n; ++i) w[i-1]=v[i];
        }

    //! unproject(3,_(0,1,2,4,5))==_(0,1,2,0,4,5)
    template <dim_t n, typename Scalar>
        void unproject(dim_t j, const vec<n, Scalar>&w , vec<n+1, Scalar>& v) {
            for(dim_t i=0; i<j; ++i) v[i]=w[i];
            v[j]=0;
            for(dim_t i=j; i<n; ++i) v[i+1]=w[i];
        }

    template <typename Scalar>
        inline
        Scalar det(const array<vec<1,Scalar>,1>& v) {
            return v[0][0];
        }

    template <typename Scalar>
        inline
        Scalar det(const array<vec<2,Scalar>,2>& v) {
            return v[0][0]*v[1][1]-v[0][1]*v[1][0];
        }

    //! Computes \f$\det(v_0,v_1,\cdots,v_{n-1})\f$
    template <dim_t n, typename Scalar>
        Scalar det(const array<vec<n,Scalar>,n>& v) {
            Scalar result=0;
            Scalar sig=1;
            array<vec<n-1,Scalar>,n> t;
            for(dim_t i=0;i<n;++i) project(0,v[i],t[i]);
            for(dim_t j=0;j<n;++j,sig*=-1) {
                array<vec<n-1,Scalar>,n-1> tt;
                for(dim_t i=0; i<j; ++i) tt[i]=t[i];
                for(dim_t i=j+1; i<n; ++i) tt[i-1]=t[i];
                result+=sig*v[j][0]*det(tt);
            }
            return result;
        }

    template <dim_t n, typename Scalar>
        void cofat(const array<vec<n,Scalar>,n>& v, array<vec<n,Scalar>,n>& cf) {
            Scalar sig=1;
            array<vec<n-1,Scalar>,n> t;
            for(dim_t k=0;k<n;++k) {
                for(dim_t i=0;i<n;++i) project(k,v[i],t[i]);
                for(dim_t j=0;j<n;++j,sig*=-1) {
                    array<vec<n-1,Scalar>,n-1> tt;
                    for(dim_t i=0;i<j;++i) tt[i]=t[i];
                    for(dim_t i=j+1;i<n;++i) tt[i-1]=t[i];
                    cf[j][k]=sig*det(tt);
                }
            }
        }

    //! Computes cross product
    template <typename Scalar>
        vec<3, Scalar>
        cross(const vec<3, Scalar> &a, const vec<3, Scalar> &b)
        {
            vec<3, Scalar> result;
            result[0]=a[1]*b[2]-a[2]*b[1];
            result[1]=a[2]*b[0]-a[0]*b[2];
            result[2]=a[0]*b[1]-a[1]*b[0];
            return result;
        }

    //! Computes cross product
    template <dim_t n, typename Scalar>
        vec<n+1,Scalar>
        cross(const array<vec<n+1,Scalar>,n>& vs) {
            vec<n+1, Scalar> result;
            array<vec<n,Scalar>,n> t;
            for(dim_t i=0;i<=n;++i) {
                for(dim_t j=0;j<n;++j) {
                    project(i,vs[j],t[j]);
                }
                result[i]=((i%2) ? -1 : 1)*det(t);
            }
            return result;
        }

    //! Normalizes a in place
    template <dim_t n, typename Scalar>
        void
        normalize(vec<n,Scalar> &a)
        {
            a=(1.0/sqrt(dot(a,a)))*a;
        }


    template <dim_t n, typename Scalar>
        void load_identity(array<vec<n,Scalar>,n>& m) {
            Scalar one=1;
            for(dim_t i=0;i<n;++i)
                for(dim_t j=0;j<n;++j)
                    if(i==j) m[i][j]=one;
                    else m[i][j]=0;
        }

    /*! @} */

}


#endif
