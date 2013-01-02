dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("ply")
require("colormap")
require("gl2")
require("array")
require("blas")
require("vec")

print("Lendo header do arquivo ply")
filename=arg[1]
mesh=ply.load(filename)
file_mht=filename:match("(.*)%.ply").."_mht.ply"
mht=ply.load(file_mht)
mesh:print_header()
mht:print_header()

deg=array.uint(mesh.vertex.size)
are=array.float(mesh.vertex.size)
vtx=array.float(mesh.vertex.size,3)
nml=array.float(mesh.vertex.size,3)
idx=array.uint(mesh.face.size,3)

bb={ 
  xa=math.huge,
	xb=-math.huge,
	ya=math.huge,
	yb=-math.huge,
	za=math.huge,
	zb=-math.huge
}  --bounding box

clr=array.float(128,3)

colormap.rgbmap(clr, 
  {
	  t={0.000, 0.125, 0.375, 0.625, 0.875, 1.000},
		r={0.000, 0.000, 0.000, 1.000, 1.000, 0.500},
		g={0.000, 0.000, 1.000, 1.000, 0.000, 0.000},
		b={0.500, 1.000, 1.000, 0.000, 0.000, 0.000} } )

local attrs=array.float(mesh.vertex.size)
local values=array.float(mht.eigenvector.size)
local mh=array.float(mht.eigenvector.size,mesh.vertex.size)

function mht.eigenvector_read_cb(i,reg) 
  values:set(i,reg.eigenvalue)
	for j=1,#reg.coords do
	  mh:set(i,j-1,reg.coords[j])
	end
end


function mesh.vertex_read_cb(i,reg) 
  vtx:set(i,0,reg.x)
  vtx:set(i,1,reg.y)
  vtx:set(i,2,reg.z)
  nml:set(i,0,0)
  nml:set(i,1,0)
  nml:set(i,2,0)
  deg:set(i,0)
  are:set(i,0)
	bb.xa=math.min(bb.xa, reg.x)
	bb.xb=math.max(bb.xb, reg.x)
	bb.ya=math.min(bb.ya, reg.y)
	bb.yb=math.max(bb.yb, reg.y)
	bb.za=math.min(bb.za, reg.z)
	bb.zb=math.max(bb.zb, reg.z)
end

function mesh.face_read_cb(i,reg) 
  local v={}
	local ii={}
	for j=1,3 do -- recupera os vertices e acumula o grau de cada vertice 
    local k=idx:set(i,j-1,reg.vertex_indices[j])
		ii[j]=k
		deg:set(k,deg:get(k)+1)
		v[j]=vec.new { vtx:get(k,0), vtx:get(k,1), vtx:get(k,2) }
	end
  local a=v[2]-v[1]
  local b=v[3]-v[1]
	local n=a^b
	local area=0.5*math.sqrt(n%n)
	n=0.5/area*n
	for j=1,3 do 
    local k=reg.vertex_indices[j]
	  local ns=vec.new { nml:get(k,0), nml:get(k,1), nml:get(k,2) }
		ns=ns+n
	  nml:set(k,0,ns[1])
	  nml:set(k,1,ns[2])
	  nml:set(k,2,ns[3])
	  are:set(k,are:get(k)+area/3)
	end
end

print("Processando arquivo ply")
mesh:read_data()
mht:read_data()
print("Bounding Box: ["..bb.xa..","..bb.xb.."]x["..bb.ya..","..bb.yb.."]x["..bb.za..","..bb.zb.."]")

fil=array.float(mht.eigenvector.size)
fil:zero()
fil_exp=array.float(mht.eigenvector.size)
coef=array.float(mht.eigenvector.size,3)
coef_t=array.float(mht.eigenvector.size,3)
vtx_high=array.float(mesh.vertex.size,3)
vtx:times_to(are,vtx_high)
blas.gemm(1.0,mh,vtx_high,0.0,coef)
blas.gemm(1.0,mh,coef,0.0,vtx_high,true)
blas.scal(-1.0,vtx_high)
vtx_high:sum(vtx)

blas.copy(vtx_high,vtx)
blas.copy(coef,coef_t)
blas.gemm(1.0,mh,coef_t,1.0,vtx,true)

for i=0,mesh.vertex.size-1 do
  local ns=vec.new { nml:get(i,0), nml:get(i,1), nml:get(i,2) }
	ns=1/deg:get(i)*ns 
	nml:set(i,0,ns[1])
	nml:set(i,1,ns[2])
	nml:set(i,2,ns[3])
end
deg=nil

print("Coleta de lixo")
collectgarbage("collect")

attr_idx=1

bb.xm=(bb.xa+bb.xb)/2
bb.ym=(bb.ya+bb.yb)/2
bb.zm=(bb.za+bb.zb)/2

