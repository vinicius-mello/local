#ifndef WRAP_CUBIC_HPP
#define WRAP_CUBIC_HPP
#include "array.hpp"
#include <cmath>

template <class T>
T initial_causal_coefficient(size_t l, const T* c)
{
    const T pole=(T)(sqrt(3.0)-2.0);
    size_t h;
    if(l<28)
        h=l;
    else
        h=28;

    // this initialization corresponds to mirror boundaries
    // accelerated loop
    T zn = pole;
    T Sum = c[0];
    for (size_t n = 1; n < h; n++) {
        Sum += zn * c[n];
        zn *= pole;
    }
    return(Sum);
}

template <class T>
T initial_anti_causal_coefficient( size_t l, const T* c)
{
    // this initialization corresponds to mirror boundaries
    const T pole=(T)(sqrt(3.0)-2.0);
    return((pole / (pole * pole - 1.0)) * (pole * c[l - 2] + c[l - 1]));
}

template <class T>
void convert_to_cubic( size_t l, T* c)
{
    if(l<=1) return;
    const T pole=(T)(sqrt(3.0)-2.0);
    // compute the overall gain
    const T lambda =(T)((1.0 - pole) * (1.0 - 1.0 / pole));

    // causal initialization
    c[0] = lambda * initial_causal_coefficient(l,c);
    // causal recursion
    for (size_t n = 1; n < l; n++) {
        c[n] = lambda * c[n] + pole * c[n - 1];
    }
    // anticausal initialization
    c[l - 1] = initial_anti_causal_coefficient(l,c);
    // anticausal recursion
    for (int n = l - 2; 0 <= n; n--) {
        c[n] = pole * (c[n + 1] - c[n]);
    }
}

template <class T>
T bspline(T t)
{
    t = fabs(t);
    T a = 2.0 - t;

    if (t < 1.0)
        return 2.0/3.0 - 0.5*t*t*a;
    else if (t < 2.0)
        return a*a*a / 6.0;
    else
        return 0.0;
}

template <class T>
T bsplined(T t)
{
    T c=(t > 0) - (t < 0); //sgn
    t = fabs(t);
    T a = 2.0 - t;

    if (t < 1.0)
        return c*t*(3.0*t-4) / 2.0;
    else if (t < 2.0)
        return -c*a*a / 2.0;
    else
        return 0.0;
}

template <class T>
T bsplinedd(T t)
{
    t = fabs(t);

    if (t < 1.0)
        return 3.0*t-2.0;
    else if (t < 2.0)
        return 2.0-t;
    else
        return 0.0;
}

template <class T>
T cubic_eval(
        size_t l,
        const T* c,
        T t
        )
{
    T tt=t*(l-1);
    T b=floor(tt);
    T delta=tt-b;
    int bi=(int)b;
    T v=0;
    for(int i=-1;i<=2;++i) {
        int index=bi+i;
        if(index<0) index=-index;
        else if(index>=l) index=2*l-index-2;
        v+=c[index]*bspline(delta-i);
    }
    return v;
}

template <class T>
T cubic_evald(
        size_t l,
        const T* c,
        T t
        )
{
    T tt=t*(l-1);
    T b=floor(tt);
    T delta=tt-b;
    int bi=(int)b;
    T v=0;
    for(int i=-1;i<=2;++i) {
        int index=bi+i;
        if(index<0) index=-index;
        else if(index>=l) index=2*l-index-2;
        v+=c[index]*bsplined(delta-i);
    }
    return v*(l-1);
}

template <class T>
void convert_to_cubic(array<T>& c) {
    for(size_t i=0;i<c.rows();++i) {
        for(size_t j=0;j<c.columns();++j) {
            array<T> temp(c.depth());
            for(size_t k=0;k<c.depth();++k) {
                temp.set(k,c.get(k,i,j));
            }
            convert_to_cubic(temp.size(),temp.data());
            for(size_t k=0;k<c.depth();++k) {
                c.set(k,i,j,temp.get(k));
            }
        }
    }
    for(size_t i=0;i<c.rows();++i) {
        for(size_t k=0;k<c.depth();++k) {
            array<T> temp(c.columns());
            for(size_t j=0;j<c.columns();++j) {
                temp.set(j,c.get(k,i,j));
            }
            convert_to_cubic(temp.size(),temp.data());
            for(size_t j=0;j<c.columns();++j) {
                c.set(k,i,j,temp.get(j));
            }
        }
    }
    for(size_t j=0;j<c.columns();++j) {
        for(size_t k=0;k<c.depth();++k) {
            array<T> temp(c.rows());
            for(size_t i=0;i<c.rows();++i) {
                temp.set(i,c.get(k,i,j));
            }
            convert_to_cubic(temp.size(),temp.data());
            for(size_t i=0;i<c.rows();++i) {
                c.set(k,i,j,temp.get(i));
            }
        }
    }
}

