%module array
%{
#include <wrappers/array.hpp>
%}

typedef unsigned int uint;
typedef unsigned char byte;

template <class T>
class array {
	public:
	array(); 
	array(size_t n, size_t m=1);
	array(size_t n, void * d, size_t offset=0);
	array(size_t n, size_t m, void * d);
	array(const array& bl);
  array& operator=(const array& b);
	~array(); 
  array(char * filename);
	void save(char * filename);
	T get(size_t i, size_t j=0) const;
	T set(size_t i, T v);
	T add_to(size_t i, T v);
	T set(size_t i, size_t j, T v);
	T sym_get(size_t i, size_t j) const;
	T sym_set(size_t i, size_t j, T v);
	T * data(size_t offset=0) const;
	void copy(array& b, size_t offset=0);
	void rearrange(size_t m, size_t n, size_t p,
	 	const char * ijk, array<T>& y) const;
	void zero();
	void set_all(T v);
	void times_to(const array& x, array& y) const;
	void times(const array& x);
	void sum_to(const array& x, array& y) const;
	void sum(const array& x);
	size_t size() const;
	size_t width() const;
	size_t dim() const;
	size_t rows() const;
	size_t columns() const;
};

%template(array_double) array<double>;
%template(array_float) array<float>;
%template(array_int) array<int>;
%template(array_uint) array<uint>;
%template(array_size_t) array<size_t>;
%template(array_char) array<char>;
%template(array_byte) array<byte>;


