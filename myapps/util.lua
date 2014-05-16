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

function newton(eq,x,y,tau) 
  local eps=math.huge
  local xn
  local yn
  local i=0
  while eps>tau or i<20 do
    local f=eq[0](x,y)
    local fx=eq[1](x,y)
    local fy=eq[2](x,y)
    local df2=fx*fx+fy*fy
    xn=x-fx/df2*f
    yn=y-fy/df2*f
    eps=math.sqrt((xn-x)^2+(yn-y)^2)
    i=i+1
    x,y=xn,yn
  end
  return xn,yn
end

function inside(x,y,xs,ys)
  local area=1/2*(-ys[2]*xs[3]+ys[1]*(-xs[2]+xs[3])+xs[1]*(ys[2]-ys[3])+xs[2]*ys[3])
  local s=1/(2*area)*(ys[1]*xs[3]-xs[1]*ys[3]+(ys[3]-ys[1])*x+(xs[1]-xs[3])*y)
  local t=1/(2*area)*(xs[1]*ys[2]-ys[1]*xs[2]+(ys[1]-ys[2])*x+(xs[2]-xs[1])*y)
  return (s>=0) and (t>=0) and ((1-s-t)>=0) 
end

function cot(ux,uy,vx,vy)
  local dot=ux*vx+uy*vy
  return dot/math.sqrt((ux*ux+uy*uy)*(vx*vx+vy*vy)-dot*dot)
end

function triangle_quality(xs,ys,mct)
  --           0
  --       1       2
  local a=cot(xs[2]-xs[1],ys[2]-ys[1],xs[3]-xs[1],ys[3]-ys[1]) 
  local b=cot(xs[3]-xs[2],ys[3]-ys[2],xs[1]-xs[2],ys[1]-ys[2]) 
  local c=cot(xs[1]-xs[3],ys[1]-ys[3],xs[2]-xs[3],ys[2]-ys[3]) 
  return math.max(math.abs(a),math.abs(b),math.abs(c))/mct  
end


