dofile("modules.lua")
dofile("DiffLandMatch.lua")
require("win")
require("gl2")
require("array")
require("lpt")
require("adia")

require("functions")

function f(x,y)
  x=2*x
  y=2*y
  return clown(x,y)
end

local x=ad.var(2,1)
local y=ad.var(2,2)
local eq=f(x,y)


function bounding_box(q) 
  q:simplex(vert:data())
  local max_x=-math.huge
  local min_x=math.huge
  local max_y=-math.huge
  local min_y=math.huge
  for i=0,2 do 
    max_x=math.max(max_x,vert:get(i,0))
    min_x=math.min(min_x,vert:get(i,0))
    max_y=math.max(max_y,vert:get(i,1))
    min_y=math.min(min_y,vert:get(i,1))
  end
  return interval.new(min_x,max_x),interval.new(min_y,max_y)
end

function dot_grad_test(diam)
  return function (q)
    local Ix,Iy=bounding_box(q)
    local I=eq[0](Ix,Iy)
    local int=I:contains(0)
    local dx=eq[1](Ix,Iy)
    local dy=eq[2](Ix,Iy)
    local dg=dx*dx+dy*dy
    if not int then
      return true
    elseif Ix:diam()<diam then
      return true
    elseif not dg:contains(0) then
      return true
    end
    return false
  end
end

function dot_grad_test2(diam,k)
  return function (q)
    local Ix,Iy=bounding_box(q)
    local I=eq[0](Ix,Iy)
    local int=I:contains(0)
    local dx=eq[1](Ix,Iy)
    local dy=eq[2](Ix,Iy)
    local dg=dx*dx+dy*dy
    if not int then
      return true
    elseif Ix:diam()<diam then
      return true
    elseif not dg:contains(0) then
      dg=interval.sqrt(dg)
      dx=dx/dg
      dy=dy/dg
      if math.max(dx:diam(),dy:diam())<k then
        return true
      end
    end
    return false
  end
end

vert=array.double(3,2)
pnt=array.double(2);
vertices=array.double(2000,2)
vertices_f=array.double(2000)
vertices_id={}
vertices_id.size=0
edges={}
roots={}
lmk_src={}
lmk_dst={}

tree=lpt.lpt2d_tree()

cnv = win.New("ldenimpl2d")

function draw_triangle(c)
	--c:simplex(vert:data())
--[[
  gl.Begin('TRIANGLES')
  gl.Vertex(vert:get(0,0),vert:get(0,1))
	if c:orientation()>0 then 
    gl.Vertex(vert:get(1,0),vert:get(1,1))
    gl.Vertex(vert:get(2,0),vert:get(2,1))
	else
    gl.Vertex(vert:get(2,0),vert:get(2,1))
    gl.Vertex(vert:get(1,0),vert:get(1,1))
	end
	gl.End()
  ]]
  local vids=vertices_ids(c)
  local xs,ys=triangle_points(vids)
	gl.Color(0,0,0)
	gl.Begin('LINE_LOOP')
 	gl.Vertex(xs[1],ys[1])
 	gl.Vertex(xs[2],ys[2])
 	gl.Vertex(xs[3],ys[3])
	gl.End()
  gl.PointSize(4.0)
  gl.Begin('POINTS')
  for i=1,3 do
    local x=xs[i]
    local y=ys[i]
    if vertices_f:get(vids[i]) <=0 then 
      gl.Color(1,0,0)
    else
      gl.Color(0,0,1)
    end
    gl.Vertex(x,y)
  end
  gl.End()
end

-- chamada quando a janela OpenGL é redimensionada
function cnv:Reshape(width, height)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
	self.width=width
	self.height=height
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:Display()
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()         
  tree:node_reset()
  repeat 
    if tree:node_is_leaf() then
	    local c=tree:node_code()
      draw_triangle(c)
  	end
  until not tree:node_next()

  for i=1,#edges do
    local t=edges[i]
    if t then
      gl.Color(1,1,0)
      gl.Begin('LINES')
      for j=1,#t do
        local xs,ys=edge_points(i,t[j])        
        gl.Vertex(xs[1],ys[1])
        gl.Vertex(xs[2],ys[2])
      end
      gl.End()
    end 
  end
  for i=1,#roots do
    local t=roots[i]
    if t then
      gl.Color(1,0,1)
      gl.Begin('POINTS')
      for j=1,#t do
        local x,y=t[j][1],t[j][2]        
        gl.Vertex(x,y)
      end
      gl.End()
    end 
  end
end

