#ifndef WRAP_ANTTWEAKBAR_HPP
#define WRAP_ANTTWEAKBAR_HPP
#include <AntTweakBar.h>
#include "array.hpp"
#include <string>

int TwInit(TwGraphAPI p);
void TwNewVar(const char * bar_name, const char * var_name, TwType type, const char * prop=0, bool ro=false);
TwType TwGetVarType(const char * bar_name, const char * var_name);
bool TwGetBoolVarByName(const char * bar_name, const char * var_name);
void TwSetBoolVarByName(const char * bar_name, const char * var_name, bool value);
double TwGetDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetDoubleVarByName(const char * bar_name, const char * var_name, double value);
array<double> TwGetArrayDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetArrayDoubleVarByName(const char * bar_name, const char * var_name, const array<double>& value);
array<float> TwGetArrayFloatVarByName(const char * bar_name, const char * var_name);
void TwSetArrayFloatVarByName(const char * bar_name, const char * var_name, const array<float>& value);


#endif // WRAP_ANTTWEAKBAR_HPP
