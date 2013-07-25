#include <mytl/glut.hpp>

struct params {
    lua_State * L;
    int t_index;
    bool first;
};

params windows[256];

void idle_cb() {
    lua_rawgeti(windows[0].L,LUA_REGISTRYINDEX,windows[0].t_index);
    lua_pcall(windows[0].L, 0, 0, 0);
}

void display_cb() {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Display");
    lua_gettable(L,-2);
    if(lua_isnil(L,-1)) {
        fprintf(stderr,"No Display method!\n");
        lua_pop(L,2);
    } else {
        lua_insert(L,1);
        lua_pcall(L, 1, 0, 0);
    }
}

void reshape_cb(int width, int height) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    bool first=windows[id].first;
    if(first) {
        lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
        lua_pushstring(L,"Init");
        lua_gettable(L,-2);
        if(lua_isnil(L,-1)) lua_pop(L,2);
        else {
            lua_insert(L,1);
            lua_pcall(L, 1, 0, 0);
            windows[id].first=false;
        }
    }
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Reshape");
    lua_gettable(L,-2);
    if(lua_isnil(L,-1)) {
        fprintf(stderr,"No Reshape method!\n");
        lua_pop(L,2);
    } else {
        lua_insert(L,1);
        lua_pushnumber(L,width);
        lua_pushnumber(L,height);
        lua_pcall(L, 3, 0, 0);
    }
}

void keyboard_cb(unsigned char key, int x, int y) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Keyboard");
    lua_gettable(L,-2);
    if(!lua_isnil(L,-1)) {
        lua_insert(L,1);
        lua_pushnumber(L,key);
        lua_pushnumber(L,x);
        lua_pushnumber(L,y);
        lua_pcall(L, 4, 0, 0);
    } else lua_pop(L,2);
}

void mouse_cb(int button, int state, int x, int y) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Mouse");
    lua_gettable(L,-2);
    if(!lua_isnil(L,-1)) {
        lua_insert(L,1);
        lua_pushnumber(L,button);
        lua_pushnumber(L,state);
        lua_pushnumber(L,x);
        lua_pushnumber(L,y);
        lua_pcall(L, 5, 0, 0);
    } else lua_pop(L,2);
}

void passive_motion_cb(int x, int y) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"PassiveMotion");
    lua_gettable(L,-2);
    if(!lua_isnil(L,-1)) {
        lua_insert(L,1);
        lua_pushnumber(L,x);
        lua_pushnumber(L,y);
        lua_pcall(L, 3, 0, 0);
    } else lua_pop(L,2);
}

void motion_cb(int x, int y) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Motion");
    lua_gettable(L,-2);
    if(!lua_isnil(L,-1)) {
        lua_insert(L,1);
        lua_pushnumber(L,x);
        lua_pushnumber(L,y);
        lua_pcall(L, 3, 0, 0);
    } else lua_pop(L,2);
}

void special_cb(int key, int x, int y) {
    int id=glutGetWindow();
    lua_State * L=windows[id].L;
    int t_index=windows[id].t_index;
    lua_rawgeti(L,LUA_REGISTRYINDEX,t_index);
    lua_pushstring(L,"Special");
    lua_gettable(L,-2);
    if(!lua_isnil(L,-1)) {
        lua_insert(L,1);
        lua_pushnumber(L,key);
        lua_pushnumber(L,x);
        lua_pushnumber(L,y);
        lua_pcall(L, 4, 0, 0);
    } else lua_pop(L,2);
}

int lua_Init(lua_State * L) {
    int argc=0;
    char argv;
    char * argv_ptr=&argv;
    glutInit(&argc,&argv_ptr);
    for(int i=0;i<256;++i) windows[i].L=0;
    windows[0].t_index=-1; //idle;
    return 0;
}

int lua_ActiveCtrl(lua_State * L) {
    unsigned status=(unsigned)lua_tonumber(L,-1);
    lua_pop(L,1);
    lua_pushboolean(L,status&GLUT_ACTIVE_CTRL);
    return 1;
}

int lua_ActiveShift(lua_State * L) {
    unsigned status=(unsigned)lua_tonumber(L,-1);
    lua_pop(L,1);
    lua_pushboolean(L,status&GLUT_ACTIVE_SHIFT);
    return 1;
}

int lua_ActiveAlt(lua_State * L) {
    unsigned status=(unsigned)lua_tonumber(L,-1);
    lua_pop(L,1);
    lua_pushboolean(L,status&GLUT_ACTIVE_ALT);
    return 1;
}

void register_cb() {
    glutDisplayFunc(display_cb);
    glutReshapeFunc(reshape_cb);
    glutKeyboardFunc(keyboard_cb);
    glutMouseFunc(mouse_cb);
    glutMotionFunc(motion_cb);
    glutPassiveMotionFunc(passive_motion_cb);
    glutSpecialFunc(special_cb);
}

int lua_Funcs(lua_State * L) {
    int id=glutGetWindow();
    int r = luaL_ref(L, LUA_REGISTRYINDEX);
    windows[id].L=L;
    windows[id].t_index=r;
    register_cb();
    return 0;
}

int lua_Idle(lua_State * L) {
    if(lua_isnil(L,-1))
        glutIdleFunc(0);
    else  {
        windows[0].L=L;
        if(windows[0].t_index==-1)
            windows[0].t_index = luaL_ref(L, LUA_REGISTRYINDEX);
        else {
            luaL_unref(L, LUA_REGISTRYINDEX,windows[0].t_index);
            windows[0].t_index = luaL_ref(L, LUA_REGISTRYINDEX);
        }
        glutIdleFunc(idle_cb);
    }
    return 0;
}

int lua_PostRedisplayOthers(lua_State * L) {
    int id=glutGetWindow();
    for(int i=0;i<256;++i) {
        if(windows[i].L!=0 && i!=id) {
            glutSetWindow(i);
            glutPostRedisplay();
        }
    }
    glutSetWindow(id);
}

int lua_NewWindow(lua_State * L) {
    const char * name=lua_tostring(L,-1);
    int id=glutCreateWindow(name);
    lua_pop(L,1);
    lua_newtable(L);
    lua_pushstring(L,"id");
    lua_pushnumber(L,id);
    lua_settable(L,-3);
    lua_pushstring(L,"name");
    lua_pushstring(L,name);
    lua_settable(L,-3);
    int r = luaL_ref(L, LUA_REGISTRYINDEX);
    windows[id].L=L;
    windows[id].t_index=r;
    windows[id].first=true;
    register_cb();
    lua_rawgeti(L,LUA_REGISTRYINDEX,r);
    return 1;
}
