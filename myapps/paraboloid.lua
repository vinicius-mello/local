dofile("modules.lua")
require("lagrangian")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")

function vec(t) 
  local m=#t
  local a=array.array_double(m)
  for i=1,m do
    a:set(i-1,t[i])
  end
  return a	  
end

function symbols(a) 
  for i=1,#a do
    _G[a[i]]=ginac.symbol(a[i])
  end
end

symbols {"R","m","g","rho","drho","theta","dtheta"}

L=m/(2*R^2)*(R^2*drho^2+R^2*rho^2*dtheta^2+4*rho^2*drho^2-2*R*g*rho^2)

idyn=iteration_map(L,{rho,theta},{drho,dtheta},0.005,{R=1,g=10,m=1})

q0=vec {1,0}
p0=vec {0,0.5}

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
dlg = iup.dialog {cnv; title="lagrangian"}

-- chamada quando a janela OpenGL é redimensionada
function cnv:resize_cb(width, height)
	--print("resize")
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  self.width=width
  self.height=height
  self.pixel_width=2/width
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

points={}
points.x={}
points.y={}

function cnv:action(x, y)
	--print("action")
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()         
  gl.PointSize(1.0)
  gl.Color(1,0,0)
  gl.Begin('POINTS')
  local n
  if #points.x<=100 then n=1 else n=#points.x-99 end
  for i=n,#points.x do
    gl.Vertex(points.x[i],points.y[i])
  end
  gl.End()
  iup.GLSwapBuffers(self)
end

-- chamada quando a janela OpenGL é criada
function cnv:map_cb()
	--print("map")
  iup.GLMakeCurrent(self)
  gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
  if c == iup.K_ESC then
  -- sai da aplicação
    iup.ExitLoop()
  end
end

timer = iup.timer{time=1}

function timer:action_cb()
  local rho=q0:get(0)
  local theta=q0:get(1)
  local x,y=rho*math.cos(theta),rho*math.sin(theta)
  points.x[#points.x+1]=x
  points.y[#points.y+1]=y
  idyn(q0,p0)
  cnv:action(0,0)
  return iup.DEFAULT
end

-- exibe a janela
timer.run = "YES"
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
