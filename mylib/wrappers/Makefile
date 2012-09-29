include ../make.inc

TARGETS= cl.o

all: $(TARGETS)

cl.o: cl.hpp cl.cpp
	g++ -c -fPIC $(CL_INC) cl.cpp
