dofile("modules.lua")
require("array")
require("gsl")

function f(t,r) 
    return
    function(s)
        return math.sqrt(2)*math.exp(-t/4)/(4*math.pi*t)^(3/2)*
        s*math.exp(-s^2/(4*t))/math.sqrt(math.cosh(s)-math.cosh(r))
    end
end

a=array.double(10000)
i=0
for rho=0,100,0.01 do
    local result=gsl.integrate {f=f(1,rho),a=rho,algorithm="qagiu"}
    if(i>=10000 or result<1e-10) then break end
    a[i]=result
    print(rho,result)
    i=i+1
end
print(i)
