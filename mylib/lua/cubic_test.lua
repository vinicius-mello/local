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



