dofile("modules.lua")
require("win")
require("gl2")
require("tetra_tree")
require("adia")
require("Heap")
require("queue")

require("functions3d")
dofile("util3d.lua")


function rescale(f)
  return function(x,y,z)
    x=2*x
    y=2*y
    z=2*z
    return f(x,y,z)
  end
end



function adaptation_test(diam,k)
  return function (q)
    local Ix,Iy,Iz=tree:bounding_box(q)
    local I=eq[0](Ix,Iy,Iz)
    local int=I:contains(0)
    local dx=eq[1](Ix,Iy,Iz)
    local dy=eq[2](Ix,Iy,Iz)
    local dz=eq[3](Ix,Iy,Iz)
    local dg=dx*dx+dy*dy+dz*dz
    if not int then
      return true
    elseif Ix:diam()<=diam then
      return true
    elseif not dg:contains(0) then
      dg=interval.sqrt(dg)
      dx=dx/dg
      dy=dy/dg
      dz=dz/dg
      if math.max(dx:diam(),dy:diam(),dz:diam())<k then
        return true
      end
    end
    return false
  end
end

function goodtetra_test(mct) 
  return function(xs,ys,zs)
    --return true
    return tetra_quality(xs,ys,zs)<=mct
  end
end

function reset(pars)
  print("reset")
  src_flag={}
  lmk_src={}
  lmk_dst={}
  heap=Heap.new()
  tree=tetra_tree.new()
  local x=ad.var(3,1)
  local y=ad.var(3,2)
  local z=ad.var(3,3)
  print(functions3d.names[pars.func+1])
  f=rescale(functions3d[functions3d.names[pars.func+1]])
  eq=f(x,y,z)
  stop=adaptation_test(2^pars.diam,pars.k)
  goodtetra=goodtetra_test(pars.mct)
  one_step=coroutine.create(main)
end

cnv = win.New("implwarp3d")

function draw_tetra(c)
  local vids,xs,ys,zs=tree:points(c)
  for i=1,4 do
    local x=xs[i]
    local y=ys[i]
    local z=zs[i]
    if f(x,y,z) >0.000001 and src_flag[vids[i]]==nil then 
      return
    end
  end
  gl.Disable('LIGHTING')
  gl.Color(0,0,0)
	gl.Begin('LINES')
 	gl.Vertex(xs[1],ys[1],zs[1])
 	gl.Vertex(xs[2],ys[2],zs[2])
  gl.Vertex(xs[1],ys[1],zs[1])
  gl.Vertex(xs[3],ys[3],zs[3])
  gl.Vertex(xs[1],ys[1],zs[1])
  gl.Vertex(xs[4],ys[4],zs[4])
  gl.Vertex(xs[2],ys[2],zs[2])
  gl.Vertex(xs[3],ys[3],zs[3])
  gl.Vertex(xs[2],ys[2],zs[2])
  gl.Vertex(xs[4],ys[4],zs[4])
  gl.Vertex(xs[3],ys[3],zs[3])
  gl.Vertex(xs[4],ys[4],zs[4])
	gl.End()
  gl.PointSize(4.0)
  gl.Begin('POINTS')
  for i=1,4 do
    local x=xs[i]
    local y=ys[i]
    local z=zs[i]
    if f(x,y,z) <=0.000001 then 
      gl.Color(1,0,0)
    else
      gl.Color(0,0,1)
    end
    gl.Vertex(x,y,z)
  end
  gl.End()
  gl.Enable('LIGHTING')
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

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:Display()
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()         
  glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
 
  if self.dragging then
    gl.PushMatrix()
    self.model_track:rotate()
    gl.Color(0.2,0.2,0.2)
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
      
  for c in tree:leafs() do 
      draw_tetra(c)
  end 
   
end

-- chamada quando a janela OpenGL é criada
function cnv:Init()
  print("Iniciando GLEW")
  gl2.init()
  print("Configurando OpenGL")
  gl.ClearColor(1.0,1.0,1.0,0.5)                  -- cor de fundo preta
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
  self.pars:NewVar {name="func",
     type={name="Functions",
                enum=functions3d.names }
  }
  self.pars.func=0
  self.pars:NewVar {name="diam", type=tw.TYPE_DOUBLE, properties="min=-6 max=-2 step=1"}
    self.pars.diam=-4
  self.pars:NewVar {name="k", type=tw.TYPE_DOUBLE, properties="min=0.5 max=10 step=0.5"}
    self.pars.k=1
  self.pars:NewVar {name="mct", type=tw.TYPE_DOUBLE, properties="min=1 max=8 step=0.5"}
    self.pars.mct=5
  self.pars:AddButton( "Reset", function() reset(self.pars) end)
  reset(self.pars)
end

