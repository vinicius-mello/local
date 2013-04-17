require("array")
require("cubic")

function vec(t)
  local m=#t
    local a=array.double(m)
  for i=1,m do
      a:set(i-1,t[i])
    end
    return a
end

local x=vec {5,7,1,4,3,6,4,1,2,4,9,11,14,9,8,11,9}

cubic.convert(x)
print(cubic.eval(x,0.0))
print(cubic.eval(x,0.5))
print(cubic.eval(x,1.0))

print(cubic.evald(x,0.0))
print(cubic.evald(x,0.5))
print(cubic.evald(x,1.0))

print((cubic.eval(x,0.500001)-cubic.eval(x,0.5))/0.000001)

local g=array.double(50000)
for i=1,50000 do
    local t=(i-1)/50000
    g:set(i-1,math.exp(-t^2))
end
cubic.convert(g)
maxerr=0
for i=1,50000 do
    local t=(i-1)/50000
    local dg=cubic.evald(g,t)
    local err=math.abs(dg-math.exp(-t^2)*(-2*t))
    if err>maxerr then maxerr=err end
    print(t,err)
end
print(maxerr)



