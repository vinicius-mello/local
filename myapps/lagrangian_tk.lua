dofile("modules.lua")
require("array")
require("gsl")
require("ginac")
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

symbols {"R","m","g","rho","drho","theta","dtheta"}

L=m/(2*R^2)*(R^2*drho^2+R^2*rho^2*dtheta^2+4*rho^2*drho^2-2*R*g*rho^2)
L=L:subs {R=1,m=1,g=10}
symbols {"h","rho0","rho1","theta0","theta1"}
Ld=L:subs {
  rho=(rho0+rho1)/2,
  drho=(rho1-rho0)/h,
  theta=(theta0+theta1)/2,
  dtheta=(theta1-theta0)/h
}
Ld=h*Ld  
Ld=Ld:subs {h=0.005}
Ld:print()
symbols {"prho0","prho1","ptheta0","ptheta1"}
eq1=prho0+Ld:diff(rho0)
eq2=ptheta0+Ld:diff(theta0)
eq3=Ld:diff(rho1)
eq4=Ld:diff(theta1)
f=ginac.compile({eq1,eq2},{rho0,theta0,rho1,theta1,prho0,ptheta0})
Jf=ginac.compile({eq1:diff(rho1),eq1:diff(theta1),eq2:diff(rho1),eq2:diff(theta1)},{rho0,theta0,rho1,theta1,prho0,ptheta0})
g=ginac.compile({eq3,eq4},{rho0,theta0,rho1,theta1})

temp= vec {0,0,0,0,0,0}

function M(v,w)
  temp:copy(v,2)
  f(temp,w)
end

function JM(v,j)
  temp:copy(v,2)
  Jf(temp,j)
end


q0=vec {1,0}
p0=vec {0,.5}
q1=vec {1,0}

function idyn()
  temp:copy(q0)
  temp:copy(p0,4)
  gsl.solve {
    f=M,
    df=JM,
    algorithm="hybridsj",
    starting_point=q1 ,
    show_iterations=false
  }
  temp:copy(q1,2)
  g(temp,p0)
  q0:copy(q1)
--  print(q0:get(0),q0:get(1))
end

-- chamada quando a janela OpenGL é redimensionada
function ReshapeCallback(win)
	width=tcl(win.." cget -width")+0
	height=tcl(win.." cget -height")+0
--	print("Reshape",width,height)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

points={}
points.x={}
points.y={}

function DisplayCallback(win)
--	print("Display")
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
  tcl(win.." swapbuffers")
end

-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
--	print("Create")
  gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
end

-- chamada quando uma tecla é pressionada

function TimerCallback(win)
--	print("Timer")
  local rho=q0:get(0)
  local theta=q0:get(1)
  local x,y=rho*math.cos(theta),rho*math.sin(theta)
  points.x[#points.x+1]=x
  points.y[#points.y+1]=y
  idyn()
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
