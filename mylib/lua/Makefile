include ../make.inc

TARGETS=array$(EXT) cloud$(EXT) blas$(EXT) lapack$(EXT) \
  cubic$(EXT) sparse$(EXT) triplets$(EXT) umfpack$(EXT) \
	gl2$(EXT) cl$(EXT) tcl$(EXT) lpt$(EXT) gsl$(EXT) \
	lbfgsb$(EXT) pack$(EXT) ginac$(EXT) \
  arpack$(EXT) 
# ma57$(EXT)
# luail$(EXT) luailu$(EXT) luailut$(EXT) \
#	ma47$(EXT) lpt$(EXT)


all: $(TARGETS)

array$(EXT): array_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB)

array_wrap.cxx: array.i $(MYLIB)/swig/array.i $(MYLIB)/wrappers/array.hpp
	swig -o $@ -c++ -lua $<

cloud$(EXT): cloud_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB)

cloud_wrap.cxx: $(MYLIB)/swig/cloud.i $(MYLIB)/wrappers/cloud.hpp
	swig -o $@ -c++ -lua $<

cubic$(EXT): cubic_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB)

cubic_wrap.cxx: $(MYLIB)/swig/cubic.i $(MYLIB)/wrappers/cubic.hpp
	swig -o $@ -c++ -lua $<

blas$(EXT): blas_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(BLAS_LIB) -I $(MYLIB)

blas_wrap.cxx: $(MYLIB)/swig/blas.i $(MYLIB)/wrappers/blas.hpp
	swig -o $@ -c++ -lua $<

lapack$(EXT): lapack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(LAPACK_LIB) -I $(MYLIB)

lapack_wrap.cxx: $(MYLIB)/swig/lapack.i $(MYLIB)/wrappers/lapack.hpp
	swig -o $@ -c++ -lua $<

sparse$(EXT): sparse_wrap.cxx
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB) 

sparse_wrap.cxx: $(MYLIB)/swig/sparse.i $(MYLIB)/wrappers/sparse.hpp
	swig -o $@ -c++ -lua $<

triplets$(EXT): triplets_wrap.cxx
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB) 

triplets_wrap.cxx: $(MYLIB)/swig/triplets.i $(MYLIB)/wrappers/triplets.hpp
	swig -o $@ -c++ -lua $<

umfpack$(EXT): umfpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(UMFPACK_INC) $(LUA_LIB) $(UMFPACK_LIB) -I $(MYLIB)

umfpack_wrap.cxx: $(MYLIB)/swig/umfpack.i $(MYLIB)/wrappers/umfpack.hpp
	swig -o $@ -c++ -lua $<

superlu$(EXT): superlu_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(SUPERLU_INC) $(LUA_LIB) $(SUPERLU_LIB)  -I $(MYLIB)

superlu_wrap.cxx: $(MYLIB)/swig/superlu.i $(MYLIB)/wrappers/superlu.hpp
	swig -o $@ -c++ -lua $<

taucs$(EXT): taucs_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(TAUCS_INC) $(LUA_LIB) $(TAUCS_LIB)  -I $(MYLIB)

taucs_wrap.cxx: $(MYLIB)/swig/taucs.i $(MYLIB)/wrappers/taucs.hpp
	swig -o $@ -c++ -lua $<

arpack$(EXT): arpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(ARPACK_LIB)  -I $(MYLIB)

arpack_wrap.cxx: $(MYLIB)/swig/arpack.i $(MYLIB)/wrappers/arpack.hpp
	swig -o $@ -c++ -lua $<

blzpack$(EXT): blzpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(BLZPACK_LIB)  -I $(MYLIB)

blzpack_wrap.cxx: $(MYLIB)/swig/blzpack.i $(MYLIB)/wrappers/blzpack.hpp
	swig -o $@ -c++ -lua $<

ma57$(EXT): ma57_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(MA57_LIB)  -I $(MYLIB)

ma57_wrap.cxx: $(MYLIB)/swig/ma57.i $(MYLIB)/wrappers/ma57.hpp
	swig -o $@ -c++ -lua $<

ma47$(EXT): ma47_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) $(MA47_LIB)  -I $(MYLIB)

ma47_wrap.cxx: $(MYLIB)/swig/ma47.i $(MYLIB)/wrappers/ma47.hpp
	swig -o $@ -c++ -lua $<

