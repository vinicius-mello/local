include ../make.inc

TARGETS=array$(EXT) blas$(EXT) sparse$(EXT) triplets$(EXT) umfpack$(EXT) \
  arpack$(EXT) ma57$(EXT)\
	ma47$(EXT) gl2$(EXT) lpt$(EXT)


all: $(TARGETS)

array$(EXT): array_wrap.cxx 
	g++ -o $@ $(SHARED) -DDEBUG=1 $< $(TCL_INC) $(TCL_LIB) -I $(MYLIB)

array_wrap.cxx: array.i $(MYLIB)/wrappers/array.hpp
	swig -o $@ -pkgversion 1.0 -c++ -tcl $<

blas$(EXT): blas_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) $(BLAS_LIB) -I $(MYLIB)

blas_wrap.cxx: $(MYLIB)/swig/blas.i $(MYLIB)/wrappers/blas.hpp
	swig -o $@ -pkgversion 1.0 -c++ -tcl $<

sparse$(EXT): sparse_wrap.cxx
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) -I $(MYLIB) 

sparse_wrap.cxx: $(MYLIB)/swig/sparse.i $(MYLIB)/wrappers/sparse.hpp
	swig -o $@ -c++ -tcl $<

triplets$(EXT): triplets_wrap.cxx
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) -I $(MYLIB) 

triplets_wrap.cxx: $(MYLIB)/swig/triplets.i $(MYLIB)/wrappers/triplets.hpp
	swig -o $@ -c++ -tcl $<

umfpack$(EXT): umfpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(UMFPACK_INC) $(TCL_LIB) $(UMFPACK_LIB) -I $(MYLIB)

umfpack_wrap.cxx: $(MYLIB)/swig/umfpack.i $(MYLIB)/wrappers/umfpack.hpp
	swig -o $@ -c++ -tcl $<

superlu$(EXT): superlu_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(SUPERLU_INC) $(TCL_LIB) $(SUPERLU_LIB)  -I $(MYLIB)

superlu_wrap.cxx: $(MYLIB)/swig/superlu.i $(MYLIB)/wrappers/superlu.hpp
	swig -o $@ -c++ -tcl $<

taucs$(EXT): taucs_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TAUCS_INC) $(TCL_LIB) $(TAUCS_LIB)  -I $(MYLIB)

taucs_wrap.cxx: $(MYLIB)/swig/taucs.i $(MYLIB)/wrappers/taucs.hpp
	swig -o $@ -c++ -tcl $<

arpack$(EXT): arpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) $(ARPACK_LIB)  -I $(MYLIB)

arpack_wrap.cxx: $(MYLIB)/swig/arpack.i $(MYLIB)/wrappers/arpack.hpp
	swig -o $@ -c++ -tcl $<

blzpack$(EXT): blzpack_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) $(BLZPACK_LIB)  -I $(MYLIB)

blzpack_wrap.cxx: $(MYLIB)/swig/blzpack.i $(MYLIB)/wrappers/blzpack.hpp
	swig -o $@ -c++ -tcl $<

ma57$(EXT): ma57_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) $(MA57_LIB)  -I $(MYLIB)

ma57_wrap.cxx: $(MYLIB)/swig/ma57.i $(MYLIB)/wrappers/ma57.hpp
	swig -o $@ -c++ -tcl $<

ma47$(EXT): ma47_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(TCL_LIB) $(MA47_LIB)  -I $(MYLIB)

ma47_wrap.cxx: $(MYLIB)/swig/ma47.i $(MYLIB)/wrappers/ma47.hpp
	swig -o $@ -c++ -tcl $<

gl2$(EXT): gl2_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(GL2_INC) $(TCL_LIB) $(GL2_LIB)  -I $(MYLIB)

gl2_wrap.cxx: $(MYLIB)/swig/gl2.i $(MYLIB)/wrappers/gl2.hpp 
	swig -o $@ -c++ -tcl $<

gsl$(EXT): gsl_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(GSL_INC) $(TCL_LIB) $(GSL_LIB)  -I $(MYLIB)

gsl_wrap.cxx: $(MYLIB)/swig/gsl.i $(MYLIB)/wrappers/gsl.hpp
	swig -o $@ -c++ -tcl $<

lpt$(EXT): lpt_wrap.cxx 
	g++ -o $@ $(SHARED) $< $(TCL_INC) $(LPT_INC) $(TCL_LIB) $(LPT_LIB)  -I $(MYLIB)

lpt_wrap.cxx: $(MYLIB)/swig/lpt.i 
	swig -o $@ -c++ -tcl $<

clean:
	rm -rf $(TARGETS) 

cleanall:
	rm -rf $(TARGETS) *_wrap.cxx
