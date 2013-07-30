%module cubic
%{
#include <wrappers/cubic.hpp>
%}

template <class T>
void convert_to_cubic(size_t l, T* c);

template <class T>
T cubic_eval(size_t l, T* c, T t);

template <class T>
T cubic_evald(size_t l, T* c, T t);

template <class T>
T cubic_eval(const array<T>& c, T t);

template <class T>
T cubic_evald(const array<T>& c, T t);

template <class T>
T cubic_eval(const array<T>& c, T tx, T ty, T tz);

template <class T>
void cubic_evald(const array<T>& c, T tx, T ty, T tz, array<T>& v);

template <class T>
void convert_to_cubic(array<T>& c);

template <class T>
void natural_spline(size_t n, const T * y, T * y2, T * u);

template <class T>
void natural_spline(const array<T>& y, array<T>& y2, array<T>& work);

template <class T>
void natural_spline(const array<T>& x, const array<T>& y, array<T>& y2, array<T>& work);

template <class T>
T natural_spline_eval(size_t n, const T * ya, const T * y2a, T x);

template <class T>
T natural_spline_evald(size_t n, const T * ya, const T * y2a, T x);

template <class T>
T natural_spline_eval(const array<T>& xa, const array<T>& ya, const array<T>& y2a, T x);

//template <class T>
//T natural_spline_evald(const array<T>& xa, const array<T>& ya, const array<T>& y2a, T x);

template <class T>
T natural_spline_eval(const array<T>& ya, const array<T>& y2a, T x);

template <class T>
T natural_spline_evald(const array<T>& ya, const array<T>& y2a, T x);

%template(convert) convert_to_cubic<double>;
%template(convert) convert_to_cubic<float>;
%template(eval) cubic_eval<double>;
%template(eval) cubic_eval<float>;
%template(evald) cubic_evald<double>;
%template(evald) cubic_evald<float>;
%template(natural_spline) natural_spline<double>;
%template(natural_spline) natural_spline<float>;
%template(natural_spline_eval) natural_spline_eval<double>;
%template(natural_spline_eval) natural_spline_eval<float>;
%template(natural_spline_evald) natural_spline_evald<double>;
%template(natural_spline_evald) natural_spline_evald<float>;





