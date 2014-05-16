require("interval")

x=interval.new(1,3)
y=interval.new(2,4)
print(x:meet(y))
print(x:join(y))
print(x:midrad())
print(x:diam())
