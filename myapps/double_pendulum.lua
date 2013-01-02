dofile("modules.lua")
require("lagrangian")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")

function vec(t) 
  local m=#t
  local a=array.double(m)
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

symbols {"m","g","l","theta1","dtheta1","theta2","dtheta2"}

L=m*l^2/6*(dtheta2^2+4*dtheta1^2+3*dtheta1*dtheta2*ginac.cos(theta1-theta2))+ m*g*l/2*(3*ginac.cos(theta1)+ginac.cos(theta2))
L:print()
idyn=iteration_map(L,{theta1,theta2},{dtheta1,dtheta2},0.005,{l=0.5,g=10,m=1})

q0=vec {1.57,1.57}
p0=vec {0.0,0.0}

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

function cnv:action(x, y)
	--print("action")
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()         
  local theta1=q0:get(0)
  local theta2=q0:get(1)
  gl.PointSize(4.0)
  gl.Color(1,0,0)
  gl.Begin('LINES')
	local x1,y1=0.5*math.sin(theta1),-0.5*math.cos(theta1)
	local x2,y2=x1+0.5*math.sin(theta2),y1-0.5*math.cos(theta2)
	gl.Vertex(0,0)
	gl.Vertex(x1,y1)
	gl.Vertex(x1,y1)
	gl.Vertex(x2,y2)
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
  idyn(q0,p0)
  cnv:action(0,0)
  return iup.DEFAULT
end

-- exibe a janela
timer.run = "YES"
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
