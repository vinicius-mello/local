#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include <tcl.h>
#include <tk.h>

static Tcl_Interp * interp;
static int l_tcl(lua_State *L)
{
    const char *cmd=luaL_checkstring(L,-1);
    Tcl_Eval(interp,cmd);
    lua_remove(L,-1);
    lua_pushstring(L,Tcl_GetStringResult(interp));
    if(lua_isnumber(L,-1)) {
        lua_Number n=lua_tonumber(L,-1);
        lua_remove(L,-1);
        lua_pushnumber(L,n);
    }
    return 1;
}

static int l_tkmainloop(lua_State *L)
{
    Tk_MainLoop();
}

static int lua_proc(ClientData clientdata,
        Tcl_Interp *interp, int argc, const char *argv[])
{
    lua_State *L=(lua_State *)clientdata;
    char * cmd=Tcl_Concat(argc-1,argv+1);
    int st=lua_gettop(L);
    luaL_loadstring(L,cmd);
    lua_call(L,0,LUA_MULTRET);
    st=lua_gettop(L)-st;
    if(st) {
        lua_pop(L,st-1);
        if(lua_isnumber(L,-1)) {
            lua_Number n=lua_tonumber(L,-1);
            sprintf(Tcl_GetStringResult(interp),"%f",n);
        } else {
            sprintf(Tcl_GetStringResult(interp),"%s",lua_tostring(L,-1));
        }
        lua_pop(L,1);
    } else {
        sprintf(Tcl_GetStringResult(interp),"%s","nil");
    }
    Tcl_Free(cmd);
    return TCL_OK;
}

static int call_proc(ClientData clientdata,
        Tcl_Interp *interp, int argc, const char *argv[])
{
    lua_State *L=(lua_State *)clientdata;
    int st=lua_gettop(L);
    lua_getglobal(L,"_tcl_procs");
    lua_getfield(L,-1,argv[0]);
    lua_remove(L,-2);
    int i;
    for(i=1;i<argc;++i) {
        lua_pushstring(L,argv[i]);
        if(lua_isnumber(L,-1)) {
            lua_Number n=lua_tonumber(L,-1);
            lua_remove(L,-1);
            lua_pushnumber(L,n);
        }
    }
    lua_call(L,argc-1,LUA_MULTRET);
    st=lua_gettop(L)-st;
    if(st) {
        lua_pop(L,st-1);
        if(lua_isnumber(L,-1)) {
            lua_Number n=lua_tonumber(L,-1);
            sprintf(Tcl_GetStringResult(interp),"%f",n);
        } else {
            sprintf(Tcl_GetStringResult(interp),"%s",lua_tostring(L,-1));
        }
        lua_pop(L,1);
    } else {
        sprintf(Tcl_GetStringResult(interp),"%s","nil");
    }
    return TCL_OK;
}

static char * trace_proc(ClientData clientdata,
        Tcl_Interp *interp, const char * name1, const char * name2, int flags)
{
    lua_State *L=(lua_State *)clientdata;
    if(flags==TCL_TRACE_READS) {
        lua_getglobal(L,name1);
        Tcl_SetVar(interp,name1,lua_tostring(L,-1),TCL_NAMESPACE_ONLY|TCL_GLOBAL_ONLY);
        lua_remove(L,-1);
    } else if(flags==TCL_TRACE_WRITES) {
        lua_pushstring(L,Tcl_GetVar(interp,name1,TCL_NAMESPACE_ONLY|TCL_GLOBAL_ONLY));
        if(lua_isnumber(L,-1)) {
            lua_Number n=lua_tonumber(L,-1);
            lua_remove(L,-1);
            lua_pushnumber(L,n);
        }
        lua_setglobal(L,name1);
    }
    return NULL;
}

static int lua_proc_proc(ClientData clientdata,
        Tcl_Interp *interp, int argc, const char *argv[])
{
    lua_State *L=(lua_State *)clientdata;
    int i;
    for(i=1;i<argc;++i) {
        lua_getglobal(L,"_tcl_procs");
        lua_pushstring(L,argv[i]);
        lua_getglobal(L,argv[i]);
        lua_rawset(L,-3);
        lua_remove(L,-1);
        Tcl_CreateCommand(interp,argv[i],call_proc,(ClientData)L,
                (Tcl_CmdDeleteProc *)NULL);
    }
    return TCL_OK;
}

static int lua_global_proc(ClientData clientdata,
        Tcl_Interp *interp, int argc, const char *argv[])
{
    lua_State *L=(lua_State *)clientdata;
    int i;
    for(i=1;i<argc;++i) {
        Tcl_SetVar(interp,argv[i],"0",TCL_NAMESPACE_ONLY|TCL_GLOBAL_ONLY);
        Tcl_TraceVar(interp,argv[i],TCL_NAMESPACE_ONLY|TCL_GLOBAL_ONLY|TCL_TRACE_READS|TCL_TRACE_WRITES,trace_proc,(ClientData)L);
    }
    return TCL_OK;
}

int luaopen_tcl(lua_State *L)
{
    interp=Tcl_CreateInterp();
    if (Tcl_Init(interp) == TCL_ERROR) {
        fprintf(stderr, "Tcl_Init failed:  %s\n", Tcl_GetStringResult(interp));
        exit(1);
    }
    if (Tk_Init(interp) == TCL_ERROR) {
        fprintf(stderr, "Tk_Init failed:  %s\n", Tcl_GetStringResult(interp));
        exit(1);
    }
    Tcl_CreateCommand(interp,"lua",lua_proc,(ClientData)L,
            (Tcl_CmdDeleteProc *)NULL);
    Tcl_CreateCommand(interp,"lua_proc",lua_proc_proc,(ClientData)L,
            (Tcl_CmdDeleteProc *)NULL);
    Tcl_CreateCommand(interp,"lua_global",lua_global_proc,(ClientData)L,

            (Tcl_CmdDeleteProc *)NULL);
    lua_register(L,"tcl",l_tcl);
    lua_register(L,"TkMainLoop",l_tkmainloop);
    lua_newtable(L);
    lua_setglobal(L,"_tcl_procs");
    return 0;
}
