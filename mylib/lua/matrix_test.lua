require("matrix")

a=matrix.new {{1, 1}, {2, 3}}
b=matrix.new {{0, 2}, {5, 1}}

print("identity(3)",matrix.identity(3))
print("a=",a)
print("b=",b)
print("a^t=",a:transpose())
print("a*b=",a*b)
print("b*a=",b*a)
print("a+b=",a+b)
print("a-b=",a-b)
print("b-a=",b-a)
print("a+1=",a+1)
print("1+a=",1+a)
print("a-1=",a-1)
print("1-a=",1-a)
print("2*a=",2*a)
print("a*2=",a*2)
print("a:det()=",a:det())
print("b:det()=",b:det())
local c=matrix.new {{1},{3}} 
print("c=",c)
print("a:solve(c)=",a:solve(c))
print("b:solve(c)=",b:solve(c))
print("a:inverse()=",a:inverse())
print("b:inverse()=",b:inverse())