gl2$(EXT): gl2_wrap.cxx $(MYLIB)/wrappers/gl2.hpp  $(MYLIB)/wrappers/fbo.h 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(GL2_INC) $(LUA_LIB) $(GL2_LIB)  -I $(MYLIB)

gl2_wrap.cxx: $(MYLIB)/swig/gl2.i $(MYLIB)/wrappers/gl2.hpp  $(MYLIB)/wrappers/fbo.h 
	swig -o $@ -c++ -lua $<

glut$(EXT): glut_wrap.cxx $(MYLIB)/mytl/glut.hpp
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(GLUT_INC) $(LUA_LIB) $(GLUT_LIB)  -I $(MYLIB)

glut_wrap.cxx: $(MYLIB)/lua/glut.i $(MYLIB)/swig/glut.i $(MYLIB)/mytl/glut.hpp luaglut.cpp
	swig -o $@ -c++ -lua $<

tw$(EXT): tw_wrap.cxx $(MYLIB)/wrappers/tw.cpp
	g++ -o $@ $(SHARED) $< $(MYLIB)/wrappers/tw.cpp $(LUA_INC) $(TW_INC) $(LUA_LIB) $(TW_LIB)  -I $(MYLIB)

tw_wrap.cxx: $(MYLIB)/swig/tw.i $(MYLIB)/wrappers/tw.hpp
	swig -o $@ -c++ -lua $<


cl$(EXT): cl_wrap.cxx $(MYLIB)/wrappers/cl.cpp
	g++ -o $@ $(SHARED) $< $(MYLIB)/wrappers/cl.cpp $(LUA_INC) $(CL_INC) $(LUA_LIB) $(CL_LIB)  -I $(MYLIB)

cl_wrap.cxx: $(MYLIB)/swig/cl.i $(MYLIB)/wrappers/cl.hpp 
	swig -o $@ -c++ -lua $<


gsl$(EXT): gsl_wrap.cxx
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(GSL_INC) $(LUA_LIB) $(GSL_LIB)  -I $(MYLIB)

#gsl_wrap.cxx: $(MYLIB)/swig/gsl.i $(MYLIB)/wrappers/gsl.hpp
gsl_wrap.cxx: gsl.i $(MYLIB)/swig/gsl.i luagsl.cpp $(MYLIB)/wrappers/gsl.hpp
	swig -o $@ -c++ -lua $<

lbfgsb$(EXT): lbfgsb_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LBFGSB_INC) $(LUA_LIB) $(LBFGSB_LIB)  -I $(MYLIB)

lbfgsb_wrap.cxx: $(MYLIB)/swig/lbfgsb.i $(MYLIB)/wrappers/lbfgsb.hpp
	swig -o $@ -c++ -lua $<


luail$(EXT): il_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(IL_INC) $(LUA_LIB) $(IL_LIB)  -I $(MYLIB)

il_wrap.cxx: $(MYLIB)/swig/il.i 
	swig -o $@ -c++ -lua $<

luailu$(EXT): ilu_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(IL_INC) $(LUA_LIB) $(IL_LIB)  -I $(MYLIB)

ilu_wrap.cxx: $(MYLIB)/swig/ilu.i 
	swig -o $@ -c++ -lua $<

luailut$(EXT): ilut_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(IL_INC) $(LUA_LIB) $(IL_LIB)  -I $(MYLIB)

ilut_wrap.cxx: $(MYLIB)/swig/ilut.i 
	swig -o $@ -c++ -lua $<


lpt$(EXT): lpt_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(LPT_INC) $(LUA_LIB) $(LPT_LIB)  -I $(MYLIB)

lpt_wrap.cxx: $(MYLIB)/swig/lpt.i 
	swig -o $@ -c++ -lua $<

pack$(EXT): lpack.c 
	gcc -o $@ $(SHARED) $< $(LUA_INC) $(LUA_LIB) -I $(MYLIB)

ginac$(EXT): lginac.cpp 
	g++ -o $@ $(SHARED) $< $(LUA_INC) $(GINAC_INC) $(LUA_LIB) $(GINAC_LIB) -I $(MYLIB)

tcl$(EXT): tcl.c 
	gcc -o $@ $(SHARED) $< $(LUA_INC) $(TCL_INC) $(LUA_LIB) $(TCL_LIB) -I $(MYLIB)

clean:
	rm -rf *_wrap.cxx 

cleanall:
	rm -rf $(TARGETS) *_wrap.cxx
