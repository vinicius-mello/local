#ifndef WRAP_ARRAY_HPP
#define WRAP_ARRAY_HPP
#include "debug.h"

typedef unsigned int uint;
typedef unsigned char byte;

template <class T>
class array {
	bool alloc;
	size_t dim_;
	size_t width_;
	T * data_;
	public:
	array() : alloc(false), dim_(0) {
	  debug_print("array default(%p): alloc?%d\n",this,alloc?1:0);
	}
	array(size_t n, size_t m=1) : alloc(true), dim_(n), width_(m) {
	  debug_print("array new(%p): alloc?%d\n",this,alloc?1:0);
	  data_=new T[n*m];
	}
	array(size_t n, void * d) : alloc(false), dim_(n), width_(1) {
	  debug_print("array alias(%p): alloc?%d\n",this,alloc?1:0);
	  data_=(T *)d;
	}
	array(size_t n, size_t m, void * d) : alloc(false), dim_(n), width_(m) {
	  debug_print("array alias(%p): alloc?%d\n",this,alloc?1:0);
	  data_=(T *)d;
	}
	array(const array& bl) : alloc(false), dim_(bl.dim_), width_(bl.width_), data_(bl.data_) 
	{
	  debug_print("array copy_cons(%p): alloc?%d\n",this,alloc?1:0);
	}
	~array() {
	  debug_print("~array(%p): alloc?%d\n",this,alloc?1:0);
		if(alloc) delete [] data_;
	}
  array& operator=(const array& b) {
	  debug_print("array attrib(%p)=(%p): alloc?%d\n",this,&b,alloc?1:0);
		if(alloc) copy(b);
		else { data_=b.data_; dim_=b.dim_; width_=b.width_;}
		return (*this);
	}
	T get(size_t i, size_t j=0) const {
		return data_[i*width_+j];
	}
	T set(size_t i, T v) {
		data_[i*width_]=v;
		return v;
	}
	T set(size_t i, size_t j, T v) {
		data_[i*width_+j]=v;
		return v;
	}
	const T& operator[](size_t i) const {
	  return data_[i];
	}
	T& operator[](size_t i) {
	  return data_[i];
	}
	T * data() const {
	  return data_;
	}
	void copy(const array& b) {
		for(size_t i=0;i<size();++i) data_[i]=b.data_[i];
	}
	void zero() {
		for(size_t i=0;i<size();++i) data_[i]=0;
	}
	void set_all(T v) {
		for(size_t i=0;i<size();++i) data_[i]=v;
	}
	void times_to(const array& x, array& y) const {
	  for(size_t j=0;j<width_;++j)
		for(size_t i=0;i<dim_;++i) y.data_[i*width_+j]=data_[i*width_+j]*x.data_[i];
	}
	void times(const array& x) {
	  for(size_t j=0;j<width_;++j)
		for(size_t i=0;i<dim_;++i) data_[i*width_+j]*=x.data_[i];
	}
	void sum_to(const array& x, array& y) const {
	  for(size_t j=0;j<width_;++j)
		for(size_t i=0;i<dim_;++i) y.data_[i*width_+j]=data_[i*width_+j]+x.data_[i*width_+j];
	}
	void sum(const array& x) {
	  for(size_t j=0;j<width_;++j)
		for(size_t i=0;i<dim_;++i) data_[i*width_+j]+=x.data_[i*width_+j];
	}
	size_t size() const {
		return dim_*width_;
	}
	size_t width() const {
		return width_;
	}
	size_t dim() const {
		return dim_;
	}
	size_t rows() const {
		return dim_;
	}
	size_t columns() const {
		return width_;
	}
};

#endif // WRAP_ARRAY_HPP