-- chamada quando uma tecla é pressionada
function cnv:Keyboard(c,x,y)
  if c == 27 then
  -- sai da aplicação
    os.exit()
  elseif c == 32 then
    coroutine.resume(one_step)
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


function main()
  print("main")
  subdivide()
  coroutine.yield()
  split_edges()
  coroutine.yield()
  tubular()
  coroutine.yield()
  snap()
end

function subdivide()
  print("subdivide")
  local qc=queue.new()
  for c in tree:leafs() do
    qc:pushleft(c)
  end
  while not qc:empty() do
    local c=qc:popright()
    if tree:is_leaf(c) and not stop(c) then
      local recent=tree:split(c)
      for i=1,#recent do qc:pushleft(recent[i]) end
      --if math.random()<0.1 then coroutine.yield() end
    end    
  end
end

function split_edges()
  print("split")
  local qc=queue.new()
  for c in tree:leafs() do
    qc:pushleft(c)
  end
  while not qc:empty() do
    local c=qc:popright()
    if tree:is_leaf(c) then      
      local vids,xs,ys,zs=tree:vertices(c)
      local edge={{1,2},{1,3},{1,4},{2,3},{2,4},{3,4}}
      for i=1,6 do
        local x1=xs[edge[i][1]]
        local y1=ys[edge[i][1]]
        local z1=zs[edge[i][1]]
        local x2=xs[edge[i][2]]
        local y2=ys[edge[i][2]]
        local z2=zs[edge[i][2]]
        local f1=f(x1,y1,z1)
        local f2=f(x2,y2,z2)
        if f1*f2<0 then
          local t=bisect(
            function(t)
              return f((1-t)*x1+t*x2,(1-t)*y1+t*y2,(1-t)*z1+t*z2)
            end, 1/512)
          if t>0.4 and t<0.6 then 
            local recent=tree:split(c)
            if recent[i]:orthant_level()<=8 then 
              qc:pushleft(recent[i])
            end
            --if math.random()<0.1 then coroutine.yield() end
            break
          end
        end  
      end
    end
  end
end

function tubular()
  print("tubular")
  for c in tree:leafs() do
    local vids,xs,ys,zs=tree:vertices(c)
    local fs={}
    for i=1,4 do
      fs[i]=f(xs[i],ys[i],zs[i])
    end
    if (fs[1]*fs[2]<=0) or (fs[1]*fs[3]<=0) or (fs[1]*fs[4]<=0)
      or (fs[2]*fs[3]<=0) or (fs[2]*fs[4]<=0) or (fs[3]*fs[4]<=0) then
      local others={{2,3,4},{1,3,4},{1,2,4},{1,2,3}}
      for i=1,4 do
        --if f(x,y,z)<0.000001 then 
        local x=xs[i]
        local y=ys[i]
        local z=zs[i] 
        local x1=xs[others[i][1]]
        local y1=ys[others[i][1]]
        local z1=zs[others[i][1]]
        local x2=xs[others[i][2]]
        local y2=ys[others[i][2]]
        local z2=zs[others[i][2]]
        local x3=xs[others[i][3]]
        local y3=ys[others[i][3]]
        local z3=zs[others[i][3]]
        local xp,yp,zp=newton(eq,x,y,z,0.00001)
        if inside(xp,yp,zp,xs,ys,zs) then            
          local d=(x-xp)^2+(y-yp)^2+(z-zp)^2
          local d1=(x1-xp)^2+(y1-yp)^2+(z1-zp)^2
          local d2=(x2-xp)^2+(y2-yp)^2+(z2-zp)^2
          local d3=(x3-xp)^2+(y3-yp)^2+(z3-zp)^2
          if (d<d1 and d<d2 and d<d3) and not src_flag[vids[i]] then
            src_flag[vids[i]]=true
            lmk_src[#lmk_src+1]={x,y,z}
            lmk_dst[#lmk_dst+1]={xp,yp,zp}
            heap:push(#lmk_src,d)
          end
        end
      end
      --end
    end
  end
end

function snap()
  print("snap")
  while not heap:isempty() do
    local i,d=heap:pop()
    local x=lmk_src[i][1]
    local y=lmk_src[i][2]
    local z=lmk_src[i][3]
    local xd=lmk_dst[i][1]
    local yd=lmk_dst[i][2]
    local zd=lmk_dst[i][3]
    tree:set(x,y,z,xd,yd,zd)
    local cells=tree:cells(x,y,z)
    for i=1,#cells do
      local c=cells[i]
      local vids,xs,ys,zs=tree:points(c)
      if not goodtetra(xs,ys,zs) then
        tree:set(x,y,z,x,y,z)
        break
      end
    end
    --coroutine.yield()
  end
end

win.Loop()
