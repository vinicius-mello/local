include ../../mylib/make.inc
CPPFLAGS= -I$(MYLIB) $(GSL_INC) $(TCL_INC)


app.dll: app.o app_wrap.o
	 g++ -shared -o app.dll app_wrap.cpp app.o $(CPPFLAGS) $(TCL_LIB) $(GSL_LIB) $(GL2_LIB)

app_wrap.cpp: app.i
	swig -tcl -c++ -o app_wrap.cpp app.i

clean:
	rm -rf app_wrap.cpp app.so *.o app.dll
