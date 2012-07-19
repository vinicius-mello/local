function append(l,x)
  l[#l+1]=x
end

function point(i,ps)
  return ps.x[i],ps.y[i]
end

function append_point(ps,x,y)
  append(ps.x,x)
  append(ps.y,y)
  return #ps.x
end

function interp(x0,y0,x1,y1,t)
  return x0+t*(x1-x0),y0+t*(y1-y0)
end

function perp_bisector(x0,y0,x1,y1)
  local A=(x1-x0)
  local B=(y1-y0)
  return {a=A,b=B,c=-(x0+x1)*A/2-(y0+y1)*B/2}
end

function perp(x0,y0,x1,y1,xp,yp)
  local A=(x1-x0)
  local B=(y1-y0)
  return {a=A,b=B,c=-xp*A-yp*B}
end

function line_parameter(x0,y0,x1,y1,l)
  local A=(x1-x0)
  local B=(y1-y0)
  return -(l.a*x0+l.b*y0+l.c)/(l.a*A+l.b*B)
end

function line_eval(l,x,y)
  return l.a*x+l.b*y+l.c
end

function bisector(xp,yp,x,y,xn,yn)
  local l=math.sqrt((xp-x)*(xp-x)+(yp-y)*(yp-y))
  xp=x+(xp-x)/l
  yp=y+(yp-y)/l
  l=math.sqrt((xn-x)*(xn-x)+(yn-y)*(yn-y))
  xn=x+(xn-x)/l
  yn=y+(yn-y)/l
  local A=(xp+xn)/2-x
  local B=(yp+yn)/2-y
  return {a=-B,b=A,c=x*B-y*A}
end

function diam(p,ps)
  local d=-math.huge
  local ii,jj
  for i=1,#p do
    for j=i+1,#p do
	  local xi,yi=point(p[i],ps)
	  local xj,yj=point(p[j],ps)
	  local dist2=(xi-xj)*(xi-xj)+(yi-yj)*(yi-yj)
	  if dist2>d then
	    d=dist2
		ii=i
		jj=j
	  end
	end
  end
  return d,ii,jj
end

function area(p,ps)
  local n=#p
  local xi,yi=point(p[1],ps)
  local a=0
  for i=1,n do
    if i==n then j=1 else j=i+1 end
	local xj,yj=point(p[j],ps)
	a=a+(xi*yj-xj*yi)
	xi,yi=xj,yj
  end
  return a/2
end
