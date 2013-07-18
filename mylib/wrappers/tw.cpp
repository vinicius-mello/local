#include "tw.hpp"
#include <map>
#include <vector>
#include <cstring>
#include <string>

using std::string;
using std::vector;
using std::map;

void (*update_cb)(const char * string)=0;

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
    char * tc;
    switch(var.type) {
        case TW_TYPE_BOOL32:
            ti=(int *)var.data;
            *ti=*((int *)value);
            break;
        case TW_TYPE_CSSTRING_256:
            tc=(char *)var.data;
            strncpy(tc,((char *)value),256);
            break;
        case TW_TYPE_DOUBLE:
            td=(double *)var.data;
            *td=*((double *)value);
            break;
        case TW_TYPE_COLOR3F:
        case TW_TYPE_DIR3F:
            {
                array<float> a1(3,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a2.copy(a1);
            }
            break;
        case TW_TYPE_COLOR4F:
        case TW_TYPE_QUAT4F:
            {
                array<float> a1(4,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a2.copy(a1);
            }
            break;
        default:
            ti=(int *)var.data;
            *ti=*((int *)value);
            break;
    }
    if(update_cb) update_cb(names[id].c_str());
}

void TwUpdateCallback(void (*cb)(const char * string)) {
    update_cb=cb;
}

void TW_CALL get_cb(void *value, void *clientData) {
    size_t id=(size_t)clientData;
    TwVar var;
    var=vars[names[id]];
    int * ti;
    double * td;
    char * tc;
    switch(var.type) {
        case TW_TYPE_BOOL32:
            ti=(int *)var.data;
            *((int *)value)=*ti;
            break;
        case TW_TYPE_CSSTRING_256:
            tc=(char *)var.data;
            strncpy(((char *)value),tc,256);
            break;
        case TW_TYPE_DOUBLE:
            td=(double *)var.data;
            *((double *)value)=*td;
            break;
        case TW_TYPE_COLOR3F:
        case TW_TYPE_DIR3F:
            {
                array<float> a1(3,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a1.copy(a2);
            }
            break;
        case TW_TYPE_COLOR4F:
        case TW_TYPE_QUAT4F:
            {
                array<float> a1(4,(float*)value);
                array<float> a2(*((array<float> *)var.data));
                a1.copy(a2);
            }
            break;
        default:
            ti=(int *)var.data;
            *((int *)value)=*ti;
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
        case TW_TYPE_CSSTRING_256:
            var.data=new char[256];
            strcpy((char *)var.data,"");
            break;
        case TW_TYPE_DOUBLE:
            var.data=new double(0);
            break;
        case TW_TYPE_COLOR3F:
        case TW_TYPE_DIR3F:
            var.data=new array<float>(3);
            break;
        case TW_TYPE_COLOR4F:
        case TW_TYPE_QUAT4F:
            var.data=new array<float>(4);
            break;
    }
    string full_name=string(bar_name)+"/"+var_name;
    vars[full_name]=var;
    TwAddVarCB(TwGetBarByName(bar_name), var_name,
            type,ro?0:set_cb, get_cb, (void*)names.size(), prop);
    names.push_back(full_name);
}

void TwNewEnum(const char * bar_name, const char * var_name, const char * enum_name, const char * enum_values, const char * prop) {
    TwVar var;
    var.type=TwDefineEnumFromString(enum_name,enum_values);
    var.data=new int(0);
    string full_name=string(bar_name)+"/"+var_name;
    vars[full_name]=var;
    TwAddVarCB(TwGetBarByName(bar_name), var_name,
            var.type,set_cb, get_cb, (void*)names.size(),prop);
    names.push_back(full_name);
}

TwType TwGetVarType(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    return vars[full_name].type;
}

int TwGetIntVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    int * value=(int *)vars[full_name].data;
    return (int)*value;
}

void TwSetIntVarByName(const char * bar_name, const char * var_name, int v) {
    string full_name=string(bar_name)+"/"+var_name;
    int * value=(int *)vars[full_name].data;
    *value=v;
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

char * TwGetStringVarByName(const char * bar_name, const char * var_name) {
    string full_name=string(bar_name)+"/"+var_name;
    char * value=(char *)vars[full_name].data;
    return value;
}

void TwSetStringVarByName(const char * bar_name, const char * var_name, char * v) {
    string full_name=string(bar_name)+"/"+var_name;
    char * value=(char *)vars[full_name].data;
    strncpy(value,v,256);
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

void TwAddSeparatorByName(const char * bar_name, const char * sp_name) {
    TwAddSeparator(TwGetBarByName(bar_name),sp_name,0);
}

void TwAddButtonByName(const char * bar_name, const char * button_name,
        TwButtonCallback callback, void *clientData) {
    TwAddButton(TwGetBarByName(bar_name),button_name,callback,clientData,0);
}
