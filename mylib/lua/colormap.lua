colormap={}
function colormap.rgbmap(a,m)
    local size=a:height()
    local step=1/(size-1)
    local i
    local j=1
    for i=0,size-1 do
        local s=i*step
        while not ((s >= m.t[j]) and (s <= m.t[j+1])) do
            j=j+1
        end
        local dem=(m.t[j+1]-m.t[j])
        local r=((s-m.t[j])*m.r[j+1]+(m.t[j+1]-s)*m.r[j])/dem
        local g=((s-m.t[j])*m.g[j+1]+(m.t[j+1]-s)*m.g[j])/dem
        local b=((s-m.t[j])*m.b[j+1]+(m.t[j+1]-s)*m.b[j])/dem
        a:set(i,0,r)
        a:set(i,1,g)
        a:set(i,2,b)
        --print(r,g,b)
    end
end

function colormap.rgbamap(a,m)
    local size=a:height()
    local step=1/(size-1)
    local i
    local j=1
    for i=0,size-1 do
        local s=i*step
        while not ((s >= m.t[j]) and (s <= m.t[j+1])) do
            j=j+1
        end
        local dem=(m.t[j+1]-m.t[j])
        local r=((s-m.t[j])*m.r[j+1]+(m.t[j+1]-s)*m.r[j])/dem
        local g=((s-m.t[j])*m.g[j+1]+(m.t[j+1]-s)*m.g[j])/dem
        local b=((s-m.t[j])*m.b[j+1]+(m.t[j+1]-s)*m.b[j])/dem
        local alpha=((s-m.t[j])*m.a[j+1]+(m.t[j+1]-s)*m.a[j])/dem
        a:set(i,0,r)
        a:set(i,1,g)
        a:set(i,2,b)
        a:set(i,3,alpha)
        --print(r,g,b)
    end
end
return colormap
