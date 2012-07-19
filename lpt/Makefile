lpt.o : lpt.hpp lpt.cpp lpt_table2 lpt_table3 lpt_table4
	g++ -c lpt.cpp  

examples: example2 example3 example4

example2: example.cpp lpt.o
	g++ -D DIM=2 -o example2 example.cpp lpt.o 

example3: example.cpp lpt.o
	g++ -D DIM=3 -o example3 example.cpp lpt.o 

example4: example.cpp lpt.o
	g++ -D DIM=4 -o example4 example.cpp lpt.o 

sigperm: sigperm.cpp
	g++ -o sigperm sigperm.cpp 

lpt_table2: sigperm
	./sigperm 2 > lpt_table2

lpt_table3: sigperm
	./sigperm 3 > lpt_table3

lpt_table4: sigperm
	./sigperm 4 > lpt_table4

docs:
	doxygen

clean:
	rm -rf lpt.o sigperm.exe sigperm lpt_table? example? example?.exe doc