-- monta interface
cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
filter_cnv = iup.glcanvas { buffer="DOUBLE", rastersize = mht.eigenvector.size.."x200" }
dlg = iup.dialog { iup.vbox {cnv,filter_cnv} ; title="model"}
--filter_dlg = iup.dialog {filter_cnv; title="filter"}

-- chamada quando a janela OpenGL é redimensionada
function cnv:resize_cb(width, height)
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
	glu.Perspective(60,width/height,0.01,1000)

  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
	self.radius=math.max((bb.zb-bb.za)/2,(bb.yb-bb.ya)/2,(bb.xb-bb.xa)/2)
	glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
  self.model_track:resize(self.radius)
  self.light_track:resize(self.radius)
end

function filter_cnv:resize_cb(width, height)
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
	glu.Ortho2D(0,mht.eigenvector.size-1,-1,1)
end


function draw_ball(radius) 
  gl.Disable('LIGHTING')
  gl.Begin('LINE_LOOP')
  for theta=0,2*math.pi,math.pi/30 do 
    gl.Vertex(radius*math.cos(theta),0.0,radius*math.sin(theta))
  end
  gl.End()
  gl.Begin('LINE_LOOP')
  for theta=0,2*math.pi,math.pi/30 do 
    gl.Vertex(0.0,radius*math.cos(theta),radius*math.sin(theta))
  end
  gl.End()
  gl.Begin('LINE_LOOP')
  for theta=0,2*math.pi,math.pi/30 do 
    gl.Vertex(radius*math.cos(theta),radius*math.sin(theta),0.0)
	end
  gl.End()
  gl.Enable('LIGHTING')
end

function draw_rays()
  gl.Disable('LIGHTING')
  gl.Begin('LINES')
  for x=-cnv.radius,cnv.radius,cnv.radius/4 do
    for y=-cnv.radius,cnv.radius,cnv.radius/4 do
      gl.Vertex(x,y,0)
      gl.Vertex(x,y,1000)
    end
	end
  gl.End()
  gl.Enable('LIGHTING')
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.EnableClientState('VERTEX_ARRAY')
  gl.EnableClientState('NORMAL_ARRAY')
  gl2.enable_vertex_attrib_array(1)
	gl2.vertex_attrib_array(1, attrs)
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()         
	glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
 
  if self.dragging then
    gl.PushMatrix()
    self.model_track:rotate()
    gl.Color(1,1,1)
    draw_ball(self.radius)
    gl.PopMatrix()
	end
  if self.light_dragging then
    gl.PushMatrix()
    self.light_track:rotate()
    gl.Color(1,1,0)
    draw_rays()
    gl.PopMatrix()
  end
	
  gl.PushMatrix()
  self.light_track:transform()
  gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
  gl.PopMatrix()
  
	self.model_track:transform()
	gl.Translate(-bb.xm,-bb.ym,-bb.zm)
  self.prog:bind()
	self.prog:uniformi("colormap",0)
	gl2.draw_triangles(idx)
  self.prog:unbind()
  gl2.disable_vertex_attrib_array(1)
  gl.DisableClientState('NORMAL_ARRAY')
  gl.DisableClientState('VERTEX_ARRAY')
  -- troca buffers
  iup.GLSwapBuffers(self)
end

function filter_cnv:action(x, y)
  iup.GLMakeCurrent(self)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
	local l=mht.eigenvector.size
	gl.Color(0.7,0.7,0.7)
	gl.Begin('LINES')
	for i=-1,1,0.25 do
	  gl.Vertex(0,i)
	  gl.Vertex(l,i)
	end
	for i=0,l,25 do
	  gl.Vertex(i,-1)
	  gl.Vertex(i,1)
	end
	gl.End()
	gl.Color(0,0,0)
	gl.Begin('LINE_STRIP')
	for i=1,l do
	  gl.Vertex(i-1,fil:get(i-1))
	end
	gl.End()
  iup.GLSwapBuffers(self)
end

