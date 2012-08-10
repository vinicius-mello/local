dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("matrix")

points={}
points.x={}
points.y={}

lg={}

function green0(x,y) 
	return math.exp(-math.abs(x-y))
end

function green1(x,y) 
	local l=math.abs(x-y)
	return 2*(1+l)*math.exp(-l)
end

function green2(x,y) 
	local l=math.abs(x-y)
	return 8*(3+3*l+l*l)*math.exp(-l)
end

function green3(x,y) 
	local l=math.abs(x-y)
	return 8*(15+15*l+6*l*l+l*l*l)*math.exp(-l)
end

lg[1]=green0
lg[2]=green1
lg[3]=green2
lg[4]=green3

function S(g) 
  local mat={}
	for i=1,#points.x do
		mat[i]={}
		for j=1,#points.x do
			mat[i][j]=g(points.x[i],points.x[j])
			if i==j then 
				mat[i][j]=mat[i][j]+(lambda.value)^4
			end
		end
	end
	return mat
end

function interp(alpha,g,x)
	local t=0
	for i=1,#points.x do
		t=t+alpha.array:get(i-1)*g(points.x[i],x)
	end
	return t
end

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
lambda = iup.val {orientation="HORIZONTAL", value=0.5, max=1}
listg = iup.list { "K0", "K1", "K2", "K3"; dropdown="YES", value=1 }
vbox= iup.vbox { cnv,iup.hbox {lambda,listg} }
dlg = iup.dialog {vbox; title="spline1d"}

function lambda:valuechanged_cb() 
	cnv:action(0,0)
end

function listg:valuechanged_cb() 
	cnv:action(0,0)
end

-- chamada quando a janela OpenGL é redimensionada
function cnv:resize_cb(width, height)
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
	self.width=width
	self.height=height
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()         

	gl.PointSize(4.0)
	gl.Color(1,0,0)
	gl.Begin('POINTS')
	for i=1,#points.x do
		gl.Vertex(points.x[i],points.y[i])
	end
	gl.End()
	if #points.x>0 then 
		local g=lg[math.floor(listg.value)]
		local s=matrix.new(S(g))
		local y=matrix.new({points.y})
		local alpha=s:solve(y)
		gl.PointSize(1.0)
		gl.Color(1,1,0)
		gl.Begin('LINE_STRIP')
		for i=-1,1,0.01 do
			gl.Vertex(i,interp(alpha,g,i))
		end
		gl.End()
	end
  -- troca buffers
  iup.GLSwapBuffers(self)
end

-- chamada quando a janela OpenGL é criada
function cnv:map_cb()
  iup.GLMakeCurrent(self)
  gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
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

function cnv:button_cb(but,pressed,x,y,status)
  iup.GLMakeCurrent(self)
  if pressed==1 then 
		x=2*x/self.width-1	
		y=1-2*y/self.height	
		points.x[#points.x+1]=x
		points.y[#points.y+1]=y
	else 
	end
  cnv:action(0,0)
end

-- exibe a janela
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
