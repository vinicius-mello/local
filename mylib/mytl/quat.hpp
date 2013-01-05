#ifndef MYTL_ALG_MODEL_QUAT
#define MYTL_ALG_MODEL_QUAT

/*! \file
 * \brief Models a Quaternion Space
 */

#include <cmath>
#include <mytl/vec.hpp>

namespace mytl {

    using std::sin;
    using std::cos;
    using std::acos;
    using std::abs;

    /*! \addtogroup alg
     * @{
     */

    //! Models a Quaternion Space
    /*! Provides the usual quaternion space operations.
     *
     * \b Example:
     * \include quat.cpp
     * \b Output:
     * \include quat.out
     */
    template <typename Scalar>
        class quat : public array<Scalar,4> {
            public:
                quat() :  array<Scalar,4>() {
                    (*this)[0]=1;
                    (*this)[1]=0;
                    (*this)[2]=0;
                    (*this)[3]=0;
                }
                quat(const  array<Scalar,4>& a) :  array<Scalar,4>(a) {}
                template <class T>
                    explicit quat(const  array<T,4>& a) {
                        (*this)[0]=Scalar(a[0]);
                        (*this)[1]=Scalar(a[1]);
                        (*this)[2]=Scalar(a[2]);
                        (*this)[3]=Scalar(a[3]);
                    }
                template <class T>
                    explicit quat(const quat<T>& q) {
                        (*this)[0]=Scalar(q[0]);
                        (*this)[1]=Scalar(q[1]);
                        (*this)[2]=Scalar(q[2]);
                        (*this)[3]=Scalar(q[3]);
                    }
                quat(Scalar q0, Scalar q1, Scalar q2, Scalar q3) {
                    (*this)[0]=q0;
                    (*this)[1]=q1;
                    (*this)[2]=q2;
                    (*this)[3]=q3;
                }
                quat(Scalar re, vec<3,Scalar> im) {
                    (*this)[0]=re;
                    (*this)[1]=im[0];
                    (*this)[2]=im[1];
                    (*this)[3]=im[2];
                }
                Scalar re() const {
                    return (*this)[0];
                }
                vec<3,Scalar> im() const {
                    vec<3,Scalar> v;
                    v[0]=(*this)[1];
                    v[1]=(*this)[2];
                    v[2]=(*this)[3];
                    return v;
                }
                quat& operator+=(const quat& v) {
                    for(dim_t i=0; i<4; ++i) {
                        (*this)[i]+=v[i];
                    }
                    return (*this);
                }
                quat& operator-=(const quat& v) {
                    for(dim_t i=0; i<4; ++i) {
                        (*this)[i]-=v[i];
                    }
                    return (*this);
                }
                quat operator+(const quat& v) const {
                    quat temp(*this);
                    temp+=v;
                    return temp;
                }
                quat operator-(const quat& v) const {
                    quat temp(*this);
                    temp-=v;
                    return temp;
                }
                quat operator-() const {
                    quat temp;
                    temp-=(*this);
                    return temp;
                }
                quat& operator*=(const quat& q) {
                    /* 8 multiplications - see "THE COMPLEXITY OF THE QUATERNION PRODUCT",
                       T. D. Howell J-C. Lafon*/
                    Scalar t[8];
                    t[0]=(*this)[0]*q[0];
                    t[1]=(*this)[3]*q[2];
                    t[2]=(*this)[1]*q[3];
                    t[3]=(*this)[2]*q[1];
                    t[4]=((*this)[0]+(*this)[1]+(*this)[2]+(*this)[3])*(q[0]+q[1]+q[2]+q[3]);
                    t[5]=((*this)[0]+(*this)[1]-(*this)[2]-(*this)[3])*(q[0]+q[1]-q[2]-q[3]);
                    t[6]=((*this)[0]-(*this)[1]+(*this)[2]-(*this)[3])*(q[0]-q[1]+q[2]-q[3]);
                    t[7]=((*this)[0]-(*this)[1]-(*this)[2]+(*this)[3])*(q[0]-q[1]-q[2]+q[3]);
                    (*this)[0]= 2*t[0]-(t[4]+t[5]+t[6]+t[7])/4;
                    (*this)[1]=-2*t[1]+(t[4]+t[5]-t[6]-t[7])/4;
                    (*this)[2]=-2*t[2]+(t[4]-t[5]+t[6]-t[7])/4;
                    (*this)[3]=-2*t[3]+(t[4]-t[5]-t[6]+t[7])/4;
                    return (*this);
                }
                quat operator*(const quat& q) const {
                    quat result(*this);
                    result*=q;
                    return result;
                }
                quat& operator*=(const Scalar& s) {
                    for(dim_t i=0; i<4; ++i) {
                        (*this)[i]*=s;
                    }
                    return (*this);
                }
                quat operator*(const Scalar& s) const {
                    quat temp(*this);
                    temp*=s;
                    return temp;
                }
        };

