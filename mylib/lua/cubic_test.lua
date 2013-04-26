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