-- chamada quando a janela OpenGL é criada
function cnv:Init()
  gl.ClearColor(1.0,1.0,1.0,0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
  tree:node_reset()
  repeat
    local c=tree:node_code()
    process_vertices(c)
  until not tree:node_next()
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

function vertices_ids(c) 
  c:simplex(vert:data())
  local vids={}
  for i=0,2 do 
    local x=vert:get(i,0)
    local y=vert:get(i,1)
    local vc=lpt.morton2_16(x,y)
    vids[#vids+1]=vertices_id[vc]
  end
  return vids
end

function process_vertices(c)
  c:simplex(vert:data())
  for i=0,2 do 
    local x=vert:get(i,0)
    local y=vert:get(i,1)
    local vc=lpt.morton2_16(x,y)
    if vertices_id[vc]==nil then
      vertices_id[vc]=vertices_id.size
      vertices:set(vertices_id.size,0,x)
      vertices:set(vertices_id.size,1,y)
      vertices_f:set(vertices_id.size,f(x,y))
      vertices_id.size=vertices_id.size+1
    end
  end    
end

function main()
  tree:node_reset()
  local first=tree:node_code()
  subdivide(first)
  coroutine.yield()
  edges[0]=false
  for i=1, vertices_id.size do
    edges[#edges+1]=false
  end
  cross_edges()
  coroutine.yield()
  find_roots()
  coroutine.yield()
  closest_root()
  coroutine.yield()
  print("solve")
  edges={}
  roots={}
  solve()
  euler_iterate()
end

function bissect(x0,y0,x1,y1)
  local xm=(x0+x1)/2
  local ym=(y0+y1)/2  
  if ((x0-x1)^2+(y0-y1)^2)<0.0001 then
    return xm,ym 
  else 
    local fm=f(xm,ym)
    if fm*f(x0,y0)>0 then
      return bissect(xm,ym,x1,y1)
    else 
      return bissect(x0,y0,xm,ym)
    end
  end    
end  

function find_roots()
  for i=1,#edges do
    roots[#roots+1]=false
    local t=edges[i]
    if t then
      local rs={}
      for j=1,#t do
        local xs,ys=edge_points(i,t[j])        
        local xr,yr=bissect(xs[1],ys[1],xs[2],ys[2])
        rs[#rs+1]={xr,yr}
      end
      roots[i]=rs
    end 
  end  
end


function closest_root()
  for i=1,#roots do
    local t=roots[i]
    if t then
      local min_d=math.huge
      local x,y,xm,ym
      x=vertices:get(i,0)
      y=vertices:get(i,1)
      for j=1,#t do
        local xr,yr=t[j][1],t[j][2]    
        local d2=(x-xr)^2+(y-yr)^2
        if d2<min_d then
          min_d=d2
          xm=xr
          ym=yr
        end
      end
      local xn,yn=newton(x,y)
      local d2=(x-xn)^2+(y-yn)^2
      if d2<min_d then
        min_d=d2
        xm=xn
        ym=yn
      end
      roots[i]={{xm,ym}}
      lmk_src[#lmk_src+1]={x,y}
      lmk_dst[#lmk_dst+1]={xm,ym}    
    end 
  end  
end

function newton(x,y) 
  local eps=math.huge
  local tau=0.001
  local xn
  local yn
  local i=0
  while eps>tau or i<20 do
    local f=eq[0](x,y)
    local fx=eq[1](x,y)
    local fy=eq[2](x,y)
    local df2=fx*fx+fy*fy
    xn=x-fx/df2*f
    yn=y-fy/df2*f
    eps=math.sqrt((xn-x)^2+(yn-y)^2)
    i=i+1
    x,y=xn,yn
  end
  return xn,yn
end

function insert_edge(v1,v2)
  if not edges[v1] then
    edges[v1]={v2}
  else
    local t=edges[v1]
    for i=1,#t do
      if v2==t[i] then
        return
      end
    end
    t[#t+1]=v2
    edges[v1]=t    
  end
end

function vertex_point(i)

end

function edge_points(i,j)
  local xs={}
  local ys={}
  xs[1]=vertices:get(i,0)
  ys[1]=vertices:get(i,1)
  xs[2]=vertices:get(j,0)
  ys[2]=vertices:get(j,1)
  return xs,ys
end

function triangle_points( vids )
  local xs={}
  local ys={}
  xs[1]=vertices:get(vids[1],0)
  ys[1]=vertices:get(vids[1],1)
  xs[2]=vertices:get(vids[2],0)
  ys[2]=vertices:get(vids[2],1)
  xs[3]=vertices:get(vids[3],0)
  ys[3]=vertices:get(vids[3],1)
  return xs,ys
end

function cross_edges()
  tree:node_reset()
  repeat
    local c=tree:node_code()
    if tree:node_is_leaf() then
      local vids=vertices_ids(c)
      local xs,ys=triangle_points(vids)
      local ed={{1,2},{1,3},{2,3}}
      for i=1,3 do
        local e1=ed[i][1]
        local e2=ed[i][2]
        local f1=f(xs[e1],ys[e1])
        local f2=f(xs[e2],ys[e2])
        if f1<=0 and f2>0 then
          insert_edge(vids[e1],vids[e2])
        elseif f1>0 and f2<=0 then 
          insert_edge(vids[e2],vids[e1])
        end
      end      
    end
  until not tree:node_next()
end

function subdivide(q)
  if tree:is_leaf(q) then
    if stop(q) then return end 
    tree:compat_bisect(q)
    local recent={}
    repeat 
      local c=tree:recent_code()
      process_vertices(c)
      recent[#recent+1]=c
    until not tree:recent_next()
    --coroutine.yield()
    for i=1,#recent do
      subdivide(recent[i])
    end
  else
    return
  end
end

function solve()
  print("Solving")
  local n=2
  local N=#lmk_src
  local m=10
  local mu=0.0
  print("m",m)
  print("n",n)
  print("N",N)
  data=alloc_data(n,N,m)
  init_data(data,lmk_src,lmk_dst)
  env=clamped_thin_plate_spline(mu)
  ws=alloc_workspace(n,N,m)
  local solver=alloc_solver(data,env,ws)
  solver.opt:pgtol_set(1)
  solver.opt:factr_set(100)
  local count=0
  repeat
    solver:iterate()
    count=count+1
  until solver.task=="conv" or count>=25
    
  solve_alpha(data,env,ws)
end

function euler_step(t,dt)
    local n=2
    local vxt=array.double(n)
    for i=0,vertices_id.size do
        local x=vertices:row(i)
        if env.in_domain(x) then
          v(x,t,vxt,data,env,ws)
          blas.axpy(dt,vxt,x)
        end
    end
end

function euler_iterate()
  local dt=0.05
  local t=0
  while t<1.0 do
    euler_step(t,dt)
    t=t+dt
    coroutine.yield()
  end
end

stop=dot_grad_test2(0.001,4)
one_step=coroutine.create(main)

win.Loop()
