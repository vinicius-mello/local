#ifndef WRAP_ANTTWEAKBAR_HPP
#define WRAP_ANTTWEAKBAR_HPP
#include <AntTweakBar.h>
#include "array.hpp"
#include <string>

#define TW_TYPE_CSSTRING_256 TW_TYPE_CSSTRING(256)

int TwInit(TwGraphAPI p);
void TwNewVar(const char * bar_name, const char * var_name, TwType type, const char * prop=0, bool ro=false);
void TwNewEnum(const char * bar_name, const char * var_name, const char * enum_name, const char * enum_values, const char * prop=0);
TwType TwGetVarType(const char * bar_name, const char * var_name);
bool TwGetBoolVarByName(const char * bar_name, const char * var_name);
void TwSetBoolVarByName(const char * bar_name, const char * var_name, bool value);
int TwGetIntVarByName(const char * bar_name, const char * var_name);
void TwSetIntVarByName(const char * bar_name, const char * var_name, int value);
char * TwGetStringVarByName(const char * bar_name, const char * var_name);
void TwSetStringVarByName(const char * bar_name, const char * var_name, char * value);
double TwGetDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetDoubleVarByName(const char * bar_name, const char * var_name, double value);
array<double> TwGetArrayDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetArrayDoubleVarByName(const char * bar_name, const char * var_name, const array<double>& value);
array<float> TwGetArrayFloatVarByName(const char * bar_name, const char * var_name);
void TwSetArrayFloatVarByName(const char * bar_name, const char * var_name, const array<float>& value);
void TwAddSeparatorByName(const char * bar_name, const char * sp_name);
void TwAddButtonByName(const char * bar_name, const char * button_name,
        TwButtonCallback callback, void *clientData);
void TwUpdateCallback(void (*cb)(const char * string));

#endif // WRAP_ANTTWEAKBAR_HPP
