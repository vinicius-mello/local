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

y=vec {5,7,1,4,3,6,4,1,2,4,9,11,14,9,8,11,9}
y2=array.double(y:size())
work=array.double(y:size())
cubic.natural_spline(y,y2,work)

gnuplot=io.popen("gnuplot -p","w")
gnuplot:write("plot '-', '-' with lines \n")
for t=0,1,0.01 do
    gnuplot:write(t.." "..cubic.eval(x,t).."\n")
end
gnuplot:write("e\n")
for t=0,1,0.01 do
    gnuplot:write(t.." "..cubic.natural_spline_eval(y,y2,t).."\n")
end
gnuplot:write("e\n")
gnuplot:flush()

c=array.float(17,17,17)
for i=0,c:width()-1 do
    for j=0,c:height()-1 do
        for k=0,c:depth()-1 do
            c:set(k,i,j,i+j+k)
        end
    end
end
cubic.convert(c)
r=array.float(3)
cubic.evald(c,0.125,0.35,0.3,r)
print(r:get(0),r:get(1),r:get(2))

