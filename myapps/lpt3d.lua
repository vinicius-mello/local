dofile("modules.lua")
require("win")
--require("luagl")
--require("luaglu")
require("array")
require("gl2")
require("queue")
require("vec")
require("lpt")

vert=array.double(12)
pnt=array.double(3)
pnt2=array.double(3)
temp=array.double(3)
ori=array.double(3)
ori:set(0,0.5)
ori:set(1,0.5)
ori:set(2,0.5)
selected=nil
visible={true,true,true,true,true,true}

unprojection=gl2.unprojection()

tree=lpt.lpt3d_tree()


cnv = win.New("lpt3d")

-- chamada quando a janela OpenGL é redimensionada
function cnv:Reshape(width, height)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
	self.height=height
	self.width=width

  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
	glu.Perspective(60,width/height,0.01,1000)

  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
	self.radius=1
	glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
  self.model_track:resize(self.radius)
  self.light_track:resize(self.radius)
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

function draw_face(a,b,c)
  local va=vec.new(a) 
  local vb=vec.new(b) 
  local vc=vec.new(c) 
	gl.Normal((vb-va)^(vc-va))
 	gl.Vertex(a)
 	gl.Vertex(b)
 	gl.Vertex(c)
end

function draw_quad(a,b,c,d)
  local va=vec.new(a) 
  local vb=vec.new(b) 
  local vc=vec.new(c) 
  local vc=vec.new(d) 
  gl.Normal((vb-va)^(vc-va))
  gl.Vertex(a)
  gl.Vertex(b)
  gl.Vertex(c)
  gl.Vertex(d)
end

function shrink(a,b,c,ratio)
  local as={(1-2*ratio)*a[1]+ratio*b[1]+ratio*c[1],
    (1-2*ratio)*a[2]+ratio*b[2]+ratio*c[2],
    (1-2*ratio)*a[3]+ratio*b[3]+ratio*c[3]}
  local bs={ratio*a[1]+(1-2*ratio)*b[1]+ratio*c[1],
    ratio*a[2]+(1-2*ratio)*b[2]+ratio*c[2],
    ratio*a[3]+(1-2*ratio)*b[3]+ratio*c[3]}
  local cs={ratio*a[1]+ratio*b[1]+(1-2*ratio)*c[1],
    ratio*a[2]+ratio*b[2]+(1-2*ratio)*c[2],
    ratio*a[3]+ratio*b[3]+(1-2*ratio)*c[3]}
    return as,bs,cs
end

function draw_tetra(cur,id)
 	cur:simplex(vert:data())
	local a={vert:get(0),vert:get(1),vert:get(2)}
	local b={vert:get(3),vert:get(4),vert:get(5)}
	local c={vert:get(6),vert:get(7),vert:get(8)}
	local d={vert:get(9),vert:get(10),vert:get(11)}
	if cur:orientation()<0 then
	  c,d=d,c
	end
  if selected and tree:id(selected)==id then
	  gl.Material('FRONT','DIFFUSE',{0,0,1})
	else
	  gl.Material('FRONT','DIFFUSE',{1,0,0})
	end
  gl.Enable('POLYGON_OFFSET_FILL')
  gl.PolygonOffset(1.0,1.0)
  gl.PolygonMode('FRONT','FILL')
	gl.Begin('TRIANGLES')
 	draw_face(b,c,d)
 	draw_face(a,d,c)
 	draw_face(a,b,d)
 	draw_face(a,c,b)
	gl.End()
  gl.Disable('POLYGON_OFFSET_FILL')
	gl.Disable('LIGHTING')
	gl.Color(1,1,1)
  gl.PolygonMode('FRONT','LINE')
	gl.Begin('TRIANGLES')
 	draw_face(b,c,d)
 	draw_face(a,d,c)
 	draw_face(a,b,d)
 	draw_face(a,c,b)
	gl.End()
	gl.Enable('LIGHTING')
end

