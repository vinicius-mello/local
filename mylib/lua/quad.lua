quad={}

require "interval"

function quad:new(Ix,Iy)
  local t={nil,nil,nil,nil;["Ix"]=Ix,["Iy"]=Iy,mark=nil}
  setmetatable(t,quad)
  return t
end

quad.__index=quad

function quad:split()
  xa,xb=self.Ix:extremes()
  ya,yb=self.Iy:extremes()
  self[1]=quad:new(interval.new(xa,(xa+xb)/2),interval.new(ya,(ya+yb)/2))
  self[2]=quad:new(interval.new((xa+xb)/2,xb),interval.new(ya,(ya+yb)/2))
  self[3]=quad:new(interval.new(xa,(xa+xb)/2),interval.new((ya+yb)/2,yb))
  self[4]=quad:new(interval.new((xa+xb)/2,xb),interval.new((ya+yb)/2,yb))
  return self
end

function quad:diam2()
  xa,xb=self.Ix:extremes()
  ya,yb=self.Iy:extremes()
  return (xa-xb)*(xa-xb)+(ya-yb)*(ya-yb)
end

function quad:draw()
  xa,xb=self.Ix:extremes()
  ya,yb=self.Iy:extremes()
  gl.Begin('LINE_LOOP')
  gl.Vertex(xa,ya)
  gl.Vertex(xb,ya)
  gl.Vertex(xb,yb)
  gl.Vertex(xa,yb)
  gl.End()
end

function quad:fill()
  xa,xb=self.Ix:extremes()
  ya,yb=self.Iy:extremes()
  gl.Begin('QUADS')
  gl.Vertex(xa,ya)
  gl.Vertex(xb,ya)
  gl.Vertex(xb,yb)
  gl.Vertex(xa,yb)
  gl.End()
end

return quad
