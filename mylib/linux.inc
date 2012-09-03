EXT=.so
SHARED= -shared -fPIC 
FORTRAN_LIB= -lgfortran
BLAS_LIB= /opt/intel/mkl/lib/intel64/libmkl_rt.so $(FORTRAN_LIB)
#BLAS_LIB= /opt/acml5.0.0/gfortran64/lib/libacml.a $(FORTRAN_LIB)
#BLAS_LIB= /usr/lib/libacml.a $(FORTRAN_LIB)
#BLAS_LIB= /usr/lib/libgoto2.a -lpthread $(FORTRAN_LIB)
#BLAS_LIB= -z muldefs /usr/lib/libblas.a $(FORTRAN_LIB)
LAPACK_LIB= $(BLAS_LIB)
#LAPACK_LIB= /usr/lib/liblapack.a $(BLAS_LIB)
ARPACK_LIB= ~/local/Numeric/ARPACK/libarpack.a $(LAPACK_LIB) 

#LUA_LIB= -llua-5.1
LUA_LIB= -llua5.1
LUA_INC= -I/usr/include/lua5.1

TCL_LIB= -ltcl
TCL_INC= -I/usr/include/tcl

UMFPACK_LIB=~/local/Numeric/SuiteSparse/UMFPACK/Lib/libumfpack.a\
       ~/local/Numeric/SuiteSparse/CHOLMOD/Lib/libcholmod.a\
       ~/local/Numeric/SuiteSparse/CCOLAMD/Lib/libccolamd.a\
       ~/local/Numeric/SuiteSparse/COLAMD/Lib/libcolamd.a\
       ~/local/Numeric/SuiteSparse/CAMD/Lib/libcamd.a\
       ~/local/Numeric/SuiteSparse/AMD/Lib/libamd.a\
       ~/local/Numeric/metis-4.0.3/libmetis.a\
			 $(BLAS_LIB)

UMFPACK_INC= -I ~/local/Numeric/SuiteSparse/UMFPACK/Include \
 -I ~/local/Numeric/SuiteSparse/SuiteSparse_config/ \
 -I ~/local/Numeric/SuiteSparse/AMD/Include/ 

MA57_LIB= ~/local/Numeric/ma57-3.7.0/src/libma57.a \
  ~/local/Numeric/metis-4.0.3/libmetis.a $(BLAS_LIB)

#MA47_LIB= -L/home/vinicius/Numeric/lib -lma47 $(BLAS_LIB)

GL2_LIB = -lGLU -lGLEW -lGL
GL2_INC = -I .

LPT_LIB = ~/local/lpt/lpt.o
LPT_INC = -I ~/local/

GSL_LIB = -lgsl $(BLAS_LIB)
GSL_INC= 

