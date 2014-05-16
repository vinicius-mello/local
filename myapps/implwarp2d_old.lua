dofile("modules.lua")
require("win")
require("gl2")
require("array")
require("lpt")
require("adia")
require("Heap")
require("queue")

require("functions")

function f(x,y)
  x=2*x
  y=2*y
  --return x^2+y^2-1
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
vertices_id={}
vertices_id.size=0
src_flag={}
lmk_src={}
lmk_dst={}
heap=Heap.new()

tree=lpt.lpt2d_tree()

cnv = win.New("implwarp2d")

function draw_triangle(c)
  local vids=vertices_ids(c)
  local xs,ys=triangle_points(vids)
  if c:orientation()<0 then
    xs[2],xs[3]=xs[3],xs[2]
    ys[2],ys[3]=ys[3],ys[2]
  end
  local tq=1-goodtriangle(xs[1],ys[1],xs[2],ys[2],xs[3],ys[3])
  print(tq)
  gl.Color(tq,tq,tq)
  gl.Begin('TRIANGLES')
  gl.Vertex(xs[1],ys[1])
  gl.Vertex(xs[2],ys[2])
  gl.Vertex(xs[3],ys[3])
  gl.End()
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
    if f(x,y) <=0.000001 then 
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
      vertices_id.size=vertices_id.size+1
    end
  end    
end

function main()
  tree:node_reset()
  local first=tree:node_code()
  subdivide(first)
  coroutine.yield()
  split()
  print("end split")
  coroutine.yield()
  tubular()
  snap()
--  print("solve")
--  solve()
--  euler_iterate()
end

function split()
  print("split")
  local qc=queue.new()
  tree:node_reset()
  repeat
    local c=tree:node_code()
    if tree:node_is_leaf() then
      qc:pushleft(c)
    end
  until not tree:node_next()

  while not qc:empty() do
    local c=qc:popright()
    if tree:is_leaf(c) then      
      c:simplex(vert:data())
      local edg={{1,2},{1,3},{2,3}}
      for i=1,3 do
        local x1=vert:get(edg[i][1]-1,0)
        local y1=vert:get(edg[i][1]-1,1)
        local x2=vert:get(edg[i][2]-1,0)
        local y2=vert:get(edg[i][2]-1,1)
        local f1=f(x1,y1)
        local f2=f(x2,y2)
        if f1*f2<0 then
          local t1=0
          local t2=1
          local t
          while t2-t1>0.001 do
            t=(t1+t2)/2
            local xm=(1-t)*x1+t*x2
            local ym=(1-t)*y1+t*y2
            local fm=f(xm,ym)
            if f1*fm<0 then
              t2=t
            else
              t1=t
            end
          end
          t=(t1+t2)/2
          print(t)
          if t>0.43 and t<0.57 then 
            tree:compat_bisect(c)
            repeat 
              local rc=tree:recent_code()
              process_vertices(rc)
              qc:pushleft(rc)
            until not tree:recent_next()
            break
          end
        end  
      end
      print("end")
    end
  end
end


function tubular()
  print("tubular")
  tree:node_reset()
  repeat
    local c=tree:node_code()
    if tree:node_is_leaf() then
      c:simplex(vert:data())
      local fs={}
      for i=1,3 do
        local x=vert:get(i-1,0)
        local y=vert:get(i-1,1)
        fs[i]=f(x,y)
      end
      if (fs[1]*fs[2]<=0) or (fs[1]*fs[3]<=0) or (fs[2]*fs[3]<=0) then
        local others={{2,3},{1,3},{1,2}}
        for i=1,3 do
          local x=vert:get(i-1,0)
          local y=vert:get(i-1,1) 
          local x1=vert:get(others[i][1]-1,0)
          local y1=vert:get(others[i][1]-1,1)
          local x2=vert:get(others[i][2]-1,0)
          local y2=vert:get(others[i][2]-1,1)
          local xp,yp=newton(x,y)
          if inside(xp,yp,x,y,x1,y1,x2,y2) then            
            local d=(x-xp)^2+(y-yp)^2
            local d1=(x1-xp)^2+(y1-yp)^2
            local d2=(x2-xp)^2+(y2-yp)^2
            if 1.1*d<d1 and 1.1*d<d2 then
              local vc=lpt.morton2_16(x,y)
              if not src_flag[vc] then
                src_flag[vc]=true
                lmk_src[#lmk_src+1]={x,y}
                lmk_dst[#lmk_dst+1]={xp,yp}
                heap:push(#lmk_src,d)
              end
            end
          end
        end
      end
    end
  until not tree:node_next()
end

function snap()
  while not heap:isempty() do
    local i,d=heap:pop()
    local x=lmk_src[i][1]
    local y=lmk_src[i][2]
    local xd=lmk_dst[i][1]
    local yd=lmk_dst[i][2]
    local vc=lpt.morton2_16(x,y)
    vertices:set(vertices_id[vc],0,xd)
    vertices:set(vertices_id[vc],1,yd)    
    coroutine.yield()
  end
end

function newton(x,y) 
  local eps=math.huge
  local tau=0.00001
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


function inside(x,y,x0,y0,x1,y1,x2,y2)
  local Area = 1/2*(-y1*x2 + y0*(-x1 + x2) + x0*(y1 - y2) + x1*y2)
  local s = 1/(2*Area)*(y0*x2 - x0*y2 + (y2 - y0)*x + (x0 - x2)*y)
  local t = 1/(2*Area)*(x0*y1 - y0*x1 + (y0 - y1)*x + (x1 - x0)*y)
  return (s>=0) and (t>=0) and ((1-s-t)>=0) 
end

function cot(ux,uy,vx,vy)
  local dot=ux*vx+uy*vy
  return dot/math.sqrt((ux*ux+uy*uy)*(vx*vx+vy*vy)-dot*dot)
end

function goodtriangle(x0,y0,x1,y1,x2,y2)
  --           0
  --       1       2
  local a=cot(x1-x0,y1-y0,x2-x0,y2-y0) 
  local b=cot(x2-x1,y2-y1,x0-x1,y0-y1) 
  local c=cot(x0-x2,y0-y2,x1-x2,y1-y2) 
  return math.min(5,math.max(math.abs(a),math.abs(b),math.abs(c)))/5  
end

stop=dot_grad_test2(0.05,1)
--stop=dot_grad_test2(0.001,3)
one_step=coroutine.create(main)

win.Loop()
