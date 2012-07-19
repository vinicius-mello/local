EXT=.dll
SHARED=-shared

FORTRAN_LIB= -lgfortran
BLAS_LIB= "/c/local/Numeric/lib/libgoto2_dll.lib" $(FORTRAN_LIB)
LAPACK_LIB= "/c/local/Numeric/lib/lapack.a" $(BLAS_LIB)
ARPACK_LIB= /c/local/Numeric/lib/libarpack.a $(LAPACK_LIB) 
BLZPACK_LIB= /c/local/Numeric/lib/libblzpack.a $(LAPACK_LIB) 

LUA_LIB= "/c/Program Files/Lua/5.1/lib/lua5.1.lib"
LUA_INC= -I"/c/Program Files/Lua/5.1/include"

TCL_LIB= "/c/Tcl/lib/tcl85.lib"
TCL_INC= -I"/c/Tcl/include"

TAUCS_LIB=/c/local/Numeric/lib/libtaucs.a\
          /c/local/Numeric/lib/libmetis.a\
          $(LAPACK_LIB)
TAUCS_INC= -I /c/local/Numeric/include  

UMFPACK_LIB=/c/local/Numeric/lib/libumfpack.a\
       /c/local/Numeric/lib/libcholmod.a\
       /c/local/Numeric/lib/libccolamd.a\
       /c/local/Numeric/lib/libcolamd.a\
       /c/local/Numeric/lib/libcamd.a\
       /c/local/Numeric/lib/libamd.a\
       /c/local/Numeric/lib/libmetis.a\
			 $(BLAS_LIB)
UMFPACK_INC= -I /c/local/Numeric/include  

SUPERLU_LIB= /c/local/Numeric/lib/libsuperlu.a\
       $(BLAS_LIB)
SUPERLU_INC= -I /c/local/Numeric/include  

MA57_LIB= /c/local/Numeric/lib/libma57.a /c/local/Numeric/lib/libfakemetis.a \
       $(BLAS_LIB)

MA47_LIB= /c/local/Numeric/lib/libma47.a $(BLAS_LIB)

GL2_LIB = -lglu32 /mingw/lib/glut32.lib -lopengl32 -lglew32.dll
GL2_INC = -I .

MAPM_LIB = /c/local/Numeric/lib/libmapm.a 
MAPM_INC= -I /c/local/Numeric/include  

BIAS_LIB = /c/local/Numeric/lib/libBias.a 
BIAS_INC= -I /c/local/Numeric/include  

GSL_LIB = "/c/local/Numeric/lib/libgsl.a" "/c/local/Numeric/lib/libgoto2.lib"
GSL_INC= -I /c/local/Numeric/include  

LPT_LIB = "/c/local/lpt-code/lpt/lpt.o"
LPT_INC = -I "/c/local/lpt-code/"
