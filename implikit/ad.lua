ad={}

local mt={}

function ad.zero(...)
    return 0
end

function ad.one(...)
    return 1
end

function ad.project(i)
    if i==1 then return function(a) return a end end
    if i==2 then return function(a,b) return b end end
    if i==3 then return function(a,b,c) return c end end
    return function(...) return select(i,...) end
end

function ad.var(n,i)
    local t={}
    for j=1,n do t[j]=ad.zero end
    t[i]=ad.one
    t[0]=ad.project(i)
    setmetatable(t,mt)
    return t
end

function ad.cte(n,k)
    local t={}
    for j=1,n do t[j]=ad.zero end
    t[0]=function(...) return k end
    setmetatable(t,mt)
    return t
end

function ad.add(a,b)
    local t={}
    if getmetatable(a)~=mt then a=ad.cte(#b,a) end
    if getmetatable(b)~=mt then b=ad.cte(#a,b) end
    for j=0,#a do t[j]=function(...) return a[j](...)+b[j](...) end end
    setmetatable(t,mt)
    return t
end

function ad.sub(a,b)
    local t={}
    if getmetatable(a)~=mt then a=ad.cte(#b,a) end
    if getmetatable(b)~=mt then b=ad.cte(#a,b) end
    for j=0,#a do t[j]=function(...) return a[j](...)-b[j](...) end end
    setmetatable(t,mt)
    return t
end

function ad.unm(a)
    local t={}
    for j=0,#a do t[j]=function(...) return -a[j](...) end end
    setmetatable(t,mt)
    return t
end

function ad.mul(a,b)
    local t={}
    if getmetatable(a)~=mt then a=ad.cte(#b,a) end
    if getmetatable(b)~=mt then b=ad.cte(#a,b) end
    for j=1,#a do t[j]=function(...) return a[j](...)*b[0](...)+a[0](...)*b[j](...) end end
    t[0]=function(...) return a[0](...)*b[0](...) end
    setmetatable(t,mt)
    return t
end

function ad.div(a,b)
    local t={}
    if getmetatable(a)~=mt then a=ad.cte(#b,a) end
    if getmetatable(b)~=mt then b=ad.cte(#a,b) end
    for j=1,#a do t[j]=function(...) return (a[j](...)*b[0](...)-a[0](...)*b[j](...))/(b[0](...)*b[0](...)) end end
    t[0]=function(...) return a[0](...)/b[0](...) end
    setmetatable(t,mt)
    return t
end

function ad.pow(a,n)
    local t={}
    if getmetatable(a)~=mt then
        error("exponent must be a number",1)
    end
    for j=1,#a do t[j]=function(...) return n*a[0](...)^(n-1)*a[j](...) end end
    t[0]=function(...) return a[0](...)^n end
    setmetatable(t,mt)
    return t
end

function ad.func(f,df)
    return function(a)
        local t={}
        for j=1,#a do t[j]=function(...) return df(a[0](...))*a[j](...) end end
        t[0]=function(...) return f(a[0](...)) end
        setmetatable(t,mt)
        return t
    end
end

ad.sin=ad.func(math.sin,math.cos)
ad.cos=ad.func(math.cos,function(a) return -math.sin(a) end)
ad.tan=ad.func(math.tan,function(a) return 1/(math.cos(a)*math.cos(a)) end)
ad.exp=ad.func(math.exp,math.exp)
ad.log=ad.func(math.log,function(a) return 1/a end)
ad.abs=ad.func(math.abs,function(a) if a<0 then return -1 else return 1 end end)
ad.sqrt=ad.func(math.sqrt,function(a) return 1/(2*math.sqrt(a)) end)
ad.asin=ad.func(math.asin,function(a) return 1/math.sqrt(1-a*a) end)
ad.acos=ad.func(math.acos,function(a) return -1/math.sqrt(1-a*a) end)
ad.atan=ad.func(math.atan,function(a) return 1/(1+a*a) end)
ad.asinh=ad.func(function(a) return math.log(a+math.sqrt(1+a*a)) end,function(a) return 1/math.sqrt(1+a*a) end)
ad.acosh=ad.func(function(a) return math.log(a+math.sqrt(a-1)*math.sqrt(a+1)) end,function(a) return 1/(math.sqrt(a-1)*math.sqrt(a+1)) end)
ad.atanh=ad.func(function(a) return 0.5*(math.log(1+a)-math.log(1-a)) end,function(a) return 1/(1-a*a) end)

mt.__add=ad.add
mt.__sub=ad.sub
mt.__unm=ad.unm
mt.__mul=ad.mul
mt.__div=ad.div
mt.__pow=ad.pow

return ad
