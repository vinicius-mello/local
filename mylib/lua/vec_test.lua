require("vec")

a=vec.new {1, 1, 3}
b=vec.new {0, 2, 1}

print("a=",a)
print("b=",b)
print("a+b=",a+b)
print("a-b=",a-b)
print("2*a=",2*a)
print("a*2=",a*2)
print("dot(a,b)=",vec.dot(a,b))
print("a%b=",a%b)
print("cross(a,b)=",vec.cross(a,b))
print("a^b=",a^b)
print("norm2(a)=",vec.norm2(a))
print("norm(a)=",vec.norm(a))