-- chamada quando a janela OpenGL é criada
function cnv:map_cb()
  iup.GLMakeCurrent(self)
  print("Iniciando GLEW")
  gl2.init()
  print("Habilitando arrays")
  gl.EnableClientState('VERTEX_ARRAY')
	gl2.vertex_array(vtx)
  gl.DisableClientState('VERTEX_ARRAY')
  gl.EnableClientState('NORMAL_ARRAY')
	gl2.normal_array(nml)
  gl.DisableClientState('NORMAL_ARRAY')

  print("Configurando OpenGL")
  gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.DepthFunc('LEQUAL')                          -- tipo do teste
  gl.Light ('LIGHT0', 'AMBIENT', {0,0,0,1})
  gl.Light ('LIGHT0', 'DIFFUSE', {1,1,1,1})
  gl.Light ('LIGHT0', 'SPECULAR', {1,1,1,1})

  gl.ShadeModel('SMOOTH')
  gl.Enable ('LIGHTING')
  gl.Enable ('LIGHT0')
  gl.LightModel('LIGHT_MODEL_TWO_SIDE',{1,1,1,1})
  gl.Enable ('CULL_FACE')
  gl.Enable ('DEPTH_TEST')
  gl.Enable ('NORMALIZE')

  print("Associando textura")
  gl2.active_texture(0)
  self.texture=gl.GenTextures(1)
	gl.BindTexture('TEXTURE_1D',self.texture[1])
	gl2.tex_1D(clr)

  print("Iniciando a trackball")
  self.model_track=gl2.trackball()
  self.light_track=gl2.trackball()
  self.pressed=false
  self.dragging=false
  self.light_dragging=false

  print("Configurando os shaders")
  self.fsh=gl2.fragment_shader()
  self.fsh:load_source("phong.frag")
  self.vsh=gl2.vertex_shader()
  self.vsh:load_source("phong.vert")
  self.prog=gl2.program()
  self.prog:attach(self.vsh)
  self.prog:attach(self.fsh)
	self.prog:bind_attribute(1,"attrib")
	self.prog:link()
  self.vsh:print_log()
  self.fsh:print_log()
  self.prog:print_log()
end

function filter_cnv:map_cb()
  iup.GLMakeCurrent(self)
  gl.ClearColor(1.0,1.0,1.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.ShadeModel('FLAT')
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
  if c == iup.K_ESC then
  -- sai da aplicação
  iup.ExitLoop()
	elseif c == iup.K_PGUP then
	  if attr_idx~=mht.eigenvector.size then
      attr_idx=attr_idx+1
			for i=1,attrs:size() do
			  attrs:set(i-1,mh:get(attr_idx-1,i-1))
			end
			local m=attrs:get(blas.imax(attrs)-1)
			blas.scal(1.0/m,attrs)
		end
	elseif c == iup.K_PGDN then
	  if attr_idx~=1 then
      attr_idx=attr_idx-1
			for i=1,attrs:size() do
			  attrs:set(i-1,mh:get(attr_idx-1,i-1))
			end
			local m=attrs:get(blas.imax(attrs)-1)
			blas.scal(1.0/m,attrs)
    end
  end
  cnv:action(0,0)
end

function cnv:button_cb(but,pressed,x,y,status)
  iup.GLMakeCurrent(self)
  if pressed==1 then 
	  self.model_track:start_motion(x,y)
	  self.light_track:start_motion(x,y)
		self.pressed=true
	else 
	  self.pressed=false
	end
	self.dragging=false
	self.light_dragging=false
  cnv:action(0,0)
end

function cnv:motion_cb(x,y,status)
  iup.GLMakeCurrent(self)
  if self.pressed then 
	  if iup.isshift(status) and iup.iscontrol(status) then
      self.light_track:move_rotation(x,y)
		  self.light_dragging=true
	  elseif iup.isshift(status) then
      self.model_track:move_scaling(x,y)
		  self.dragging=true
		elseif iup.iscontrol(status) then
      self.model_track:move_pan(x,y)
		  self.dragging=true
		elseif iup.isalt(status) then
      self.model_track:move_zoom(x,y)
		  self.dragging=true
		else 
      self.model_track:move_rotation(x,y)
		  self.dragging=true
		end
  	cnv:action(0,0)
	end
end

last_x=0
function filter_cnv:button_cb(but,pressed,x,y,status)
  iup.GLMakeCurrent(self)
  if pressed==1 then 
		self.pressed=true
		last_x=x
	else 
    blas.copy(vtx_high,vtx)
    blas.copy(coef,coef_t)
		for i=1,fil:size() do fil_exp:set(i-1,2^fil:get(i-1)) end
		coef_t:times(fil_exp)
    blas.gemm(1.0,mh,coef_t,1.0,vtx,true)
	  self.pressed=false
  	cnv:action(0,0)
	end
	self.dragging=false
end

function filter_cnv:motion_cb(x,y,status)
  iup.GLMakeCurrent(self)
  if self.pressed then 
	  local xx=last_x
	  if xx > x then 
		  x,xx=xx,x
		end
	  for i=xx,x do
		  if i>=0 and i<fil:size() then 
			  fil:set(i,(100-y)/100) 
			end
		end
		last_x=x
  	filter_cnv:action(0,0)
	end
end


-- exibe a janela
dlg:show()
--filter_dlg:show()
-- entra no loop de eventos
iup.MainLoop()
