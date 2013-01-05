require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")

require("functions")
require("numeric")
require("util")

function f(x,y)
  return quartic(x,y)
end

local find_roots=find_roots_by_bissection(50,0.00001)
local find_min=find_min_by_sampling(50)

local vertices={}
vertices.x={-1,1,1,-1}
vertices.y={-1,-1,1,1}
local zeros={x={},y={}}
local quad={1,2,3,4}
quad.zeros={}


function main()
  sample_line(1,2)
  sample_line(2,3)
  sample_line(3,4)
  sample_line(4,1)


  local nz=#zeros.x

  for i=1,nz do
    append(quad.zeros,i)
  end

  coroutine.yield()

  bsp(quad)
end


function sample_line(ii,jj)
  local xi,yi=point(ii,vertices)
  local xj,yj=point(jj,vertices)
  local lf=function(t) return f(interp(xi,yi,xj,yj,t)) end
  local roots=find_roots(lf)
  for i=1,#roots do
    local xt,yt=interp(xi,yi,xj,yj,roots[i])
    append_point(zeros,xt,yt)
  end
end

function small_area(e)
  return function(cell)
    if #cell.zeros==2 then
      local d=diam(cell.zeros,zeros)
      if d<e then
        return true
      end
    elseif area(cell,vertices)<e then
      return true
    end
    return false
  end
end

local stop=small_area(0.01)

function bsp(cell)
  if stop(cell) then return end

  sample_cell(cell)
  coroutine.yield()
  bsp(cell.left)
  bsp(cell.right)
end


function sample_cell(c)
  local l
  if #c.zeros>=2 then
    local d,ii,jj=diam(c.zeros,zeros)
    local xi,yi=point(c.zeros[ii],zeros)
    local xj,yj=point(c.zeros[jj],zeros)
    l=perp_bisector(xi,yi,xj,yj)
  else
    local m,t,ii,jj=find_min_boundary(c)
    if t==1 then
      l=corner_bisector(c,jj)
    elseif t==0 then
      l=corner_bisector(c,ii)
    else
      local xi,yi=point(c[ii],vertices)
      local xj,yj=point(c[jj],vertices)
      local xt,yt=interp(xi,yi,xj,yj,t)
      l=perp(xi,yi,xj,yj,xt,yt)
    end
  end

  local pp,pn,ii,jj=split_convex_polygon(c,l)
  pp.zeros={}
  pn.zeros={}
  for i=1,#c.zeros do
    local x,y=point(c.zeros[i],zeros)
    local s=line_eval(l,x,y)
    if s>0 then
      append(pp.zeros,c.zeros[i])
    elseif s<0 then
      append(pn.zeros,c.zeros[i])
    else
      append(pp.zeros,c.zeros[i])
      append(pn.zeros,c.zeros[i])
    end
  end

  local nz=#zeros.x
  sample_line(ii,jj)
  for pi=nz+1,#zeros.x do
    append(pp.zeros,pi)
    append(pn.zeros,pi)
  end

  c.left=pp
  c.right=pn
end


function split_convex_polygon(p,l)
  local n=#p
  local pp={}
  local pn={}
  local x,y=point(p[1],vertices)
  local s=line_eval(l,x,y)
  local int={}
  for i=1,n do
    local ni=(i % n)+1
    if s > 0 then
      append(pp,p[i])
    elseif s<0 then
      append(pn,p[i])
    else
      append(pp,p[i])
      append(pn,p[i])
      append(int,p[i])
    end
    local xn,yn=point(p[ni],vertices)
    local ns=line_eval(l,xn,yn)
    if ns*s<0 then
      local t=line_parameter(x,y,xn,yn,l)
      local xt,yt=interp(x,y,xn,yn,t)
      local pi=append_point(vertices,xt,yt)
      append(pp,pi)
      append(pn,pi)
      append(int,pi)
    end
    s=ns
    x=xn
    y=yn
  end
  return pp,pn,int[1],int[2]
end


function corner_bisector(p,i)
  local n=#p
  local ni=(i % n)+1
  local pi
  if i==1 then pi=n else pi=i-1 end
  local xp,yp=point(p[pi],vertices)
  local x,y=point(p[i],vertices)
  local xn,yn=point(p[ni],vertices)
  return bisector(xp,yp,x,y,xn,yn)
end


function find_min_boundary(c)
  local n=#c
  local x,y=point(c[1],vertices)
  local m=math.huge
  local t,ii,jj
  for i=1,n do
    local ni=(i % n)+1
    local xn,yn=point(c[ni],vertices)
    local lf=function(t) return f(interp(x,y,xn,yn,t)) end
    local mi,ti=find_min(lf)
    if mi<m then
      ii,jj=i,ni
      m=mi
      t=ti
    end
    x,y=xn,yn
  end
  return m,t,ii,jj
end


function draw_poly(p)
  gl.Color(1,0,0,1)
  gl.Begin('LINE_STRIP')
  for i=1,#p do
    gl.Vertex(point(p[i],vertices))
  end
  gl.End()
  gl.PointSize(4.0)
  gl.Color(1,1,0)
  gl.Begin('POINTS')
  for i=1,#p.zeros do
    gl.Vertex(point(p.zeros[i],zeros))
  end
  gl.End()
end


function draw_bsp(cell)
  if not cell.left then
    draw_poly(cell)
  else
    draw_bsp(cell.left)
    draw_bsp(cell.right)
  end
end


one_step=coroutine.create(main)

cnv = iup.glcanvas{buffer="DOUBLE", rastersize = "480x480"}

function cnv:resize_cb(width, height)
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height)

  gl.MatrixMode('PROJECTION')
  gl.LoadIdentity()
  gl.Ortho(-1,1,-1,1,-1,1)

  gl.MatrixMode('MODELVIEW')
  gl.LoadIdentity()
end

function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  draw_bsp(quad)
  iup.GLSwapBuffers(self)
end


function cnv:k_any(c)
  if c == iup.K_SP then
    coroutine.resume(one_step)
    cnv:action(0,0)
  end
end

dlg = iup.dialog{cnv; title="bsp"}

dlg:show()

iup.MainLoop()