template <class T>
T cubic_eval(const array<T>& c, T t) {
    return cubic_eval(c.size(),c.data(),t);
}

template <class T>
T cubic_evald(const array<T>& c, T t) {
    return cubic_evald(c.size(),c.data(),t);
}

template <class T>
T cubic_eval(const array<T>& c, T tx, T ty, T tz) {
    T ttx=tx*(c.width()-1);
    T bx=floor(ttx);
    T deltax=ttx-bx;
    int bix=(int)bx;

    T tty=ty*(c.height()-1);
    T by=floor(tty);
    T deltay=tty-by;
    int biy=(int)by;

    T ttz=tz*(c.depth()-1);
    T bz=floor(ttz);
    T deltaz=ttz-bz;
    int biz=(int)bz;

    T v=0;
    for(int i=-1;i<=2;++i) {
        int indexx=bix+i;
        if(indexx<0) indexx=-indexx;
        else if(indexx>=c.width()) indexx=2*c.width()-indexx-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=c.height()) indexy=2*c.height()-indexy-2;
            for(int k=-1;k<=2;++k) {
                int indexz=biz+k;
                if(indexz<0) indexz=-indexz;
                else if(indexz>=c.depth()) indexz=2*c.depth()-indexz-2;
                v+=c.get(indexz, indexx, indexy)*bspline(deltax-(T)i)*bspline(deltay-(T)j)*bspline(deltaz-(T)k);
            }
        }
    }
    return v;
}

template <class T>
void cubic_evald(const array<T>& c, T tx, T ty, T tz, array<T>& v) {
    T ttx=tx*(c.width()-1);
    T bx=floor(ttx);
    T deltax=ttx-bx;
    int bix=(int)bx;

    T tty=ty*(c.height()-1);
    T by=floor(tty);
    T deltay=tty-by;
    int biy=(int)by;

    T ttz=tz*(c.depth()-1);
    T bz=floor(ttz);
    T deltaz=ttz-bz;
    int biz=(int)bz;

    v.zero();
    for(int i=-1;i<=2;++i) {
        int indexx=bix+i;
        if(indexx<0) indexx=-indexx;
        else if(indexx>=c.width()) indexx=2*c.width()-indexx-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=c.height()) indexy=2*c.height()-indexy-2;
            for(int k=-1;k<=2;++k) {
                int indexz=biz+k;
                if(indexz<0) indexz=-indexz;
                else if(indexz>=c.depth()) indexz=2*c.depth()-indexz-2;
                v.add_to(0,c.get(indexz,indexx,indexy)*bsplined(deltax-(T)i)*bspline(deltay-(T)j)*bspline(deltaz-(T)k));
                v.add_to(1,c.get(indexz,indexx,indexy)*bspline(deltax-(T)i)*bsplined(deltay-(T)j)*bspline(deltaz-(T)k));
                v.add_to(2,c.get(indexz,indexx,indexy)*bspline(deltax-(T)i)*bspline(deltay-(T)j)*bsplined(deltaz-(T)k));
            }
        }
    }
}

template <class T>
void natural_spline(size_t n, const T * x, const T * y, T * y2, T * u) {
    size_t i,k;
    T p,qn,sig,un;
    y2[0]=u[0]=0.0;
    for (i=1;i<n-1;i++) {
        sig=(x[i]-x[i-1])/(x[i+1]-x[i-1]);
        p=sig*y2[i-1]+2.0;
        y2[i]=(sig-1.0)/p;
        u[i]=(y[i+1]-y[i])/(x[i+1]-x[i]) - (y[i]-y[i-1])/(x[i]-x[i-1]);
        u[i]=(6.0*u[i]/(x[i+1]-x[i-1])-sig*u[i-1])/p;
    }
    qn=un=0.0;
    y2[n-1]=(un-qn*u[n-2])/(qn*y2[n-2]+1.0);
    for (k=n-1;k>=1;k--)
        y2[k-1]=y2[k-1]*y2[k]+u[k-1];
}

