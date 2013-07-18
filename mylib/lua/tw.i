%include "../swig/tw.i"

namespace tw {

%native(AddButtonLua) int lua_AddButtonLua(lua_State * L);
%native(UpdateCallback) int lua_UpdateCallback(lua_State * L);
%native(ModifiersFunc) int lua_ModifiersFunc(lua_State * L);

};


%{
#include "luatw.cpp"
%}

