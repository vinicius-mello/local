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
        array(size_t depth, size_t height, size_t width);
        array(size_t height, size_t width);
        array(size_t width);
        array(size_t width, void * d, size_t offset=0);
        array(size_t height, size_t width, void * d, size_t offset=0);
        array(const array& bl);
        ~array();
        array& operator=(const array& b);
        array(char * filename);
        void from_double(const array<double>& bl);
        void to_double(array<double>& bl) const;
        void save(char * filename) const;
        void read(char * filename);
        void write(char * filename);
        T get(size_t i) const;
        T set(size_t i, T v);
        size_t offset(size_t i, size_t j) const;
        size_t offset(size_t k, size_t i, size_t j) const;
        T get(size_t i, size_t j) const;
        T set(size_t i, size_t j, T v);
        T get(size_t k, size_t i, size_t j) const;
        T set(size_t k, size_t i, size_t j, T v);
        T add_to(size_t i, T v);
        T add_to(size_t i, size_t j, T v);
        T add_to(size_t k, size_t i, size_t j, T v);
        T sym_get(size_t i, size_t j) const;
        T sym_set(size_t i, size_t j, T v);
        array<T> row(size_t k, size_t i);
        array<T> row(size_t i);
        array<T> plane(size_t k);
        T * data(size_t offset=0);
        T * data(size_t i, size_t j);
        T * data(size_t k, size_t i, size_t j);
        void * ptr();
        void copy(const array& b, size_t offset=0);
        void zero();
        void set_all(T v);
        size_t size() const;
        size_t size_of() const;
        size_t depth() const;
        size_t height() const;
        size_t width() const;
        size_t dim() const;
        size_t rows() const;
        size_t columns() const;
        void rearrange(const char * ijk, array<T>& y) const;
};

