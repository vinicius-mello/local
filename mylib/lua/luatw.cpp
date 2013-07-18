#include <wrappers/tw.hpp>
#include <mytl/glut.hpp>

struct cb_param {
    lua_State * L;
    int f_index;
};

cb_param buttons[256];
int next_id=0;

lua_State * update_L;
int update_r;

void update_cb(const char * name) {
    lua_State * L=update_L;
    lua_rawgeti(L,LUA_REGISTRYINDEX,update_r);
    lua_pushstring(L,name);
    lua_pcall(L, 1, 0, 0);
}

void TW_CALL button_cb(void *param) {
    int id=reinterpret_cast<long>(param);
    lua_State * L=buttons[id].L;
    int f_index=buttons[id].f_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,f_index);
    lua_pcall(L, 0, 0, 0);
}

int lua_AddButtonLua(lua_State * L) {
    int r = luaL_ref(L, LUA_REGISTRYINDEX);
    const char * bar_name=lua_tostring(L,-2);
    const char * button_name=lua_tostring(L,-1);
    lua_pop(L,2);
    buttons[next_id].L=L;
    buttons[next_id].f_index=r;
    TwAddButtonByName(bar_name,button_name,button_cb,(void*)next_id);
    next_id++;
    return 0;
}

int lua_UpdateCallback(lua_State * L) {
    update_r = luaL_ref(L, LUA_REGISTRYINDEX);
    update_L = L;
    TwUpdateCallback(update_cb);
}

int lua_ModifiersFunc(lua_State * L) {
    TwGLUTModifiersFunc(glutGetModifiers);
    return 0;
}
