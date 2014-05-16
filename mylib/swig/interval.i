%module interval
%{
#include <boost/numeric/interval.hpp>
using namespace boost;
using namespace numeric;
using namespace interval_lib;

typedef interval<double, 
 policies<save_state<rounded_transc_exact<double> >, 
 checking_base<double> > > I;
%}

class I {
    public:
        I();
        I(double l);
        I(double l, double u);
        I(const I& i);
        I &operator=(double v);
        I &operator=(I i);
        void assign(double l, double u);
        double lower();
        double upper();
        static I empty();
        static I whole();
        static I hull(double x, double y);        
};

%extend I {
    
    I operator+(const I& i) {
        return (*$self)+i;
    };
    I operator-(const I& i) {
        return (*$self)-i;
    };
    I operator*(const I& i) {
        return (*$self)*i;
    };
    I operator/(const I& i) {
        return (*$self)/i;
    };    
    I operator+(double i) {
        return (*$self)+i;
    };
    I operator-(double i) {
        return (*$self)-i;
    };
    I operator*(double i) {
        return (*$self)*i;
    };
    I operator/(double i) {
        return (*$self)/i;
    };

    I __neg__() {
        return -(*$self);
    }; 

    I __pow__(int e) {
        return pow((*$self),e);
    }
    const char *__str__() {
       static char tmp[1024];
       sprintf(tmp,"[%g,%g]", $self->lower(),$self->upper());
       return tmp;
    }
    double median() {
        return median(*$self);
    }
    double width() {
        return width(*$self);
    }
    double norm() {
        return norm(*$self);
    }
    double in(double x) {
        return in(x,*$self);
    }
    double zero_in() {
        return zero_in(*$self);
    }

};


I square(const I& i);
I pow(const I& i, int e);
I exp(const I& i);
I log(const I& i);
I sqrt(const I& i);
I sin(const I& i);
I cos(const I& i);
I tan(const I& i);
I asin(const I& i);
I acos(const I& i);
I atan(const I& i);
I sinh(const I& i);
I cosh(const I& i);
I tanh(const I& i);
I asinh(const I& i);
I acosh(const I& i);
I atanh(const I& i);


/*

    */



