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
T initial_anti_causal_coefficient(size_t l, const T* c)
{
    // this initialization corresponds to mirror boundaries
    const T pole=(T)(sqrt(3.0)-2.0);
    return((pole / (pole * pole - 1.0)) * (pole * c[l - 2] + c[l - 1]));
}

template <class T>
void convert_to_cubic(size_t l, T* c)
{
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
T cubic_eval(size_t l, const T* c, T t)
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
T cubic_evald(size_t l, const T* c, T t)
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
    return convert_to_cubic(c.size(),c.data());
}

template <class T>
T cubic_eval(const array<T>& c, T t) {
    return cubic_eval(c.size(),c.data(),t);
}

template <class T>
T cubic_evald(const array<T>& c, T t) {
    return cubic_evald(c.size(),c.data(),t);
}

#endif // WRAP_CUBIC_HPP
