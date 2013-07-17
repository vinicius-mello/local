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
    size_t depth_;
    size_t height_;
    size_t width_;
    T * data_;
    public:
    array() : alloc(false), height_(0), data_(0) {
        debug_print("array default(%p): alloc?%d\n",this,alloc?1:0);
    }
    array(size_t depth, size_t height, size_t width)
        : alloc(true), depth_(depth), height_(height), width_(width) {
            debug_print("array new(%p): alloc?%d\n",this,alloc?1:0);
            data_=new T[depth_*height_*width_];
        }
    array(size_t height, size_t width)
        : alloc(true), depth_(1), height_(height), width_(width) {
            debug_print("array new(%p): alloc?%d\n",this,alloc?1:0);
            data_=new T[depth_*height_*width_];
        }
    array(size_t width)
        : alloc(true), depth_(1), height_(1), width_(width) {
            debug_print("array new(%p): alloc?%d\n",this,alloc?1:0);
            data_=new T[depth_*height_*width_];
        }
    array(size_t width, void * d, size_t offset=0)
        : alloc(false), depth_(1), height_(1), width_(width) {
            debug_print("array alias(%p): alloc?%d\n",this,alloc?1:0);
            data_=((T *)d)+offset;
        }
    array(size_t height, size_t width, void * d, size_t offset=0)
        : alloc(false), depth_(1), height_(height), width_(width) {
            debug_print("array alias(%p): alloc?%d\n",this,alloc?1:0);
            data_=((T *)d)+offset;
        }
    array(const array& bl)
        : alloc(false), depth_(bl.depth_),  height_(bl.height_), width_(bl.width_), data_(bl.data_)
    {
        debug_print("array copy_cons(%p): alloc?%d\n",this,alloc?1:0);
    }
    void from_double(const array<double>& bl)
    {
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    T d=(T)bl.get(k,i,j);
                    set(k,i,j,d);
                }
            }
        }
    }
    void to_double(array<double>& bl) const
    {
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    double d=(double)get(k,i,j);
                    bl.set(k,i,j,d);
                }
            }
        }
    }
    ~array() {
        debug_print("~array(%p): alloc?%d\n",this,alloc?1:0);
        if(alloc) delete [] data_;
    }
    array& operator=(const array& b) {
        debug_print("array attrib(%p)=(%p): alloc?%d\n",this,&b,alloc?1:0);
        if(alloc) copy(b);
        else { data_=b.data_; depth_=b.depth_;height_=b.height_; width_=b.width_;}
        return (*this);
    }
    array(char * filename) {
        ifstream in(filename);
        in>>depth_;
        in>>height_;
        in>>width_;
        data_=new T[depth_*height_*width_];
        alloc=true;
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    T d;
                    in>>d;
                    set(k,i,j,d);
                }
            }
        }
    }
    void save(char * filename) const {
        ofstream out(filename);
        out<<depth_<<" ";
        out<<height_<<" ";
        out<<width_<<endl;
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    T d=get(k,i,j);
                    out<<d;
                    if(j!=(width_-1)) out<<" ";
                }
                out<<endl;
            }
            out<<endl;
        }
    }
    void read(char * filename) {
        ifstream in(filename,ifstream::binary);
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    T d;
                    in.read((char *)&d,sizeof(T));
                    set(k,i,j,d);
                }
            }
        }
    }
    void write(char * filename) const {
        ofstream out(filename,ofstream::binary);
        for(int k=0;k<depth_;++k) {
            for(int i=0;i<height_;++i) {
                for(int j=0;j<width_;++j) {
                    T d=get(k,i,j);
                    out.write((char *)&d,sizeof(T));
                }
            }
        }
    }

    T get(size_t i) const {
        return data_[i];
    }
    T set(size_t i, T v) {
        data_[i]=v;
        return v;
    }
    size_t offset(size_t i, size_t j) const {
        return i*width_+j;
    }
    size_t offset(size_t k, size_t i, size_t j) const {
        return k*width_*height_+i*width_+j;
    }
    T get(size_t i, size_t j) const {
        return data_[offset(i,j)];
    }
    T set(size_t i, size_t j, T v) {
        data_[offset(i,j)]=v;
        return v;
    }
    T get(size_t k, size_t i, size_t j) const {
        return data_[offset(k,i,j)];
    }
    T set(size_t k, size_t i, size_t j, T v) {
        data_[offset(k,i,j)]=v;
        return v;
    }
    T add_to(size_t i, T v) {
        data_[i]+=v;
        return v;
    }
    T add_to(size_t i, size_t j, T v) {
        data_[offset(i,j)]+=v;
        return v;
    }
    T add_to(size_t k, size_t i, size_t j, T v) {
        data_[offset(k,i,j)]+=v;
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
    T * data(size_t offset=0) {
        return data_+offset;
    }
    const T * data(size_t offset=0) const {
        return data_+offset;
    }
    array<T> row(size_t k, size_t i) {
        return array<T>(width_,data(offset(k,i,0)));
    }
    array<T> row(size_t i) {
        return array<T>(width_,data(offset(0,i,0)));
    }
    array<T> row(size_t i) const {
        return array<T>(width_,(void *)data(offset(0,i,0)));
    }
    array<T> plane(size_t k) {
        return array<T>(height_,width_,data(offset(k,0,0)));
    }
    T * data(size_t k, size_t i, size_t j) {
        return data_+offset(k,i,j);
    }
    const T * data(size_t k, size_t i, size_t j) const {
        return data_+offset(k,i,j);
    }
    T * data(size_t i, size_t j) {
        return data_+offset(i,j);
    }
    void * ptr() {
        return (void *)data_;
    }
    const T * data(size_t i, size_t j) const {
        return data_+offset(i,j);
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
    size_t size() const {
        return depth_*height_*width_;
    }
    size_t size_of() const {
        return depth_*height_*width_*sizeof(T);
    }
    size_t depth() const {
        return depth_;
    }
    size_t height() const {
        return height_;
    }
    size_t width() const {
        return width_;
    }
    size_t dim() const {
        return size();
    }
    size_t rows() const {
        return height_;
    }
    size_t columns() const {
        return width_;
    }
    void rearrange(const char * ijk, array<T>& y) const {
        char perm[3];
        perm[0]=ijk[0]-'0';
        perm[1]=ijk[1]-'0';
        perm[2]=ijk[2]-'0';
        size_t size[3];
        size[0]=depth_;
        size[1]=height_;
        size[2]=width_;
        size_t stride[3];
        stride[0]=size[perm[1]]*size[perm[2]];
        stride[1]=size[perm[2]];
        stride[2]=1;
        for(size_t k=0;k<depth_;++k) {
            for(size_t i=0;i<height_;++i) {
                for(size_t j=0;j<width_;++j) {
                    y.data_[k*stride[perm[0]]+i*stride[perm[1]]+j*stride[perm[2]]]=
                        get(k,i,j);
                }
            }
        }
        y.depth_=size[perm[0]];
        y.height_=size[perm[1]];
        y.width_=size[perm[2]];
    }
};

#endif // WRAP_ARRAY_HPP
