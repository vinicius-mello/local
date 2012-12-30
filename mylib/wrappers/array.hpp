#ifndef WRAP_ARRAY_HPP
#define WRAP_ARRAY_HPP
#include "debug.h"
#include <fstream>

using std::ifstream;
using std::ofstream;
using std::endl;

typedef unsigned int uint;
typedef unsigned char byte;

template <class T>
class array {
	bool alloc;
	size_t dim_;
	size_t width_;
	T * data_;
	public:
	array() : alloc(false), dim_(0), data_(0) {
	  debug_print("array default(%p): alloc?%d\n",this,alloc?1:0);
	}
	array(size_t n, size_t m=1) : alloc(true), dim_(n), width_(m) {
	  debug_print("array new(%p): alloc?%d\n",this,alloc?1:0);
	  data_=new T[n*m];
	}
	array(size_t n, void * d, size_t offset=0) : alloc(false), dim_(n), width_(1) {
	  debug_print("array alias(%p): alloc?%d\n",this,alloc?1:0);
	  data_=((T *)d)+offset;
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
	array(char * filename) {
	 	ifstream in(filename);
		int n,m;
		in>>n;
		in>>m;
	  data_=new T[n*m];
		alloc=true;
		dim_=n;
		width_=m;
		for(int i=0;i<n;++i) {
			T d;
			for(int j=0;j<m;++j) { 
				in>>d;
				set(i,j,d);
			}
		} 
	}
	void save(char * filename) {
	 	ofstream out(filename);
		int n,m;
		n=dim_; out<<n<<" ";
		m=width_; out<<m<<endl;
		for(int i=0;i<n;++i) {
			for(int j=0;j<m;++j) {
				T d=get(i,j);
				out<<d;
				if(j!=(m-1)) out<<" ";
			}
			out<<endl;
		} 
	}
	T get(size_t i, size_t j=0) const {
		return data_[i*width_+j];
	}
	T set(size_t i, T v) {
		data_[i*width_]=v;
		return v;
	}
	T add_to(size_t i, T v) {
		data_[i*width_]+=v;
		return v;
	}
	T set(size_t i, size_t j, T v) {
		data_[i*width_+j]=v;
		return v;
	}
	T sym_get(size_t i, size_t j) const {
		if(i>j) return data_[j + (i+1)*i/2]; // column order
		return data_[i + (j+1)*j/2];
	}
	T sym_set(size_t i, size_t j, T v) {
		if(i>j) data_[j + (i+1)*i/2]=v;
		else data_[i + (j+1)*j/2]=v;
		return v;
	}
	const T& operator[](size_t i) const {
	  return data_[i];
	}
	T& operator[](size_t i) {
	  return data_[i];
	}
	T * data(size_t offset=0) const {
	  return data_+offset;
	}
	void copy(const array& b, size_t offset=0) {
		for(size_t i=0;i<b.size();++i) data_[i+offset]=b.data_[i];
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
	void rearrange(size_t m, size_t n, size_t p,
	 	const char * ijk, array<T>& y) const {
		size_t stride[3];
		stride[0]=1;
		stride[1]=m;
		stride[2]=m*n;
		char perm[3];
		perm[0]=ijk[0]-'i';
		perm[1]=ijk[1]-'i';
		perm[2]=ijk[2]-'i';
		for(size_t k=0;k<p;++k) {
			for(size_t j=0;j<n;++j) { 
				for(size_t i=0;i<m;++i) {
					y.data_[k*stride[perm[2]]+j*stride[perm[1]]+i*stride[perm[0]]]=
						data_[k*stride[2]+j*stride[1]+i*stride[0]];
				}
			}
		} 
	}
};

#endif // WRAP_ARRAY_HPP
