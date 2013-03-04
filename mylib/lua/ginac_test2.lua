require("ginac")
require("array")
sym=ginac.symbol
s=sym("s")
t=sym("t")
p=sym("p")
f=ginac.compile(s*ginac.exp(-s^2/(4*t))/ginac.sqrt(ginac.cosh(s)-ginac.cosh(p)),{t,s,p})
a=array.double(3)

a:set(0,1)
a:set(1,2)
a:set(2,1)
print(f(a))

