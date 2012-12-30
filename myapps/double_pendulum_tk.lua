dofile("modules.lua")
require("lagrangian")
require("tcl")
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

symbols {"m","g","l","theta1","dtheta1","theta2","dtheta2"}

L=m*l^2/6*(dtheta2^2+4*dtheta1^2+3*dtheta1*dtheta2*ginac.cos(theta1-theta2))+ m*g*l/2*(3*ginac.cos(theta1)+ginac.cos(theta2))
L:print()
idyn=iteration_map(L,{theta1,theta2},{dtheta1,dtheta2},0.005,{l=0.5,g=10,m=1})

q0=vec {1.57,1.57}
p0=vec {0.0,0.0}

-- chamada quando a janela OpenGL é redimensionada
function ReshapeCallback(win)
	width=tcl(win.." cget -width")+0
	height=tcl(win.." cget -height")+0
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

function DisplayCallback(win)
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
  tcl(win.." swapbuffers")
end

-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
  gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
end


function TimerCallback(win)
  idyn(q0,p0)
  tcl(win.." postredisplay")
end

tcl [[

  package require Togl 2.1
	lua_proc DisplayCallback
	lua_proc ReshapeCallback
	lua_proc CreateCallback
	lua_proc TimerCallback
  togl .hello -time 1 -width 500 -height 500 \
                     -double true -depth true \
                     -createproc CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -timercommand TimerCallback \
                     -displayproc DisplayCallback 
  pack .hello

]]

TkMainLoop()
