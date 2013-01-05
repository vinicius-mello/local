require("array")

a=array.double("array3d.in") 
print("a",a:depth(),a:height(),a:width())
b=array.double(4,3,2)
print("b",b:depth(),b:height(),b:width())
c=array.float(2,3,4)
print("c",c:depth(),c:height(),c:width())
a:rearrange("210",b)
print("b",b:depth(),b:height(),b:width())
c:from_double(b)
print("c",c:depth(),c:height(),c:width())
b:save("array3d.out")

