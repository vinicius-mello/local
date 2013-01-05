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
void convert_to_cubic(array<T>& c);

%template(convert) convert_to_cubic<double>;
%template(convert) convert_to_cubic<float>;
%template(eval) cubic_eval<double>;
%template(eval) cubic_eval<float>;
%template(evald) cubic_evald<double>;
%template(evald) cubic_evald<float>;




