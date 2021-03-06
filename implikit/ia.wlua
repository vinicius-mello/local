require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")

require "quad"
require "adia"

require("functions")

function f(x,y)
  return quartic(x,y)
end

local x=ad.var(2,1)
local y=ad.var(2,2)
local eq=f(x,y)


function small_diam(diam)
  return function (q)
	local I=eq[0](q.Ix,q.Iy)
	local int=I:contains(0)
    if not int then
	  q.mark='black'
	elseif q:diam2()<diam then
	  q.mark='yellow'
	end
	return q.mark ~= nil
  end
end

function dot_grad(diam)
  return function (q)
	local I=eq[0](q.Ix,q.Iy)
	local int=I:contains(0)
	local dx=eq[1](q.Ix,q.Iy)
	local dy=eq[2](q.Ix,q.Iy)
	local dg=dx*dx+dy*dy
    if not int then
	  q.mark='black'
	elseif q:diam2()<diam then
	  q.mark='yellow'
	elseif not dg:contains(0) then
	  q.mark='orange'
	end
	return q.mark ~= nil
  end
end


local stop=small_diam(0.001)
local quadroot=quad:new(interval.new(-1,1),interval.new(-1,1))

function main()
  subdivide(quadroot)
end

function subdivide(q)
  if stop(q) then return end
  q:split()
  coroutine.yield()
  for i=1,4 do
	subdivide(q[i])
  end
end

one_step=coroutine.create(main)

cnv = iup.glcanvas{buffer="DOUBLE", rastersize = "480x480"}

function draw_quad(node)
  if not node[1] then
    if node.mark=='black' then
	  gl.Color(0,0,0)
	  node:fill()
	  gl.Color(1,1,1)
	  node:draw()
	elseif node.mark=='yellow' then
	  gl.Color(1,1,0)
	  node:fill()
	elseif node.mark=='orange' then
	  gl.Color(1,0.5,0)
	  node:fill()
	else
	  gl.Color(0.5,0.5,0.5)
	  node:fill()
	  gl.Color(1,1,1)
	  node:draw()
	end
  else
    for i=1,4 do draw_quad(node[i]) end
  end
end


function cnv:resize_cb(width, height)
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height)

  gl.MatrixMode('PROJECTION')   -- Select The Projection Matrix
  gl.LoadIdentity()             -- Reset The Projection Matrix

  gl.MatrixMode('MODELVIEW')    -- Select The Model View Matrix
  gl.LoadIdentity()             -- Reset The Model View Matrix
end

function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT') -- Clear Screen And Depth Buffer
  draw_quad(quadroot)
  iup.GLSwapBuffers(self)
end


function cnv:k_any(c)
  if c == iup.K_SP then
    coroutine.resume(one_step)
	cnv:action(0,0)
  end
end

dlg = iup.dialog{cnv; title="ia"}

dlg:show()

iup.MainLoop()