function draw_tetra2(cur,id,ratio)
  
  cur:simplex(vert:data())
  local a={vert:get(0),vert:get(1),vert:get(2)}
  local b={vert:get(3),vert:get(4),vert:get(5)}
  local c={vert:get(6),vert:get(7),vert:get(8)}
  local d={vert:get(9),vert:get(10),vert:get(11)}
  if cur:orientation()<0 then
    c,d=d,c
  end
  
  local ac,bc,dc=shrink(a,b,d,ratio)
  local ba,ca,da=shrink(b,c,d,ratio)
  local ad,cd,bd=shrink(a,c,b,ratio)
  local ab,db,cb=shrink(a,d,c,ratio)
  
  if selected and tree:id(selected)==id then
    gl.Material('FRONT','DIFFUSE',{0,0,1})
  else
    gl.Material('FRONT','DIFFUSE',{1,0,0})
  end
  gl.Enable('POLYGON_OFFSET_FILL')
  gl.PolygonOffset(1.0,1.0)
  gl.PolygonMode('FRONT','FILL')
  gl.Begin('QUADS')
  draw_quad(ab,db,dc,ac)
  draw_quad(ab,ad,cd,cb)
  draw_quad(ad,ac,bc,bd)
  draw_quad(bd,ba,ca,cd)
  draw_quad(ba,bc,dc,da)
  draw_quad(cb,ca,da,db)
  gl.End()
  gl.Begin('TRIANGLES')
  draw_face(ab,ac,ad)
  draw_face(ba,bd,bc)
  draw_face(ca,cb,cd)
  draw_face(da,dc,db)
  gl.End()
  gl.Disable('POLYGON_OFFSET_FILL')
  gl.Disable('LIGHTING')
  gl.Color(1,1,1)
  gl.PolygonMode('FRONT','LINE')
  gl.Begin('QUADS')
  draw_quad(ab,db,dc,ac)
  draw_quad(ab,ad,cd,cb)
  draw_quad(ad,ac,bc,bd)
  draw_quad(bd,ba,ca,cd)
  draw_quad(ba,bc,dc,da)
  draw_quad(cb,ca,da,db)
  gl.End()
  gl.Begin('TRIANGLES')
  draw_face(ab,ac,ad)
  draw_face(ba,bd,bc)
  draw_face(ca,cb,cd)
  draw_face(da,dc,db)
  gl.End()
  gl.Enable('LIGHTING')
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:Display()
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
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

  tree:node_reset()
  repeat 
    if tree:node_is_leaf() then
	    local cur=tree:node_code()
			local id=tree:node_id()
      print(id)
			if visible[id]==nil then
			  visible[id]=true
			end
			if visible[id] then 
  		draw_tetra2(cur,id,self.pars.ratio)
			end
  	end
  until not tree:node_next()

  print(ori:get(0),ori:get(1),ori:get(2))
  tree:search_all(ori:data())
  repeat
    print(tree:recent_id())
  until not tree:recent_next()

end

-- chamada quando a janela OpenGL é criada
function cnv:Init()
  print("Iniciando GLEW")
  gl2.init()
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
  --gl.ShadeModel('FLAT')
  gl.Enable ('CULL_FACE')
  gl.Enable ('NORMALIZE')

  print("Iniciando a trackball")
  self.model_track=gl2.trackball()
  self.light_track=gl2.trackball()
  self.pressed=false
  self.dragging=false
  self.light_dragging=false
  self.pars=bar.New("Parameters")
  self.pars:NewVar {name="ratio", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.02"}
  self.pars.ratio=0.1
end

-- chamada quando uma tecla é pressionada
function cnv:Keyboard(c,x,y)
  if c == 27 then
  -- sai da aplicação
    os.exit()
	elseif c == 115 then
	  if selected then
		  tree:compat_bisect(selected)
			repeat 
			  local c=tree:recent_code()
				visible[tree:recent_id()]=visible[tree:id(c:parent())]
			until not tree:recent_next()
			selected=nil
		end
	elseif c == 104 then
	  if selected then
		  visible[tree:id(selected)]=false
		end
  end
end

function cnv:Mouse(button,state,x,y)
    if button==glut.LEFT_BUTTON and
        state==glut.DOWN then
        self.model_track:start_motion(x,y)
        self.light_track:start_motion(x,y)
        self.pressed=true
        self.mod_status=self:GetModifiers()
    else
        self.pressed=false
        if not self.dragging or self.light_dragging then
          pnt:set(0,x)
          pnt:set(1,self.height-y)
          unprojection:reset()
          local qu=queue.new()
          for i=0,5 do 
            qu:pushleft(lpt.lpt3d(i))
          end
          local min_t=1.0
          selected=nil
          while not qu:empty() do
            local c=qu:popright()
            c:simplex(vert:data())
            local inter=unprojection:to_tetra(pnt:data(),vert:data(),pnt2:data(),temp:data(),c:orientation())
            if inter then
              if not tree:is_leaf(c) then
                qu:pushleft(c:child(0))
                qu:pushleft(c:child(1))
              else 
                if visible[tree:id(c)] then
                  if temp:get(0)<min_t then
                    min_t=temp:get(0)
                    selected=c
                  end
                end
              end
            end
          end
        end    
    end
    self.dragging=false
    self.light_dragging=false
end

function cnv:Motion(x,y)
    if self.pressed then
        if self:ActiveShift(self.mod_status) and self:ActiveCtrl(self.mod_status) then
            self.light_track:move_rotation(x,y)
            self.light_dragging=true
        elseif self:ActiveShift(self.mod_status) then
            self.model_track:move_scaling(x,y)
            self.dragging=true
        elseif self:ActiveCtrl(self.mod_status) then
            self.model_track:move_pan(x,y)
            self.dragging=true
        elseif self:ActiveAlt(self.mod_status) then
            self.model_track:move_zoom(x,y)
            self.dragging=true
        else
            self.model_track:move_rotation(x,y)
            self.dragging=true
        end
    end
end

win.Loop()
