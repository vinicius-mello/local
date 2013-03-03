%include "../swig/gsl.i"
namespace gsl {

%native(minimize) int lua_multimin_minimize(lua_State * L);
%native(solve) int lua_multiroot_solve(lua_State * L);
%native(integrate) int lua_integration_integrate(lua_State * L);

};
%{
#include "luagsl.cpp"
%}

