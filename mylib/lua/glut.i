%include "../swig/glut.i"

namespace glut {

%native(Funcs) int lua_Funcs(lua_State * L);
%native(Init) int lua_Init(lua_State * L);
%native(IdleFunc) int lua_Idle(lua_State * L);
%native(PostRedisplayOthers) int lua_PostRedisplayOthers(lua_State * L);
%native(NewWindow) int lua_NewWindow(lua_State * L);
%native(ActiveCtrl) int lua_ActiveCtrl(lua_State * L);
%native(ActiveShift) int lua_ActiveShift(lua_State * L);
%native(ActiveAlt) int lua_ActiveAlt(lua_State * L);

};


%{
#include "luaglut.cpp"
%}