template <class T>
void natural_spline(size_t n, const T * y, T * y2, T * u) {
    size_t i,k;
    T p,qn,un,h;
    h=1.0/n;
    y2[0]=u[0]=0.0;
    for (i=1;i<n-1;i++) {
        p=0.5*y2[i-1]+2.0;
        y2[i]=-0.5/p;
        u[i]=(y[i+1]-y[i])/h - (y[i]-y[i-1])/h;
        u[i]=(6.0*u[i]/(2*h)-0.5*u[i-1])/p;
    }
    qn=un=0.0;
    y2[n-1]=(un-qn*u[n-2])/(qn*y2[n-2]+1.0);
    for (k=n-1;k>=1;k--)
        y2[k-1]=y2[k-1]*y2[k]+u[k-1];
}

template <class T>
void natural_spline(const array<T>& x, const array<T>& y, array<T>& y2, array<T>& work) {
    natural_spline(y.size(),x.data(),y.data(),y2.data(),work.data());
}

template <class T>
void natural_spline(const array<T>& y, array<T>& y2, array<T>& work) {
    natural_spline(y.size(),y.data(),y2.data(),work.data());
}

template <class T>
T natural_spline_eval(size_t n, const T * xa, const T * ya, const T * y2a,
        T x)
{
    size_t klo,khi,k;
    T h,b,a;
    klo=0;
    khi=n-1;
    while (khi-klo > 1) {
        k=(khi+klo) >> 1;
        if (xa[k] > x) khi=k;
        else klo=k;
    }
    h=xa[khi]-xa[klo];
    a=(xa[khi]-x)/h;
    b=(x-xa[klo])/h;
    return a*ya[klo]+b*ya[khi]+((a*a*a-a)*y2a[klo]+(b*b*b-b)*y2a[khi])*(h*h)/6.0;
}

template <class T>
T natural_spline_eval(size_t n, const T * ya, const T * y2a, T x)
{
    size_t klo,khi,k;
    T h,b,a;
    x=(x>=1)?0.9999999:x;
    h=1.0/(n-1);
    klo=floor(x*(n-1));
    khi=klo+1;
    a=(khi*h-x)/h;
    b=(x-klo*h)/h;
    return a*ya[klo]+b*ya[khi]+((a*a*a-a)*y2a[klo]+(b*b*b-b)*y2a[khi])*(h*h)/6.0;
}

template <class T>
T natural_spline_evald(size_t n, const T * ya, const T * y2a, T x)
{
    size_t klo,khi,k;
    T h,b,a;
    x=(x>=1)?0.9999999:x;
    h=1.0/(n-1);
    klo=floor(x*(n-1));
    khi=klo+1;
    a=(khi*h-x)/h;
    b=(x-klo*h)/h;
    return -ya[klo]/h+ya[khi]/h+((-3.0*a*a+1.0)*y2a[klo]+(3.0*b*b-1.0)*y2a[khi])*h/6.0;
}

template <class T>
T natural_spline_eval(const array<T>& xa, const array<T>& ya, const array<T>& y2a, T x) {
    return natural_spline_eval(xa.size(),xa.data(),ya.data(),y2a.data(),x);
}
/*
template <class T>
T natural_spline_evald(const array<T>& xa, const array<T>& ya, const array<T>& y2a, T x) {
    return natural_spline_evald(xa.size(),xa.data(),ya.data(),y2a.data(),x);
}*/


template <class T>
T natural_spline_eval(const array<T>& ya, const array<T>& y2a, T x) {
    return natural_spline_eval(ya.size(),ya.data(),y2a.data(),x);
}

template <class T>
T natural_spline_evald(const array<T>& ya, const array<T>& y2a, T x) {
    return natural_spline_evald(ya.size(),ya.data(),y2a.data(),x);
}

#endif // WRAP_CUBIC_HPP
