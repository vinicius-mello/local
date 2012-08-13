dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("matrix")

points={}
points.x={-0.75,-0.25,0.25,0.75,-0.75,-0.25,0.25,0.75}
points.y={0.5,0.5,0.5,0.5,-0.5,-0.5,-0.5,-0.5}

lg={}

function bezier3(t,i0,i1,i2,i3)
	local px,py=0,0
	local tt=1-t
	px=points.x[i0]*tt^3+3*points.x[i1]*tt^2*t+3*points.x[i2]*tt*t^2+points.x[i3]*t^3
	py=points.y[i0]*tt^3+3*points.y[i1]*tt^2*t+3*points.y[i2]*tt*t^2+points.y[i3]*t^3
	return px,py
end

function bezier3t(t,i0,i1,i2,i3)
	local tx,ty=0,0
	local tt=1-t
	tx=3*((points.x[i1]-points.x[i0])*tt^2+(points.x[i2]-points.x[i1])*2*tt*t+(points.x[i3]-points.x[i2])*t^2)
	ty=3*((points.y[i1]-points.y[i0])*tt^2+(points.y[i2]-points.y[i1])*2*tt*t+(points.y[i3]-points.y[i2])*t^2)
	return tx,ty
end

function dist(x,y,u,v)
	return math.sqrt((x-u)*(x-u)+(y-v)*(y-v))
end

function gauss(x,y,u,v) 
	local l=dist(x,y,u,v)
	return math.exp(-l^2)
end

function green0(x,y,u,v) 
	local l=dist(x,y,u,v)
	return math.exp(-l)
end

function green1(x,y,u,v) 
	local l=dist(x,y,u,v)
	return 2*(1+l)*math.exp(-l)
end

function green2(x,y,u,v) 
	local l=dist(x,y,u,v)
	return 8*(3+3*l+l*l)*math.exp(-l)
end

function green3(x,y,u,v) 
	local l=dist(x,y,u,v)
	return 8*(15+15*l+6*l*l+l*l*l)*math.exp(-l)
end

lg[1]=green0
lg[2]=green1
lg[3]=green2
lg[4]=green3
lg[5]=gauss

function click(pts,x,y,err)
  for i=1,#pts.x do
		if math.abs(x-pts.x[i])<err and 
		  math.abs(y-pts.y[i])<err then
			return i 
		end		
	end
	return 0
end

function S(g,x0,y0,x1,y1) 
  local mat={}
	mat[1]={}
	mat[2]={}
	mat[1][1]=g(x0,y0,x0,y0)+(sigma.value)^4
	mat[1][2]=g(x0,y0,x1,y1)
	mat[2][2]=g(x1,y1,x1,y1)+(sigma.value)^4
	mat[2][1]=mat[1][2]
	return mat
end

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
sigma = iup.val {orientation="HORIZONTAL", value=0.0, max=1}
listg = iup.list { "K0", "K1", "K2", "K3", "Gaussian" ; dropdown="YES", value=2 }
vbox= iup.vbox { cnv,iup.hbox {sigma,listg} }
dlg = iup.dialog {vbox; title="spline vector"}

function sigma:valuechanged_cb() 
	cnv:action(0,0)
end

function listg:valuechanged_cb() 
	cnv:action(0,0)
end

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

function cnv:convert(x,y)
	x=2*x/self.width-1	
	y=1-2*y/self.height	
	return x,y
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:action(x, y)
	--print("action")
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()         

	gl.PointSize(6.0)
	gl.Color(1,0,0)
	gl.Begin('POINTS')
	for i=1,4 do
		gl.Vertex(points.x[i],points.y[i])
	end
	gl.End()
	gl.Color(0,0,1)
	gl.Begin('POINTS')
	for i=5,8 do
		gl.Vertex(points.x[i],points.y[i])
	end
	gl.End()
	gl.LineWidth(1.0)
	gl.Color(1,0,0)
	gl.Begin('LINE_STRIP')
	for t=0,1,0.01 do
		local px,py=bezier3(t,1,2,3,4)
		gl.Vertex(px,py)
	end
	gl.End()
	gl.Color(0,0,1)
	gl.Begin('LINE_STRIP')
	for t=0,1,0.01 do
		local px,py=bezier3(t,5,6,7,8)
		gl.Vertex(px,py)
	end
	gl.End()
	gl.Color(1,1,0)
	gl.Begin('LINES')
	for t=0,1,0.1 do
		local p0x,p0y=bezier3(t,1,2,3,4)
		local p1x,p1y=bezier3(t,5,6,7,8)
		local t0x,t0y=bezier3t(t,1,2,3,4)
		local t1x,t1y=bezier3t(t,5,6,7,8)
		local g=lg[math.floor(listg.value)]
		local s=matrix.new(S(g,p0x,p0y,p1x,p1y))
		local dx=matrix.new({{t0x,t1x}})
		local dy=matrix.new({{t0y,t1y}})
		local alpha={}
		alpha.x=s:solve(dx)
		alpha.y=s:solve(dy)
		local a0x=alpha.x.array:get(0)
		local a1x=alpha.x.array:get(1)
		local a0y=alpha.y.array:get(0)
		local a1y=alpha.y.array:get(1)
		gl.Vertex(p0x,p0y)
		gl.Vertex(p0x+0.1*a0x,p0y+0.1*a0y)
		gl.Vertex(p1x,p1y)
		gl.Vertex(p1x+0.1*a1x,p1y+0.1*a1y)
	end
	gl.End()

  -- troca buffers
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
	seli=0
	selt=0
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
  if c == iup.K_ESC then
  -- sai da aplicação
    iup.ExitLoop()
  end
end

function cnv:button_cb(but,pressed,x,y,status)
  iup.GLMakeCurrent(self)
  if pressed==1 then 
		x,y=cnv:convert(x,y)
		seli=click(points,x,y,5*self.pixel_width) 
	else 
		seli=0
	end
  cnv:action(0,0)
end

function cnv:motion_cb(x,y,status)
	if seli>0 then
		x,y=cnv:convert(x,y)
			points.x[seli]=x
			points.y[seli]=y
  	cnv:action(0,0)
  end
end

-- exibe a janela
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
