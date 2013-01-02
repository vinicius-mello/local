require("array")

a=array.double("array3d.in") 
b=array.double(4,3,2)
a:rearrange("210",b)
b:save("array3d.out")
