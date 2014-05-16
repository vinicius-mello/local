require("adia")

local x=ad.var(2,1)
local y=ad.var(2,2)

local eq=-1+x^2+y^2

q={}
q.x=interval.new(0.1,0.2)
q.y=interval.new(0.3,0.4)
print(eq[0](q.x,q.y))
