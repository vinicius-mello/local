#include "tw.hpp"
#include <map>
#include <vector>
#include <string>

using std::string;
using std::vector;
using std::map;


struct TwVar {
    TwType type;
    void * data;
};

map<string,TwVar> vars;
vector<string> names;

int TwInit(TwGraphAPI p) {
    TwInit(p,0);
}

void TW_CALL set_cb(const void *value, void *clientData) {
    size_t id=(size_t)clientData;
    TwVar var;
    var=vars[names[id]];
    int * ti;
    double * td;
    switch(var.type) {
        case TW_TYPE_BOOL32:
            ti=(int *)var.data;
            *ti=*((int *)value);
            break;
        case TW_TYPE_DOUBLE:
            td=(double *)var.data;
            *td=*((double *)value);
            break;
        case TW_TYPE_COLOR3F:
            {
                array<float> a1(3,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a2.copy(a1);
            }
            break;
    }
}

void TW_CALL get_cb(void *value, void *clientData) {
    size_t id=(size_t)clientData;
    TwVar var;
    var=vars[names[id]];
    int * ti;
    double * td;
    switch(var.type) {
        case TW_TYPE_BOOL32:
            ti=(int *)var.data;
            *((int *)value)=*ti;
            break;
        case TW_TYPE_DOUBLE:
            td=(double *)var.data;
            *((double *)value)=*td;
            break;
        case TW_TYPE_COLOR3F:
            {
                array<float> a1(3,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a1.copy(a2);
            }
            break;
    }

}

void TwNewVar(const char * bar_name, const char * var_name, TwType type, const char * prop, bool ro) {
    TwVar var;
    var.type=type;
    var.data=0;
    switch(type) {
        case TW_TYPE_BOOL32:
            var.data=new int(0);
            break;
        case TW_TYPE_DOUBLE:
            var.data=new double(0);
            break;
        case TW_TYPE_COLOR3F:
            var.data=new array<float>(3);
            break;
    }
    string full_name=string(bar_name)+"/"+var_name;
    vars[full_name]=var;
    TwAddVarCB(TwGetBarByName(bar_name), var_name,
            type,ro?0:set_cb, get_cb, (void*)names.size(), prop);
    names.push_back(full_name);
}

TwType TwGetVarType(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    return vars[full_name].type;
}

bool TwGetBoolVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    int * value=(int *)vars[full_name].data;
    return (bool)*value;
}

void TwSetBoolVarByName(const char * bar_name, const char * var_name, bool v) {
    string full_name=string(bar_name)+"/"+var_name;
    int * value=(int *)vars[full_name].data;
    *value=v?1:0;
}

double TwGetDoubleVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    double * value=(double *)vars[full_name].data;
    return *value;
}

void TwSetDoubleVarByName(const char * bar_name, const char * var_name, double v) {
    string full_name=string(bar_name)+"/"+var_name;
    double * value=(double *)vars[full_name].data;
    *value=v;
}

array<double> TwGetArrayDoubleVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    array<double> * value=(array<double> *)vars[full_name].data;
    return *value;
}

void TwSetArrayDoubleVarByName(const char * bar_name, const char * var_name, const array<double>& v) {
    string full_name=string(bar_name)+"/"+var_name;
    array<double> * value=(array<double> *)vars[full_name].data;
    value->copy(v);
}

array<float> TwGetArrayFloatVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    array<float> * value=(array<float> *)vars[full_name].data;
    return *value;
}

void TwSetArrayFloatVarByName(const char * bar_name, const char * var_name, const array<float>& v) {
    string full_name=string(bar_name)+"/"+var_name;
    array<float> * value=(array<float> *)vars[full_name].data;
    value->copy(v);
}

