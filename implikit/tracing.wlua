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
local n=64
local lines={}

function main()
  for y=-1,1,2/n do
    local lf=function(t) return f(interp(-1,y,1,y,t)) end
	local roots=find_roots(lf)
	lines[y]=roots
    coroutine.yield()
  end
end


function draw_lines()
  for y,roots in pairs(lines) do
    gl.Color(1,0,0,1)
    gl.Begin('LINE_STRIP')
    gl.Vertex(-1,y)
    gl.Vertex(1,y)
    gl.End()
    gl.PointSize(4.0)
    gl.Color(1,1,0)
    gl.Begin('POINTS')
    for i=1,#roots do
      gl.Vertex(2*roots[i]-1,y)
    end
    gl.End()
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
  draw_lines()
  iup.GLSwapBuffers(self)
end


function cnv:k_any(c)
  if c == iup.K_SP then
    coroutine.resume(one_step)
	cnv:action(0,0)
  end
end

dlg = iup.dialog{cnv; title="tracing"}

dlg:show()

iup.MainLoop()
