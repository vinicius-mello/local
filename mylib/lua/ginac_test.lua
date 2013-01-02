require("ginac")
require("array")
sym=ginac.symbol
x=sym("x")
y=sym("y")
f=ginac.compile({x^3+3*y*x+y,x^2+y^3*x^2},{x,y})
a=array.double(2)
b=array.double(2)
a:set(0,1)
a:set(1,1)
f(a,b)
print(b:get(0),b:get(1))

