require("vec")

function bisect(f,tol)
  local t1=0
  local t2=1
  local t
  local f1=f(0)
  local f2=f(1)
  while t2-t1>tol do
    t=(t1+t2)/2
    local fm=f(t)
    if f1*fm<0 then
      t2=t
    else
      t1=t
    end
  end
  t=(t1+t2)/2
  return t
end

function newton(eq,x,y,z,tau) 
  local eps=math.huge
  local xn
  local yn
  local zn
  local i=0
  while eps>tau or i<20 do
    local f=eq[0](x,y,z)
    local fx=eq[1](x,y,z)
    local fy=eq[2](x,y,z)
    local fz=eq[3](x,y,z)
    local df2=fx*fx+fy*fy+fz*fz
    xn=x-fx/df2*f
    yn=y-fy/df2*f
    zn=z-fz/df2*f
    eps=math.sqrt((xn-x)^2+(yn-y)^2+(zn-z)^2)
    i=i+1
    x,y,z=xn,yn,zn
  end
  return xn,yn,zn
end

function det(a,b,c,d,e,f,g,h,i)
  return (a*e*i+b*f*g+c*d*h-c*e*g-b*d*i-a*f*h)
end

function vol(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
  return 1/6*(det(x2,x3,x4,y2,y3,y4,z2,z3,z4)-
    det(x1,x3,x4,y1,y3,y4,z1,z3,z4)+
    det(x1,x2,x4,y1,y2,y4,z1,z2,z4)-
    det(x1,x2,x3,y1,y2,y3,z1,z2,z3))
end

function inside(x,y,z,xs,ys,zs)
  local v=vol(xs[1],ys[1],zs[1],xs[2],ys[2],zs[2],xs[3],ys[3],zs[3],xs[4],ys[4],zs[4])
  local s=vol(x,y,z,xs[2],ys[2],zs[2],xs[3],ys[3],zs[3],xs[4],ys[4],zs[4])/v
  local t=vol(xs[1],ys[1],zs[1],x,y,z,xs[3],ys[3],zs[3],xs[4],ys[4],zs[4])/v
  local u=vol(xs[1],ys[1],zs[1],xs[2],ys[2],zs[2],x,y,z,xs[4],ys[4],zs[4])/v
  return (s>=0) and (t>=0) and (u>=0) and ((1-s-t-u)>=0) 
end

function cot(u,v)
  local d=vec.dot(u,v)
  return d/math.sqrt(vec.dot(u,u)*vec.dot(v,v)-d*d)
end

function tetra_quality(xs,ys,zs)
  --           4 --- 3
  --          /  \  /
  --       1 ----- 2
  local edges={{1,2},{1,3},{1,4},{2,3},{2,4},{3,4}}
  local opp={{3,4},{4,2},{2,3},{1,4},{3,1},{1,2}}
  local max=-math.huge
  for i=1,#edges do
    local u12=vec.new {
      xs[edges[i][2]]-xs[edges[i][1]],
      ys[edges[i][2]]-ys[edges[i][1]],
      zs[edges[i][2]]-zs[edges[i][1]] }
    local u13=vec.new {
      xs[opp[i][1]]-xs[edges[i][1]],
      ys[opp[i][1]]-ys[edges[i][1]],
      zs[opp[i][1]]-zs[edges[i][1]] }
    local u14=vec.new {
      xs[opp[i][2]]-xs[edges[i][1]],
      ys[opp[i][2]]-ys[edges[i][1]],
      zs[opp[i][2]]-zs[edges[i][1]] }
    u12=vec.normalize(u12)
    u13=vec.normalize(u13)
    u14=vec.normalize(u14)
    max=math.max(max,math.abs(cot(vec.cross(u12,u13),vec.cross(u14,u12))))
  end
  local faces=
    {{1,2,3},{2,3,1},{3,1,2},{1,2,4},{2,4,1},{4,1,2},
     {1,3,4},{3,4,1},{4,1,3},{2,3,4},{3,4,2},{4,2,3}}
  for i=1,#faces do
    local u=vec.new {
      xs[faces[i][2]]-xs[faces[i][1]],
      ys[faces[i][2]]-ys[faces[i][1]],
      zs[faces[i][2]]-zs[faces[i][1]] }
    local v=vec.new {
      xs[faces[i][3]]-xs[faces[i][1]],
      ys[faces[i][3]]-ys[faces[i][1]],
      zs[faces[i][3]]-zs[faces[i][1]] }
    max=math.max(max,math.abs(cot(u,v)))
  end
  return max
end


