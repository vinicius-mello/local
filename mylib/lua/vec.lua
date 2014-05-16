vec={}
local mt={}

function mt.__add(a,b)
    local r={}
    for i=1,#a do
        r[i]=a[i]+b[i]
    end
    return vec.new(r)
end

function mt.__sub(a,b)
    local r={}
    for i=1,#a do
        r[i]=a[i]-b[i]
    end
    return vec.new(r)
end

function mt.__mul(a,b)
    if type(a)=="table" then
        a,b = b,a
    end
    local r={}
    for i=1,#b do
        r[i]=a*b[i]
    end
    return vec.new(r)
end

function mt.__unm(a)
    local r={}
    for i=1,#a do
        r[i]=-a[i]
    end
    return vec.new(r)
end

function mt.__mod(a,b)
    return vec.dot(a,b)
end

function mt.__pow(a,b)
   return vec.cross(a,b)
end

function mt.__tostring(a)
    return a[1].." "..a[2].." "..a[3]
end

function vec.new(t)
    setmetatable(t,mt)
    return t
end

function vec.dot(a,b)
    local r=0
    for i=1,#a do
        r=r+a[i]*b[i]
    end
    return r
end

function vec.cross(a,b)
    local r={}
    r[1]=a[2]*b[3]-a[3]*b[2]
    r[2]=a[3]*b[1]-a[1]*b[3]
    r[3]=a[1]*b[2]-a[2]*b[1]
    return vec.new(r)
end

function vec.norm2(a)
    local r=0
    for i=1,#a do
        r=r+a[i]*a[i]
    end
    return r
end

function vec.norm(a)
    return math.sqrt(vec.norm2(a))
end

function vec.normalize(a)
    local l=vec.norm(a)
    return (1.0/l)*a
end

return vec
