require("array")
require("cloud")

a=array.array_float("array.in")
b=array.array_float(2)
cloud.barycenter(a,0,5,b)
print(b:get(0),b:get(1))