    template <typename Scalar>
        quat<Scalar> operator*(const Scalar& s, const quat<Scalar>& q) {
            quat<Scalar> temp(q);
            temp*=s;
            return temp;
        }

    template <typename Scalar>
        Scalar dot(const quat<Scalar>& a, const quat<Scalar>& b) {
            return dot(a.im(), b.im())+a.re()*b.re();
        }

    template <typename Scalar>
        quat<Scalar> conj(const quat<Scalar>& a) {
            const Scalar minusone=-1;
            quat<Scalar> result(a);
            result[1]*=minusone; result[2]*=minusone; result[3]*=minusone;
            return result;
        }

    template <typename Scalar>
        quat<Scalar>& operator/=(quat<Scalar>& a, const quat<Scalar>& b) {
            const Scalar one=1;
            a*=conj(b)*(one/dot(b,b));
            return a;
        }

    template <typename Scalar>
        quat<Scalar> operator/(const quat<Scalar>& a, const quat<Scalar>& b) {
            quat<Scalar> result(a);
            result/=b;
            return result;
        }
    template <typename Scalar>
        quat<Scalar> operator/(const Scalar& a, const quat<Scalar>& b) {
            quat<Scalar> result;
            result=conj(b)*(a/dot(b,b));
            return result;
        }

    //! Computes the axis of rotation given by q
    template <typename Scalar>
        vec<3,Scalar> axis(const quat<Scalar>& q) {
            Scalar s=sin(acos(q.re()));
            if(fabs(s)<0.00001)
                return vec<3,Scalar>();
            else
                return (1/s)*q.im();
        }

    //! Computes the angle of rotation given by q
    template <typename Scalar>
        Scalar angle(const quat<Scalar>& q) {
            return 2.0*acos(q.re());
        }

    template <typename Scalar>
        vec<3,Scalar> action(const quat<Scalar>& q, const vec<3, Scalar>& v) {
            quat<Scalar> vq(0, v);
            quat<Scalar> temp=q*vq/q;
            return temp.im();
        }

    //! Computes quaternion from angle and axis of rotation
    template <typename Scalar>
        quat<Scalar> rotation(Scalar th, const vec<3,Scalar>& ax) {
            Scalar thtwo=th/2;
            Scalar cothtwo=cos(thtwo);
            Scalar sithtwo=sin(thtwo);
            quat<Scalar> temp(cothtwo, sithtwo*ax);
            return temp;
        }

    //! Computes quaternion witch represents rotation from v0 to v1
    template <typename Scalar>
        quat<Scalar> rotation(const vec<3,Scalar>& v0, const vec<3,Scalar>& v1) {
            Scalar d=dot(v0, v1);
            if(abs(d)>.999999)
                return quat<Scalar>(1, 0, 0, 0);
            Scalar th=acos(d);
            vec<3, Scalar> n=cross(v0, v1);
            normalize(n);
            return rotation(th, n);
        }

    /*! @} */

}

#endif
