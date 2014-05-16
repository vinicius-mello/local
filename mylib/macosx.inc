EXT=.so
SHARED= -shared -fPIC 
FORTRAN_LIB= -L/usr/local/gfortran/lib -lgfortran
BLAS_LIB= -framework vecLib
#BLAS_LIB= /opt/intel/mkl/lib/intel64/libmkl_rt.so $(FORTRAN_LIB)
#BLAS_LIB= /opt/acml5.0.0/gfortran64/lib/libacml.a $(FORTRAN_LIB)
#BLAS_LIB= /usr/lib/libacml.a $(FORTRAN_LIB)
#BLAS_LIB= /usr/lib/libgoto2.a -lpthread $(FORTRAN_LIB)
#BLAS_LIB= -z muldefs /usr/lib/libblas.a $(FORTRAN_LIB)
LAPACK_LIB= $(BLAS_LIB)
#LAPACK_LIB= /usr/lib/liblapack.a $(BLAS_LIB)
ARPACK_LIB= ~/local/Numeric/ARPACK/libarpack.a $(LAPACK_LIB) 

#LUA_LIB= -llua-5.1
#LUA_LIB= -llua5.1
LUA_LIB= -undefined dynamic_lookup
LUA_INC= -I/usr/local/include/lua5.1

TCL_LIB= -framework Tcl -framework Tk
TCL_INC= -I /Library/Frameworks/Tcl.framework/Versions/8.6/Headers/ -I /Library/Frameworks/Tk.framework/Versions/8.6/Headers/ 

UMFPACK_LIB=~/local/Numeric/SuiteSparse/UMFPACK/Lib/libumfpack.a\
       ~/local/Numeric/SuiteSparse/CHOLMOD/Lib/libcholmod.a\
       ~/local/Numeric/SuiteSparse/CCOLAMD/Lib/libccolamd.a\
       ~/local/Numeric/SuiteSparse/COLAMD/Lib/libcolamd.a\
       ~/local/Numeric/SuiteSparse/CAMD/Lib/libcamd.a\
       ~/local/Numeric/SuiteSparse/AMD/Lib/libamd.a\
       -lsuitesparseconfig\
       ~/local/Numeric/metis-4.0.3/libmetis.a\
			 $(BLAS_LIB)

UMFPACK_INC= -I ~/local/Numeric/SuiteSparse/UMFPACK/Include \
 -I ~/local/Numeric/SuiteSparse/SuiteSparse_config/ \
 -I ~/local/Numeric/SuiteSparse/AMD/Include/ 

MA57_LIB= ~/local/Numeric/ma57-3.7.0/src/libma57.a \
  ~/local/Numeric/metis-4.0.3/libmetis.a $(BLAS_LIB)

#MA47_LIB= -L/home/vinicius/Numeric/lib -lma47 $(BLAS_LIB)

GL2_LIB = -lGLEW -framework GLUT -framework AGL -framework OpenGL
GL2_INC = 

GLUT_LIB = -framework GLUT -framework AGL -framework OpenGL
GLUT_INC = 

TW_LIB = -lAntTweakBar $(GLUT_LIB)
TW_INC = $(GLUT_INC)

CL_LIB = -framework OpenCL $(GL2_LIB)
CL_INC = 

LPT_LIB = ~/local/lpt/lpt.o
LPT_INC = -I ~/local/

BOOST_INC = -I /usr/local/include/

IL_LIB = -lIL -lILU -lILUT
IL_INC = 

GSL_LIB = -lgsl $(BLAS_LIB)
GSL_INC= 

LBFGSB_LIB = ~/local/Numeric/Lbfgsb.3.0/timer.o ~/local/Numeric/Lbfgsb.3.0/linpack.o ~/local/Numeric/Lbfgsb.3.0/lbfgsb.o $(BLAS_LIB) $(FORTRAN_LIB)
LBFGSB_INC= 

GINAC_LIB = -lginac -lcln
GINAC_INC= 
